from celery import shared_task
from django.conf import settings
from django.core.mail import send_mail


@shared_task(queue="notifications", max_retries=3)
def send_password_reset(user_id: str, raw_token: str) -> None:
    """Sends the reset link.

    The raw token is passed as an argument and never logged. Celery task
    arguments are visible in Flower and in the broker, so this task must
    stay on a queue whose broker is not shared with anything external.
    """
    from apps.accounts.models import User

    user = User.objects.filter(pk=user_id).first()
    if user is None:
        return

    link = f"{settings.APP_WEB_URL}/reset?token={raw_token}"
    send_mail(
        subject="Reset your Quran One password",
        message=(
            "Use the link below to set a new password. It expires in 30 "
            f"minutes.\n\n{link}\n\n"
            "If you did not request this, no action is needed."
        ),
        from_email=settings.DEFAULT_FROM_EMAIL,
        recipient_list=[user.email],
        fail_silently=False,
    )


@shared_task(queue="notifications", max_retries=3)
def send_email_verification(user_id: str, raw_token: str) -> None:
    from apps.accounts.models import User

    user = User.objects.filter(pk=user_id).first()
    if user is None:
        return

    link = f"{settings.APP_WEB_URL}/verify?token={raw_token}"
    send_mail(
        subject="Confirm your email",
        message=(
            "Confirm your address with the link below. Your account already "
            f"works without this.\n\n{link}"
        ),
        from_email=settings.DEFAULT_FROM_EMAIL,
        recipient_list=[user.email],
        fail_silently=False,
    )
