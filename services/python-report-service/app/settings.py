import math
import os
import re
from collections.abc import Mapping
from dataclasses import dataclass
from urllib.parse import urlsplit

CORE_API_MAX_PAGE_SIZE = 100
EXPORT_FILENAME_PATTERN = re.compile(r"[A-Za-z0-9][A-Za-z0-9._-]*")


@dataclass(frozen=True)
class Settings:
    core_api_base_url: str
    core_api_timeout_seconds: float
    core_api_page_size: int
    service_host: str
    service_port: int
    service_healthcheck_host: str
    service_healthcheck_timeout_seconds: float
    report_export_filename: str

    @classmethod
    def from_environment(
        cls,
        environment: Mapping[str, str] | None = None,
    ) -> "Settings":
        values = os.environ if environment is None else environment
        required = (
            "CORE_API_BASE_URL",
            "CORE_API_TIMEOUT_SECONDS",
            "CORE_API_PAGE_SIZE",
            "SERVICE_HOST",
            "SERVICE_PORT",
            "SERVICE_HEALTHCHECK_HOST",
            "SERVICE_HEALTHCHECK_TIMEOUT_SECONDS",
            "REPORT_EXPORT_FILENAME",
        )
        missing = [key for key in required if not values.get(key, "").strip()]
        if missing:
            raise ValueError(f"Missing required environment variables: {', '.join(missing)}")

        base_url = values["CORE_API_BASE_URL"].rstrip("/")
        parsed_url = urlsplit(base_url)
        if parsed_url.scheme not in {"http", "https"} or not parsed_url.netloc:
            raise ValueError("CORE_API_BASE_URL must be an absolute HTTP(S) URL.")

        try:
            timeout = float(values["CORE_API_TIMEOUT_SECONDS"])
            page_size = int(values["CORE_API_PAGE_SIZE"])
            port = int(values["SERVICE_PORT"])
            healthcheck_timeout = float(
                values["SERVICE_HEALTHCHECK_TIMEOUT_SECONDS"],
            )
        except ValueError as error:
            raise ValueError("Timeout, page size, and port must be numeric.") from error

        if not math.isfinite(timeout) or timeout <= 0:
            raise ValueError("CORE_API_TIMEOUT_SECONDS must be greater than zero.")
        if not 1 <= page_size <= CORE_API_MAX_PAGE_SIZE:
            raise ValueError(
                f"CORE_API_PAGE_SIZE must be between 1 and {CORE_API_MAX_PAGE_SIZE}."
            )
        if not 1 <= port <= 65535:
            raise ValueError("SERVICE_PORT must be between 1 and 65535.")
        if not math.isfinite(healthcheck_timeout) or healthcheck_timeout <= 0:
            raise ValueError(
                "SERVICE_HEALTHCHECK_TIMEOUT_SECONDS must be greater than zero.",
            )

        host = values["SERVICE_HOST"].strip()
        healthcheck_host = values["SERVICE_HEALTHCHECK_HOST"].strip()
        filename = values["REPORT_EXPORT_FILENAME"].strip()
        if not host:
            raise ValueError("SERVICE_HOST must not be empty.")
        if not healthcheck_host:
            raise ValueError("SERVICE_HEALTHCHECK_HOST must not be empty.")
        if not EXPORT_FILENAME_PATTERN.fullmatch(filename):
            raise ValueError("REPORT_EXPORT_FILENAME must be a file name, not a path.")

        return cls(
            core_api_base_url=base_url,
            core_api_timeout_seconds=timeout,
            core_api_page_size=page_size,
            service_host=host,
            service_port=port,
            service_healthcheck_host=healthcheck_host,
            service_healthcheck_timeout_seconds=healthcheck_timeout,
            report_export_filename=filename,
        )


def get_settings() -> Settings:
    return Settings.from_environment()
