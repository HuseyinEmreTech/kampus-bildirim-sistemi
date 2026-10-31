import pytest

from app.settings import Settings


VALID_ENVIRONMENT = {
    "CORE_API_BASE_URL": "http://core.test",
    "CORE_API_TIMEOUT_SECONDS": "3.5",
    "CORE_API_PAGE_SIZE": "50",
    "SERVICE_HOST": "127.0.0.1",
    "SERVICE_PORT": "8001",
    "SERVICE_HEALTHCHECK_HOST": "localhost",
    "SERVICE_HEALTHCHECK_TIMEOUT_SECONDS": "2",
    "REPORT_EXPORT_FILENAME": "export.csv",
}


def test_settings_read_runtime_values_from_environment():
    settings = Settings.from_environment(VALID_ENVIRONMENT)

    assert settings.core_api_base_url == "http://core.test"
    assert settings.core_api_timeout_seconds == 3.5
    assert settings.core_api_page_size == 50
    assert settings.service_host == "127.0.0.1"
    assert settings.service_port == 8001
    assert settings.service_healthcheck_host == "localhost"
    assert settings.service_healthcheck_timeout_seconds == 2
    assert settings.report_export_filename == "export.csv"


def test_settings_reject_missing_environment_values():
    with pytest.raises(ValueError, match="CORE_API_BASE_URL"):
        Settings.from_environment({})


@pytest.mark.parametrize(
    ("key", "value"),
    [
        ("CORE_API_BASE_URL", "not-a-url"),
        ("CORE_API_TIMEOUT_SECONDS", "zero"),
        ("CORE_API_TIMEOUT_SECONDS", "0"),
        ("CORE_API_PAGE_SIZE", "101"),
        ("CORE_API_PAGE_SIZE", "0"),
        ("SERVICE_HOST", " "),
        ("SERVICE_PORT", "70000"),
        ("SERVICE_HEALTHCHECK_HOST", " "),
        ("SERVICE_HEALTHCHECK_TIMEOUT_SECONDS", "inf"),
        ("REPORT_EXPORT_FILENAME", "../reports.csv"),
        ("REPORT_EXPORT_FILENAME", "report\r\n.csv"),
        ("CORE_API_TIMEOUT_SECONDS", "nan"),
    ],
)
def test_settings_reject_invalid_environment_values(key, value):
    environment = {**VALID_ENVIRONMENT, key: value}

    with pytest.raises(ValueError):
        Settings.from_environment(environment)
