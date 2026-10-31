# Rapor İstatistik Servisi (C#)

Issue #92, [ADR-04](../../proje-bilgileri/adr/04-cok-dilli-web-ve-servisler.md). Bildirimler hakkında **okuma ağırlıklı** istatistik veren küçük bir .NET 10 servisi. Çekirdek (Dart) çalışmaya devam eder; bu servis kapatılırsa ürün etkilenmez.

## Sınırlar

- Çekirdeğin PostgreSQL veritabanını **yalnızca okur**: bağlantı `default_transaction_read_only=on` ile açılır, yazma sorgusu reddedilir.
- Giriş Dart çekirdeğinde kalır. Bu servis, çekirdeğin ürettiği **erişim belirtecini** aynı sırla (`JWT_ACCESS_SECRET`, HS256, `iss=campus-report`) doğrular; yeni giriş adresi yoktur.
- Kişisel veri dönmez: yalnızca sayılar.

## Uçlar

| Uç | Rol | Yanıt |
| --- | --- | --- |
| `GET /health` | Herkes | `200 { "status": "ok" }` |
| `GET /api/stats/summary` | Görevli (`Staff`) | `200 { "total", "byStatus": { "Yeni", "Ustlenildi", "Cozuldu" }, "byCategory": { "Ariza", "Temizlik", "Guvenlik", "Diger" }, "averageResolutionHours" }` |

- Her durum ve kategori, bildirim olmasa da `0` ile döner.
- `averageResolutionHours`: çözülen bildirimlerin oluşturulmadan çözülmeye ortalama süresi (saat, 1 ondalık); çözülen yoksa `null`.
- Hata biçimi çekirdekle aynı: belirteç yok/geçersiz `401 UNAUTHORIZED`, öğrenci `403 FORBIDDEN`; gövde `{ "error": { "code", "message", "details" } }`.

## Çalıştırma

Gerekenler: .NET SDK 10 ve çalışan çekirdek veritabanı (`docker compose up -d`).

```powershell
cd services/rapor-istatistik
$env:DATABASE_URL = "postgres://<kullanici>:<parola>@localhost:5432/campus?sslmode=disable"
$env:JWT_ACCESS_SECRET = "<.env'deki JWT_ACCESS_SECRET>"
dotnet run --project src/RaporIstatistik
```

Testler (veritabanı gerekmez):

```powershell
dotnet test
```

Docker:

```powershell
docker build -t rapor-istatistik services/rapor-istatistik
docker run --rm -p 8090:8080 -e DATABASE_URL=... -e JWT_ACCESS_SECRET=... rapor-istatistik
```

## Ortam değişkenleri

| Ad | Açıklama |
| --- | --- |
| `DATABASE_URL` | Çekirdekle aynı biçim; salt okunur kullanılır |
| `JWT_ACCESS_SECRET` | Çekirdekle aynı erişim belirteci sırrı, en az 32 karakter |

## Sonra

- `GET /api/stats/export.csv`: bildirimlerin kişisel veri içermeyen CSV dışa aktarımı.
- CI işi ve `compose.yaml`'a ekleme: entegrasyon sahibi Hüseyin (ADR-04).
