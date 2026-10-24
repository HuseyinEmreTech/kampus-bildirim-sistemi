import csv
import io

import httpx
import pytest
from fastapi.testclient import TestClient

from app.main import app, get_core_client
from app.settings import Settings, get_settings

TEST_SETTINGS = Settings(
    core_api_base_url="http://core.test",
    core_api_timeout_seconds=2,
    core_api_page_size=50,
    service_host="127.0.0.1",
    service_port=8001,
    service_healthcheck_host="localhost",
    service_healthcheck_timeout_seconds=2,
    report_export_filename="export.csv",
)


@pytest.fixture(autouse=True)
def override_settings():
    app.dependency_overrides[get_settings] = lambda: TEST_SETTINGS
    yield
    app.dependency_overrides.clear()


def make_core_client(handler):
    transport = httpx.MockTransport(handler)
    return httpx.AsyncClient(
        base_url="http://core.test",
        transport=transport,
    )


def test_health_reports_service_status():
    with TestClient(app) as client:
        response = client.get("/health")

    assert response.status_code == 200
    assert response.json() == {"status": "ok"}


def test_export_requires_bearer_token():
    with TestClient(app) as client:
        response = client.get("/api/reports/export")

    assert response.status_code == 401


def test_export_rejects_unknown_status_and_category():
    with TestClient(app) as client:
        status_response = client.get(
            "/api/reports/export",
            params={"status": "Unknown"},
            headers={"Authorization": "Bearer staff-token"},
        )
        category_response = client.get(
            "/api/reports/export",
            params={"category": "Unknown"},
            headers={"Authorization": "Bearer staff-token"},
        )

    assert status_response.status_code == 422
    assert category_response.status_code == 422


def test_export_forwards_token_filters_and_returns_csv():
    requests = []

    def handler(request):
        requests.append(request)
        return httpx.Response(
            200,
            json={
                "items": [
                    {
                        "reportId": "report-1",
                        "category": "Ariza",
                        "description": "Lamba bozuk",
                        "status": "Yeni",
                        "createdAt": "2026-10-24T10:00:00Z",
                        "location": {"place": "B Blok"},
                    }
                ],
                "total": 1,
                "page": 1,
                "pageSize": 100,
            },
        )

    async def override_core_client():
        async with make_core_client(handler) as core_client:
            yield core_client

    app.dependency_overrides[get_core_client] = override_core_client
    try:
        with TestClient(app) as client:
            response = client.get(
                "/api/reports/export",
                params={"status": "Yeni", "category": "Ariza"},
                headers={"Authorization": "Bearer staff-token"},
            )
    finally:
        app.dependency_overrides.clear()

    assert response.status_code == 200
    assert response.headers["content-type"].startswith("text/csv")
    assert response.headers["content-disposition"] == (
        'attachment; filename="export.csv"'
    )
    assert requests[0].headers["authorization"] == "Bearer staff-token"
    assert dict(requests[0].url.params) == {
        "page": "1",
        "pageSize": "50",
        "status": "Yeni",
        "category": "Ariza",
    }
    rows = list(csv.DictReader(io.StringIO(response.text)))
    assert rows == [
        {
            "reportId": "report-1",
            "category": "Ariza",
            "description": "Lamba bozuk",
            "status": "Yeni",
            "createdAt": "2026-10-24T10:00:00Z",
            "place": "B Blok",
        }
    ]


def test_export_fetches_all_pages():
    requested_pages = []

    def handler(request):
        page = int(request.url.params["page"])
        requested_pages.append(page)
        items = [
            {
                "reportId": f"report-{page}",
                "category": "Ariza",
                "description": "Lamba bozuk",
                "status": "Yeni",
                "createdAt": "2026-10-24T10:00:00Z",
                "location": {"place": None},
            }
        ] if page <= 2 else []
        return httpx.Response(200, json={"items": items, "total": 2})

    async def override_core_client():
        async with make_core_client(handler) as core_client:
            yield core_client

    app.dependency_overrides[get_core_client] = override_core_client
    try:
        with TestClient(app) as client:
            response = client.get(
                "/api/reports/export",
                headers={"Authorization": "Bearer staff-token"},
            )
    finally:
        app.dependency_overrides.clear()

    assert response.status_code == 200
    assert requested_pages == [1, 2]
    assert len(list(csv.DictReader(io.StringIO(response.text)))) == 2


def test_export_escapes_spreadsheet_formulas():
    def handler(request):
        return httpx.Response(
            200,
            json={
                "items": [
                    {
                        "reportId": "report-1",
                        "category": "Ariza",
                        "description": "=1+1",
                        "status": "Yeni",
                        "createdAt": "2026-10-24T10:00:00Z",
                        "location": {"place": " @SUM(A1:A2)"},
                    }
                ],
                "total": 1,
            },
        )

    async def override_core_client():
        async with make_core_client(handler) as core_client:
            yield core_client

    app.dependency_overrides[get_core_client] = override_core_client
    try:
        with TestClient(app) as client:
            response = client.get(
                "/api/reports/export",
                headers={"Authorization": "Bearer staff-token"},
            )
    finally:
        app.dependency_overrides.clear()

    rows = list(csv.DictReader(io.StringIO(response.text)))
    assert rows[0]["description"] == "'=1+1"
    assert rows[0]["place"] == "' @SUM(A1:A2)"


def test_export_maps_core_auth_rejection():
    def handler(request):
        return httpx.Response(403)

    async def override_core_client():
        async with make_core_client(handler) as core_client:
            yield core_client

    app.dependency_overrides[get_core_client] = override_core_client
    try:
        with TestClient(app) as client:
            response = client.get(
                "/api/reports/export",
                headers={"Authorization": "Bearer invalid-token"},
            )
    finally:
        app.dependency_overrides.clear()

    assert response.status_code == 403


def test_export_returns_bad_gateway_for_invalid_core_response():
    def handler(request):
        return httpx.Response(200, json={"unexpected": []})

    async def override_core_client():
        async with make_core_client(handler) as core_client:
            yield core_client

    app.dependency_overrides[get_core_client] = override_core_client
    try:
        with TestClient(app) as client:
            response = client.get(
                "/api/reports/export",
                headers={"Authorization": "Bearer staff-token"},
            )
    finally:
        app.dependency_overrides.clear()

    assert response.status_code == 502


def test_export_returns_bad_gateway_for_invalid_report_record():
    def handler(request):
        return httpx.Response(
            200,
            json={"items": [{"reportId": "incomplete"}], "total": 1},
        )

    async def override_core_client():
        async with make_core_client(handler) as core_client:
            yield core_client

    app.dependency_overrides[get_core_client] = override_core_client
    try:
        with TestClient(app) as client:
            response = client.get(
                "/api/reports/export",
                headers={"Authorization": "Bearer staff-token"},
            )
    finally:
        app.dependency_overrides.clear()

    assert response.status_code == 502
