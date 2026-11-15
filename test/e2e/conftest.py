"""Sunucunun erişilebilirliğini kontrol eder; CI'da sunucu zorunludur."""

import os
import socket
from urllib.parse import urlparse

import pytest

BASE_URL = os.environ.get("E2E_BASE_URL", "http://localhost:8080")

_TIMEOUT_SECONDS = 0.5


def _server_is_up() -> bool:
    parsed = urlparse(BASE_URL)
    host = parsed.hostname or "localhost"
    port = parsed.port or (443 if parsed.scheme == "https" else 80)
    try:
        with socket.create_connection((host, port), timeout=_TIMEOUT_SECONDS):
            return True
    except OSError:
        return False


def pytest_collection_modifyitems(config, items):
    if _server_is_up():
        return
    neden = f"E2E sunucusu çalışmıyor: {BASE_URL}"
    if os.environ.get("E2E_ZORUNLU") == "1":
        pytest.exit(neden, returncode=1)
    skip = pytest.mark.skip(reason=neden)
    for item in items:
        item.add_marker(skip)
