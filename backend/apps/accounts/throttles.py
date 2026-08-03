import hashlib

from rest_framework.throttling import ScopedRateThrottle


class EmailScopedThrottle(ScopedRateThrottle):
    """Keys on email plus IP rather than IP alone.

    IP-only throttling is defeated by a botnet and simultaneously punishes
    everyone behind a single carrier NAT, which in Indonesia and Pakistan
    is a large share of this app's users. Email-only throttling is defeated
    by rotating addresses. Both together are cheap and awkward to evade.

    The key is hashed so that a Redis dump does not become a list of the
    email addresses that recently attempted to sign in.
    """

    def get_cache_key(self, request, view):
        email = (request.data.get("email") or "").lower().strip()
        ident = self.get_ident(request)
        raw = f"{email}|{ident}".encode()
        return f"throttle_{self.scope}_{hashlib.sha256(raw).hexdigest()}"
