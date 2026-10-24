from urllib.request import urlopen

from app.settings import get_settings

settings = get_settings()
with urlopen(
    (
        f"http://{settings.service_healthcheck_host}:"
        f"{settings.service_port}/health"
    ),
    timeout=settings.service_healthcheck_timeout_seconds,
):
    pass
