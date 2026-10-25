import socket

from app.settings import Settings, get_settings


def check_health(settings: Settings) -> None:
    with socket.create_connection(
        (settings.service_healthcheck_host, settings.service_port),
        timeout=settings.service_healthcheck_timeout_seconds,
    ):
        return


if __name__ == "__main__":
    check_health(get_settings())
