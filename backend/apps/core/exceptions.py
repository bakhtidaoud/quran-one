from typing import Any

from rest_framework import status
from rest_framework.response import Response
from rest_framework.views import exception_handler as drf_handler


def handler(exc: Exception, context: dict[str, Any]) -> Response | None:
    """One error envelope for every failure the API can produce.

    The Flutter client maps `code` onto its sealed QFailure hierarchy. Free
    text is for humans; `code` is the contract. Adding a new code is a
    breaking change and is treated as one.
    """
    response = drf_handler(exc, context)

    if response is None:
        return None

    request = context.get("request")
    trace_id = getattr(request, "request_id", None)

    code = _code_for(response.status_code, response.data)
    detail = response.data

    payload: dict[str, Any] = {
        "error": {
            "code": code,
            "message": _message_for(detail),
            "trace_id": trace_id,
        }
    }

    if isinstance(detail, dict) and code == "validation_failed":
        payload["error"]["fields"] = detail

    if response.status_code == status.HTTP_429_TOO_MANY_REQUESTS:
        retry_after = response.headers.get("Retry-After")
        if retry_after:
            payload["error"]["retry_after"] = int(retry_after)

    response.data = payload
    return response


def _code_for(status_code: int, detail: Any) -> str:
    if status_code == 400:
        return "validation_failed"
    if status_code == 401:
        return "unauthorized"
    if status_code == 403:
        return "forbidden"
    if status_code == 404:
        return "not_found"
    if status_code == 409:
        return "conflict"
    if status_code == 429:
        return "rate_limited"
    if status_code >= 500:
        return "server_error"
    return "error"


def _message_for(detail: Any) -> str:
    if isinstance(detail, str):
        return detail
    if isinstance(detail, dict):
        first = next(iter(detail.values()), "Request failed")
        return _message_for(first)
    if isinstance(detail, list) and detail:
        return _message_for(detail[0])
    return "Request failed"
