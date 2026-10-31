"""E2E testlerinin ortak kurulumu.

Sunucu çalışmıyorsa testler bağlantı hatasıyla düşmesin: sunucunun açık olup
olmadığı bir kez kontrol edilir, kapalıysa testler nedeniyle birlikte atlanır.
Bu, `python -m pytest test/e2e` komutunun sunucu yokken de yeşil (skip) ve
anlaşılır çıkmasını sağlar.

Sunucu adresi `E2E_BASE_URL` ile değiştirilebilir (varsayılan
`http://localhost:8080`).
"""

import os
import socket
from urllib.parse import urlparse

import pytest

BASE_URL = os.environ.get("E2E_BASE_URL", "http://localhost:8080")

_TIMEOUT_SECONDS = 0.5


def _server_is_up() -> bool:
    parsed = urlparse(BASE_URL)
    host = parsed.hostname or "localhost"
    port = parsed.port or 80
    try:
        with socket.create_connection((host, port), timeout=_TIMEOUT_SECONDS):
            return True
    except OSError:
        return False


def pytest_collection_modifyitems(config, items):
    if _server_is_up():
        return
    skip = pytest.mark.skip(reason=f"E2E sunucusu çalışmıyor: {BASE_URL}")
    for item in items:
        item.add_marker(skip)
