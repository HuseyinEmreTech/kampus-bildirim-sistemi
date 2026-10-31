# Python rapor dışa aktarma servisi

Bu FastAPI servisi raporları kendi veritabanında tutmaz ve çekirdek API'ye yazma
isteği göndermez. Görevli erişim belirtecini çekirdek API'ye iletir; servis
`GET /api/reports` yanıtındaki sayfaları alıp CSV olarak döndürür. Yetki denetimi
çekirdek API'de yapılır. Bildirim ve durum geçmişi yazımı Dart çekirdeğinin
transaction'ında kalır.

## Sözleşme

### `GET /health`

Servis sağlık kontrolü:

```json
{"status": "ok"}
```

### `GET /api/reports/export`

`Authorization: Bearer <access-token>` başlığı zorunludur. Belirteç görevli
belirteci olmalıdır; rol ve erişim doğrulamasını çekirdek API yapar.

| Sorgu parametresi | Gerekli | Değer |
| --- | --- | --- |
| `status` | Hayır | `Yeni`, `Ustlenildi`, `Cozuldu` |
| `category` | Hayır | `Ariza`, `Temizlik`, `Guvenlik`, `Diger` |
| `assignee` | Hayır | Çekirdek API'nin rapor listesi filtresi |

Servis filtreleri çekirdek API'ye iletir ve yapılandırılmış sayfa boyutuyla
(çekirdek API'nin kabul ettiği üst sınır 100) tüm sayfaları alır. CSV UTF-8
biçimindedir; sütunlar `reportId`, `category`, `description`,
`status`, `createdAt`, `place` sırasındadır. Kullanıcı girdilerindeki e-tablo
formülleri CSV dışa aktarımında etkisizleştirilir.

| Durum | Anlam |
| --- | --- |
| `200` | CSV dosyası (`REPORT_EXPORT_FILENAME` ile yapılandırılır) |
| `401` | Bearer erişim belirteci yok/geçersiz veya çekirdek API isteği reddetti |
| `400` / `403` / `404` | Çekirdek API isteği reddetti |
| `422` | Filtre değerleri geçersiz |
| `502` | Çekirdek API erişilemiyor veya sözleşmeye uymayan yanıt döndürdü |

## Yapılandırma

Servis çalışma ayarlarını yalnızca ortam değişkenlerinden alır; eksik veya
geçersiz değer varsa başlamaz. Varsayılan değer kullanılmaz.

| Değişken | Açıklama |
| --- | --- |
| `CORE_API_BASE_URL` | Çekirdek API'nin mutlak HTTP(S) adresi |
| `CORE_API_TIMEOUT_SECONDS` | Çekirdek API isteği zaman aşımı |
| `CORE_API_PAGE_SIZE` | Çekirdek API'den istenecek sayfa boyutu (1-100) |
| `SERVICE_HOST` | Uvicorn'un dinleyeceği adres |
| `SERVICE_PORT` | Servis portu (1-65535) |
| `SERVICE_HEALTHCHECK_HOST` | Docker health check'in TCP bağlantısı kuracağı host |
| `SERVICE_HEALTHCHECK_TIMEOUT_SECONDS` | Health check TCP bağlantısı zaman aşımı |
| `REPORT_EXPORT_FILENAME` | CSV indirme dosya adı (yol değil) |

## Yerel çalıştırma

Python 3.12 ve `pip` gereklidir. Ayarları PowerShell oturumunda belirleyin:

```powershell
cd services\python-report-service
$env:CORE_API_BASE_URL = "http://localhost:8080"
$env:CORE_API_TIMEOUT_SECONDS = "10"
$env:CORE_API_PAGE_SIZE = "100"
$env:SERVICE_HOST = "127.0.0.1"
$env:SERVICE_PORT = "8001"
$env:SERVICE_HEALTHCHECK_HOST = "127.0.0.1"
$env:SERVICE_HEALTHCHECK_TIMEOUT_SECONDS = "2"
$env:REPORT_EXPORT_FILENAME = "reports.csv"
python -m venv .venv
.\.venv\Scripts\Activate.ps1
python -m pip install -r requirements-dev.txt
python -m app
```

Docker health check, `SERVICE_HEALTHCHECK_HOST` ve `SERVICE_PORT` ayarlarına
TCP bağlantısı kurarak servis portunun dinlediğini kontrol eder; HTTP isteği
göndermez. Ayrı `/health` endpoint'i uygulama seviyesinde kontrol için
kullanılabilir. `SERVICE_HOST` dinleme adresidir; Docker'da çoğunlukla
`0.0.0.0` olacağı için health check hedefinden ayrı yapılandırılır. CSV
indirmek için çekirdek API'den alınmış görevli access token'ını iletin:

```powershell
curl.exe -H "Authorization: Bearer <access-token>" `
  "http://localhost:8001/api/reports/export?status=Yeni"
```

Testleri çalıştırma:

```powershell
python -m pytest -q
```

## Docker

Servisi kendi klasörü build context olacak şekilde oluşturun. `docker run` için
yukarıdaki tüm ayarları `--env` ile sağlayın. Örnek:

```powershell
docker build -t campus-python-report-service .
docker run --rm -p 8001:8001 `
  -e CORE_API_BASE_URL=http://host.docker.internal:8080 `
  -e CORE_API_TIMEOUT_SECONDS=10 `
  -e CORE_API_PAGE_SIZE=100 `
  -e SERVICE_HOST=0.0.0.0 `
  -e SERVICE_PORT=8001 `
  -e SERVICE_HEALTHCHECK_HOST=127.0.0.1 `
  -e SERVICE_HEALTHCHECK_TIMEOUT_SECONDS=2 `
  -e REPORT_EXPORT_FILENAME=reports.csv `
  campus-python-report-service
```

Konteyner içindeki health check, yapılandırılmış host ve portta TCP bağlantısı
kurar. Docker ağı çekirdek API'ye erişemiyorsa `CORE_API_BASE_URL` değerini o
ağda erişilebilir çekirdek API adresine göre ayarlayın. Host port eşlemesinde
sağdaki port, `SERVICE_PORT` ile aynı olmalıdır.
