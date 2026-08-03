from django.db import connection
from django.http import HttpRequest, JsonResponse
from django.views.decorators.csrf import csrf_exempt


@csrf_exempt
def health(request: HttpRequest) -> JsonResponse:
    """Liveness. Answers only: is this process running.

    It touches nothing. A health check that queries the database will take
    the whole fleet out during a brief database blip.
    """
    return JsonResponse({"status": "ok"})


@csrf_exempt
def readiness(request: HttpRequest) -> JsonResponse:
    """Readiness. Answers: can this process serve traffic."""
    checks = {"database": False, "cache": False}

    try:
        with connection.cursor() as cursor:
            cursor.execute("SELECT 1")
        checks["database"] = True
    except Exception:  # noqa: BLE001
        pass

    try:
        from django.core.cache import cache

        cache.set("readyz", 1, 5)
        checks["cache"] = cache.get("readyz") == 1
    except Exception:  # noqa: BLE001
        pass

    ok = all(checks.values())
    return JsonResponse(
        {"status": "ok" if ok else "degraded", "checks": checks},
        status=200 if ok else 503,
    )
