import os

from celery import Celery

os.environ.setdefault("DJANGO_SETTINGS_MODULE", "config.settings.dev")

app = Celery("quran_one")
app.config_from_object("django.conf:settings", namespace="CELERY")
app.autodiscover_tasks()

# Four queues, not one. A slow content-pack build must never delay an Athan
# notification, and notifications are the only thing here with a hard
# deadline.
app.conf.task_routes = {
    "apps.prayer.tasks.*": {"queue": "notifications"},
    "apps.content.tasks.*": {"queue": "content"},
    "apps.billing.tasks.*": {"queue": "billing"},
    "apps.sync.tasks.*": {"queue": "default"},
}
