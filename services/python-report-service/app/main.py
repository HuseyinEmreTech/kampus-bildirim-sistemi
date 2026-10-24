import csv
import io
from collections.abc import AsyncIterator
from typing import Annotated, Any

import httpx
from fastapi import Depends, FastAPI, Header, HTTPException, Query
from fastapi.responses import Response

from app.contracts import ReportCategory, ReportStatus
from app.settings import Settings, get_settings

CSV_FIELDS = ("reportId", "category", "description", "status", "createdAt", "place")
SPREADSHEET_FORMULA_PREFIXES = ("=", "+", "-", "@")

app = FastAPI(title="Campus Report Python Service")


async def get_core_client(
    settings: Settings = Depends(get_settings),
) -> AsyncIterator[httpx.AsyncClient]:
    async with httpx.AsyncClient(
        base_url=settings.core_api_base_url,
        timeout=settings.core_api_timeout_seconds,
    ) as client:
        yield client


def _require_bearer_token(authorization: str | None) -> str:
    parts = authorization.split() if authorization else []
    if len(parts) != 2 or parts[0].lower() != "bearer":
        raise HTTPException(
            status_code=401,
            detail="Bearer access token is required.",
        )
    return authorization


def _core_payload_items(payload: Any) -> tuple[list[dict[str, Any]], int]:
    if not isinstance(payload, dict):
        raise HTTPException(status_code=502, detail="Core API returned an invalid response.")

    items = payload.get("items")
    total = payload.get("total")
    if (
        not isinstance(items, list)
        or not isinstance(total, int)
        or isinstance(total, bool)
        or total < 0
        or any(not isinstance(item, dict) for item in items)
    ):
        raise HTTPException(status_code=502, detail="Core API returned an invalid response.")

    return items, total


async def _fetch_reports(
    core_client: httpx.AsyncClient,
    page_size: int,
    authorization: str,
    status: ReportStatus | None,
    category: ReportCategory | None,
    assignee: str | None,
) -> list[dict[str, Any]]:
    reports: list[dict[str, Any]] = []
    page = 1

    while True:
        params: dict[str, str | int] = {"page": page, "pageSize": page_size}
        if status is not None:
            params["status"] = status.value
        if category is not None:
            params["category"] = category.value
        if assignee is not None:
            params["assignee"] = assignee

        try:
            upstream = await core_client.get(
                "/api/reports",
                params=params,
                headers={"Authorization": authorization},
            )
        except httpx.RequestError as error:
            raise HTTPException(
                status_code=502,
                detail="Core API is unavailable.",
            ) from error

        if 400 <= upstream.status_code < 500:
            raise HTTPException(
                status_code=upstream.status_code,
                detail="Core API rejected the request.",
            )
        if upstream.status_code < 200 or upstream.status_code >= 300:
            raise HTTPException(status_code=502, detail="Core API request failed.")

        try:
            items, total = _core_payload_items(upstream.json())
        except ValueError as error:
            raise HTTPException(
                status_code=502,
                detail="Core API returned an invalid response.",
            ) from error

        reports.extend(items)
        if len(reports) >= total:
            return reports[:total]
        if not items:
            raise HTTPException(
                status_code=502,
                detail="Core API returned incomplete pagination data.",
            )
        page += 1


def _spreadsheet_safe(value: Any) -> str:
    text = "" if value is None else str(value)
    if text.lstrip().startswith(SPREADSHEET_FORMULA_PREFIXES):
        return f"'{text}"
    return text


def _report_csv(reports: list[dict[str, Any]]) -> str:
    output = io.StringIO(newline="")
    writer = csv.DictWriter(output, fieldnames=CSV_FIELDS)
    writer.writeheader()

    for report in reports:
        required_fields = CSV_FIELDS[:-1]
        if any(
            not isinstance(report.get(field), str)
            for field in required_fields
        ):
            raise HTTPException(status_code=502, detail="Core API returned an invalid report.")

        location = report.get("location")
        if not isinstance(location, dict):
            raise HTTPException(status_code=502, detail="Core API returned an invalid report.")
        place = location.get("place")
        if place is not None and not isinstance(place, str):
            raise HTTPException(status_code=502, detail="Core API returned an invalid report.")

        row = {
            "reportId": report.get("reportId"),
            "category": report.get("category"),
            "description": report.get("description"),
            "status": report.get("status"),
            "createdAt": report.get("createdAt"),
            "place": place,
        }
        writer.writerow({key: _spreadsheet_safe(value) for key, value in row.items()})

    return output.getvalue()


@app.get("/health")
async def health() -> dict[str, str]:
    return {"status": "ok"}


@app.get("/api/reports/export")
async def export_reports(
    status: Annotated[
        ReportStatus | None,
        Query(description="Rapor durumu filtresi."),
    ] = None,
    category: Annotated[
        ReportCategory | None,
        Query(description="Rapor kategorisi filtresi."),
    ] = None,
    assignee: str | None = Query(default=None),
    authorization: str | None = Header(default=None),
    core_client: httpx.AsyncClient = Depends(get_core_client),
    settings: Settings = Depends(get_settings),
) -> Response:
    token = _require_bearer_token(authorization)
    reports = await _fetch_reports(
        core_client,
        settings.core_api_page_size,
        token,
        status,
        category,
        assignee,
    )
    return Response(
        content=_report_csv(reports),
        media_type="text/csv",
        headers={
            "Content-Disposition": (
                f'attachment; filename="{settings.report_export_filename}"'
            )
        },
    )
