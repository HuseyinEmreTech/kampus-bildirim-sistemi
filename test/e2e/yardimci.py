import base64

import requests

BASE_URL = "http://localhost:8080"
PAROLA = "Demo.1234"

# 1x1 piksellik geçerli PNG (sahte test fotoğrafı)
_PNG_BASE64 = (
    "iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR4nGP4z8DwHwAFAAH/"
    "iZk9HQAAAABJRU5ErkJggg=="
)
SAHTE_PNG = base64.b64decode(_PNG_BASE64)


def giris_yap(email: str, parola: str = PAROLA) -> dict:
    yanit = requests.post(
        f"{BASE_URL}/api/auth/login",
        json={"email": email, "password": parola},
        timeout=10,
    )
    assert yanit.status_code == 200, yanit.text
    return yanit.json()


def yetki_basligi(giris: dict) -> dict:
    return {"Authorization": f"Bearer {giris['accessToken']}"}


def bildirim_ac(ogrenci_giris: dict, aciklama: str) -> dict:
    yanit = requests.post(
        f"{BASE_URL}/api/reports",
        headers=yetki_basligi(ogrenci_giris),
        data={
            "category": "Ariza",
            "description": aciklama,
            "locationSource": "Gps",
            "latitude": "36.5871",
            "longitude": "36.1742",
            "place": "B Blok 2. kat",
        },
        files={"photo": ("test.png", SAHTE_PNG, "image/png")},
        timeout=15,
    )
    assert yanit.status_code == 201, yanit.text
    return yanit.json()