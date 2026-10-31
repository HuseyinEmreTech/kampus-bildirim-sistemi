"""Demo verisini (db/seed/001_ornek.sql) çalışan veritabanına yükler.

Kullanım (proje klasöründen):
    python test/veri/seed_yukle.py

Gerçek veri yoktur; tüm hesapların parolası herkese açık demo parolasıdır.
"""
import subprocess
import sys
from pathlib import Path

KOK = Path(__file__).resolve().parents[2]
SEED = KOK / "db" / "seed" / "001_ornek.sql"
KOMUT = [
    "docker", "compose", "-f", "compose.prod.yaml",
    "exec", "-T", "db", "psql", "-U", "campus", "-d", "campus",
]


def main() -> int:
    if not SEED.exists():
        print(f"Seed dosyası bulunamadı: {SEED}")
        return 1
    with SEED.open("rb") as dosya:
        sonuc = subprocess.run(
            KOMUT, stdin=dosya, cwd=KOK, capture_output=True, text=True
        )
    print(sonuc.stdout)
    if "duplicate key" in sonuc.stderr:
        print("Seed zaten yüklü, değişiklik yapılmadı. Sorun yok.")
        return 0
    if sonuc.returncode != 0 or "ERROR" in sonuc.stderr:
        print(sonuc.stderr)
        print("Seed yüklenemedi.")
        return 1
    print("Seed yüklendi.")
    return 0


if __name__ == "__main__":
    sys.exit(main())