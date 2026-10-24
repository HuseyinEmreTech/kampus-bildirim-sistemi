import uvicorn

from app.main import app
from app.settings import get_settings

settings = get_settings()
uvicorn.run(
    app,
    host=settings.service_host,
    port=settings.service_port,
)
