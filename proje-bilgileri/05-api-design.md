---
title: API Tasarımı
durum: Taslak
son-guncelleme: 2026-10-17
---

# API Tasarımı

← [İndeks](00-index.md)

Standartlar: [Mimari genel bakış](02-architecture-overview.md). Modeller: [Domain tasarımı](03-domain-design.md).

## Endpoint'ler

| Endpoint | Metot | Rol | Açıklama |
| --- | --- | --- | --- |
| `/api/auth/login` | POST | Herkes | Giriş yapar; erişim ve yenileme belirteci döner |
| `/api/auth/refresh` | POST | Herkes | Yenileme belirteciyle yeni belirteç çifti alır; eski belirteç iptal olur |
| `/api/reports` | POST | Öğrenci | Yeni bildirim (fotoğraf, konum, kategori, açıklama) |
| `/api/reports` | GET | Görevli | Sayfalı liste; `status`, `category`, `assignee`, `page`, `pageSize` |
| `/api/me/reports` | GET | Öğrenci | Kendi bildirimleri, sayfalı |
| `/api/reports/{id}` | GET | İlgili öğrenci veya görevli | Detay ve durum geçmişi |
| `/api/reports/{id}/assignment` | PUT | Görevli | "İlgileniyorum" (üstlen) |
| `/api/reports/{id}/resolution` | PUT | Üstlenen görevli | Çözüldü işaretle |
| `/api/me/notifications` | GET | Öğrenci | "Çözüldü" bildirimleri; sayfalı, okunmamış sayısıyla |
| `/api/me/notifications/{id}/read` | PUT | Öğrenci | Okundu işaretle |
| `/api/buildings` | GET | Giriş yapmış herkes | Bina listesi (konum izni yokken seçim için) |
| `/health` | GET | Herkes | Sağlık kontrolü |

## Parametreler

| Parametre | Endpoint | Zorunlu | Açıklama |
| --- | --- | --- | --- |
| `status` | `GET /api/reports` | Hayır | `Yeni`, `Ustlenildi`, `Cozuldu` |
| `category` | `GET /api/reports` | Hayır | `Ariza`, `Temizlik`, `Guvenlik`, `Diger` |
| `assignee` | `GET /api/reports` | Hayır | `me` ise yalnızca isteği yapan görevlinin üstlendikleri |
| `page` | Listeler | Hayır | 1'den başlar, varsayılan 1 |
| `pageSize` | Listeler | Hayır | Varsayılan 20, en fazla 100 |

## Hata biçimi ve durum kodları

```json
{ "error": { "code": "VALIDATION_ERROR", "message": "Açıklama en az 5 karakter olmalı.", "details": "description" } }
```

| Durum | Kod | Ne zaman |
| --- | --- | --- |
| 400 | `VALIDATION_ERROR` | Geçersiz istek |
| 401 | `UNAUTHORIZED` | Giriş yok, erişim ya da yenileme belirteci geçersiz/süresi dolmuş |
| 401 | `INVALID_CREDENTIALS` | E-posta veya parola hatalı (hangisi olduğu söylenmez) |
| 403 | `FORBIDDEN` | Rol yetkisi yok |
| 404 | `NOT_FOUND` | Kayıt yok |
| 409 | `CONFLICT` | Bildirim zaten üstlenilmiş |
| 422 | `OUTSIDE_CAMPUS` | Konum kampüs dışında (öneri) |
| 429 | `RATE_LIMITED` | İstek sınırı aşıldı: IP başına dakikada 100 istek, girişte dakikada 5 deneme. `Retry-After` başlığı kaç saniye bekleneceğini söyler |

## Örnekler

### Giriş

```bash
curl -X POST "http://localhost:8080/api/auth/login" \
  -H "Content-Type: application/json" \
  -d '{"email":"ayse@ornek.edu","password":"<parola>"}'
```

```json
{ "accessToken": "<erisim-belirteci>", "refreshToken": "<yenileme-belirteci>", "user": { "userId": "5c98741b-64c8-49de-9e68-3d7a2f44802b", "fullName": "Ayşe Yılmaz", "role": "Student" } }
```

Erişim belirteci 15 dakika, yenileme belirteci 7 gün geçerlidir (HS256 JWT). Korumalı isteklerde `Authorization: Bearer <erisim-belirteci>` gönderilir.

### Belirteç yenileme

```bash
curl -X POST "http://localhost:8080/api/auth/refresh" \
  -H "Content-Type: application/json" \
  -d '{"refreshToken":"<yenileme-belirteci>"}'
```

Yanıt girişle aynı biçimdedir. Kullanılan yenileme belirteci iptal edilir; aynı belirteç ikinci kez gönderilirse `401 UNAUTHORIZED`.

### Bildirim oluştur

Fotoğraf yüklemesi için `multipart/form-data` kullanılır (öneri).

```bash
curl -X POST "http://localhost:8080/api/reports" \
  -H "Authorization: Bearer <erisim-belirteci>" \
  -F "category=Ariza" \
  -F "description=B blok 2. kat koridor lambası yanmıyor" \
  -F "locationSource=Gps" -F "latitude=36.5871" -F "longitude=36.1742" -F "place=B Blok 2. kat" \
  -F "photo=@lamba.jpg;type=image/jpeg"
```

Konum izni yoksa `locationSource=Building` ve `buildingId=<bina-id>` gönderilir; `latitude` ve `longitude` gönderilmez.

Yanıt `201`: [Domain tasarımındaki örnek veri](03-domain-design.md#örnek-veri-sahte) biçiminde bildirim.

### Bildirimi üstlen

```bash
curl -X PUT "http://localhost:8080/api/reports/d4816d0a-cd8e-4442-98c0-65d3ba11be70/assignment" \
  -H "Authorization: Bearer <erisim-belirteci>"
```

Başarılıysa `200` ve `status: "Ustlenildi"`. Başkası üstlenmişse:

```json
{ "error": { "code": "CONFLICT", "message": "Bildirim zaten üstlenilmiş.", "details": "" } }
```

### Çözüldü işaretle

```bash
curl -X PUT "http://localhost:8080/api/reports/d4816d0a-cd8e-4442-98c0-65d3ba11be70/resolution" \
  -H "Authorization: Bearer <erisim-belirteci>" \
  -F "note=Lamba değiştirildi." \
  -F "resolutionPhoto=@sonuc.jpg;type=image/jpeg"
```

Sonuç fotoğrafı zorunludur (`multipart/form-data`); yoksa `400 VALIDATION_ERROR`. Başarılıysa `200`, `status: "Cozuldu"`; öğrenci için `ReportResolved` bildirimi aynı işlemde oluşur ([Rule 04](03-domain-design.md#kurallar-rules)).

### Bildirimlerim

```bash
curl "http://localhost:8080/api/me/notifications?page=1&pageSize=20" \
  -H "Authorization: Bearer <erisim-belirteci>"
```

```json
{
  "unreadCount": 1,
  "items": [
    {
      "notificationId": "8a1f0c3e-5b7d-4c21-9e4a-2f6b7d9c1a10",
      "reportId": "d4816d0a-cd8e-4442-98c0-65d3ba11be70",
      "type": "ReportResolved",
      "message": "Bildiriminiz çözüldü: B blok 2. kat koridor lambası",
      "createdAt": "2026-10-02T11:40:00Z",
      "readAt": null
    }
  ],
  "page": 1,
  "pageSize": 20,
  "total": 1
}
```

Hiç bildirim yoksa `items` boş dizi, `unreadCount` 0 döner.

Her yanıtta güvenlik başlıkları bulunur: `X-Content-Type-Options: nosniff`, `X-Frame-Options: DENY`, `Content-Security-Policy: default-src 'none'; frame-ancestors 'none'`, `Referrer-Policy: no-referrer`, `Strict-Transport-Security`, `Cache-Control: no-store`.

Her yanıtta `X-Request-Id` başlığı da vardır; sunucu günlüğünde aynı istek bu kimlikle bulunur. Sunucu her isteği tek satır JSON olarak günlüğe yazar (`time`, `level`, `requestId`, `method`, `path`, `status`, `durationMs`); sorgu, başlık ve gövde günlüğe yazılmaz.

Yanıt gövdeleri örnektir; gerçek alanlar geliştirme sırasında bu dokümanla birlikte güncellenir.
