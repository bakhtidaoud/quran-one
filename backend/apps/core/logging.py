import json
import logging
from typing import Any

# Field names that must never reach a log line, an error tracker or an
# analytics event. Religious practice is the most sensitive category of data
# this product holds and it is redacted at the boundary rather than trusted
# to reviewer discipline.
REDACTED_KEYS = frozenset(
    {
        "password",
        "token",
        "refresh",
        "access",
        "authorization",
        "latitude",
        "longitude",
        "email",
        "note",
        "query",
    }
)


class JSONFormatter(logging.Formatter):
    def format(self, record: logging.LogRecord) -> str:
        payload: dict[str, Any] = {
            "level": record.levelname,
            "logger": record.name,
            "message": record.getMessage(),
            "time": self.formatTime(record, "%Y-%m-%dT%H:%M:%S%z"),
        }

        request_id = getattr(record, "request_id", None)
        if request_id:
            payload["trace_id"] = request_id

        extra = getattr(record, "context", None)
        if isinstance(extra, dict):
            payload["context"] = {
                k: ("[redacted]" if k.lower() in REDACTED_KEYS else v)
                for k, v in extra.items()
            }

        if record.exc_info:
            payload["exception"] = self.formatException(record.exc_info)

        return json.dumps(payload, default=str)
