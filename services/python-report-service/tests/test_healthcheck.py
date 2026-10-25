import socket
from unittest.mock import MagicMock, Mock

import pytest

from app.healthcheck import check_health
from app.settings import Settings

TEST_SETTINGS = Settings(
    core_api_base_url="http://core.test",
    core_api_timeout_seconds=2,
    core_api_page_size=50,
    service_host="127.0.0.1",
    service_port=8001,
    service_healthcheck_host="localhost",
    service_healthcheck_timeout_seconds=1.5,
    report_export_filename="reports.csv",
)


def test_healthcheck_opens_configured_tcp_connection(monkeypatch):
    connection = MagicMock()
    create_connection = Mock(return_value=connection)
    monkeypatch.setattr(socket, "create_connection", create_connection)

    check_health(TEST_SETTINGS)

    create_connection.assert_called_once_with(
        ("localhost", 8001),
        timeout=1.5,
    )
    connection.__exit__.assert_called_once()


def test_healthcheck_fails_when_service_port_is_unavailable(monkeypatch):
    create_connection = Mock(side_effect=ConnectionRefusedError)
    monkeypatch.setattr(socket, "create_connection", create_connection)

    with pytest.raises(ConnectionRefusedError):
        check_health(TEST_SETTINGS)
