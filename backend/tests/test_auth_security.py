"""Authentication security tests.

Tagged so they can be selected, but they are not optional: this module
runs on every pull request. The failures it catches are the ones that
never get caught in review.

Nothing here talks to a real identity provider. Provider tokens are
signed locally against a fixture JWKS, because a suite that needs
Google credentials is a suite that gets skipped in CI within a month.
"""

import time

import pytest
from django.urls import reverse

pytestmark = [pytest.mark.django_db, pytest.mark.security]


class TestAccountEnumeration:
    def test_forgot_password_is_indistinguishable(self, client, user):
        known = client.post(
            reverse("auth-password-forgot"), {"email": user.email}
        )
        unknown = client.post(
            reverse("auth-password-forgot"), {"email": "nobody@example.com"}
        )

        assert known.status_code == unknown.status_code == 202
        assert known.json() == unknown.json()

    def test_login_rejects_both_cases_identically(self, client, user):
        missing = client.post(
            reverse("auth-login"),
            {"email": "nobody@example.com", "password": "whatever"},
        )
        wrong = client.post(
            reverse("auth-login"),
            {"email": user.email, "password": "whatever"},
        )

        assert missing.status_code == wrong.status_code == 401
        assert missing.json()["error"]["code"] == wrong.json()["error"]["code"]
        assert missing.json()["error"]["message"] == (
            wrong.json()["error"]["message"]
        )

    def test_login_timing_is_equalised(self, client, user):
        """Not a strict bound. CI runners are noisy and a tight ratio
        here produces a test everyone learns to ignore. A 3x gate still
        catches the real bug, which is skipping the password hasher
        entirely when the user row is absent.
        """

        def timed(email):
            start = time.perf_counter()
            client.post(
                reverse("auth-login"), {"email": email, "password": "x"}
            )
            return time.perf_counter() - start

        # Warm the hasher so the first call does not pay import cost.
        timed(user.email)

        missing = min(timed("nobody@example.com") for _ in range(3))
        present = min(timed(user.email) for _ in range(3))

        assert missing < present * 3


class TestSocialTokens:
    def test_wrong_signing_key_is_rejected(self, client, attacker_key):
        """Guards the single worst social auth bug: decoding a provider
        token without verifying it against the provider's JWKS.
        """
        token = sign_identity_token(key=attacker_key, sub="victim-apple-id")
        response = client.post(
            "/v1/auth/social/apple", {"identity_token": token}
        )

        assert response.status_code == 401
        assert response.json()["error"]["code"] == "unauthorized"

    def test_mismatched_nonce_is_rejected(self, client, apple_key):
        token = sign_identity_token(
            key=apple_key, sub="apple-id", nonce="hash-of-something-else"
        )
        response = client.post(
            "/v1/auth/social/apple",
            {"identity_token": token, "raw_nonce": "the-real-nonce"},
        )

        assert response.status_code == 401

    def test_wrong_audience_is_rejected(self, client, apple_key):
        token = sign_identity_token(
            key=apple_key, sub="apple-id", aud="app.someoneelse"
        )
        response = client.post(
            "/v1/auth/social/apple", {"identity_token": token}
        )

        assert response.status_code == 401

    def test_expired_token_is_rejected(self, client, apple_key):
        token = sign_identity_token(
            key=apple_key, sub="apple-id", exp=int(time.time()) - 60
        )
        response = client.post(
            "/v1/auth/social/apple", {"identity_token": token}
        )

        assert response.status_code == 401


class TestAccountTakeover:
    def test_unverified_email_does_not_auto_link(
        self, client, unverified_squatter, google_key
    ):
        """The takeover.

        An attacker registers with victim@example.com using a password
        and never verifies the address. The victim later signs in with
        Google on that same address. If the server links by email
        alone, the attacker's password now opens the victim's account.
        """
        token = sign_identity_token(
            key=google_key,
            sub="google-victim",
            email=unverified_squatter.email,
            email_verified=True,
        )
        response = client.post(
            "/v1/auth/social/google", {"identity_token": token}
        )

        assert response.status_code == 200
        assert response.json()["account"]["id"] != str(unverified_squatter.pk)

    def test_provider_asserting_unverified_email_never_links(
        self, client, user, google_key
    ):
        token = sign_identity_token(
            key=google_key,
            sub="google-stranger",
            email=user.email,
            email_verified=False,
        )
        response = client.post(
            "/v1/auth/social/google", {"identity_token": token}
        )

        assert response.json()["account"]["id"] != str(user.pk)


class TestSessionLifecycle:
    def test_password_reset_revokes_every_session(
        self, client, user_with_three_devices
    ):
        perform_reset(client, user_with_three_devices)
        assert outstanding_jtis(user_with_three_devices) == set()

    def test_password_change_spares_the_current_session(self, auth_client):
        current = current_jti(auth_client)
        perform_change(auth_client)

        remaining = outstanding_jtis(auth_client.user)
        assert remaining == {current}

    def test_rotated_refresh_survives_a_lost_response(self, client, user):
        """Refresh succeeds server side and the client never sees the
        response. On the mobile networks a large share of these users
        are on, this happens constantly. Without the grace window it
        signs people out at random, and it is unreproducible in an
        office.
        """
        refresh = issue_refresh(user)

        first = client.post(reverse("auth-refresh"), {"refresh": refresh})
        assert first.status_code == 200

        retry = client.post(reverse("auth-refresh"), {"refresh": refresh})
        assert retry.status_code == 200, "grace window not honoured"

        # But briefly, and only once. Beyond the window a replayed
        # refresh token is a stolen refresh token.
        with freeze_time("+60s"):
            late = client.post(reverse("auth-refresh"), {"refresh": refresh})
        assert late.status_code == 401

    def test_entitlement_is_never_a_jwt_claim(self, auth_client):
        # A claim the client holds is a claim the client can forge for
        # the lifetime of the token. Premium is read from the server.
        claims = decode_access(current_access(auth_client))
        assert "premium" not in claims
        assert "tier" not in claims
        assert set(claims) <= {"sub", "iat", "exp", "jti", "token_type"}


class TestBruteForce:
    def test_delay_escalates_but_never_locks_out(self, client, user):
        from apps.core.security import LoginAttemptGuard

        delays = [LoginAttemptGuard.delay_for(n) for n in range(0, 12)]

        assert delays[:3] == [0, 0, 0], "honest typos must not be punished"
        assert delays[5] > delays[3]
        assert max(delays) <= 30, (
            "a permanent lockout converts brute force into a denial of "
            "service against the victim"
        )


class TestLogHygiene:
    def test_no_credential_or_location_reaches_the_logs(
        self, client, caplog, user
    ):
        client.post(
            reverse("auth-login"),
            {"email": user.email, "password": "correct horse battery"},
        )

        blob = caplog.text.lower()
        for leak in (
            "correct horse battery",
            user.email.lower(),
            "latitude",
            "longitude",
            "refresh",
        ):
            assert leak not in blob, f"{leak} reached the log stream"
