---
title: "Plan: Murat Yaman"
durum: Güncel
son-guncelleme: 2026-10-02
---

# Plan: Murat Yaman (sunucu ve API)

← [Ekip ve yol haritası](../10-ekip-ve-yol-haritasi.md) · [Başlangıç rehberi](00-baslangic-rehberi.md)

**Sorumluluk:** `packages/contracts` sınıflarının yazımı (Hüseyin onaylar), `packages/server` (Shelf endpoint'leri, kimlik doğrulama ara katmanı, hata eşleme, `bin/main.dart`); hafta 8'den sonra Flutter'da **görevli ekranları**.

**Neden sen:** C# biliyorsun; Dart'ın sözdizimi C#'a çok yakın (sınıf, `final`, `async`/`await`, null güvenliği). Sunucu katmanı ince: isteği oku, servisi çağır, sonucu JSON'a çevir. İş kuralı yazmazsın, kuralı servis uygular.

**Dokunmayacağın yerler (sorulmadan):** `packages/domain`, `packages/application`, `packages/infrastructure`, `test/architecture_test.dart`, `.github/`. Bir endpoint için servis eksikse issue'da yaz.

**Hocanın sorabileceği:** "Yetkisiz biri başkasının bildirimini görebilir mi, nerede engelliyorsunuz?", "Hata kodları nasıl belirleniyor?", "Token nasıl doğrulanıyor?"

## Dart'a C#'tan geçiş (hafta 3-4)

| C# | Dart |
| --- | --- |
| `public class X` | `class X` (alt çizgiyle başlayan isim kütüphaneye özeldir: `_x`) |
| `readonly` | `final` |
| `string?` | `String?` (null güvenliği varsayılan açık) |
| `Task<T>`, `async`/`await` | `Future<T>`, `async`/`await` |
| `List<T>`, `Dictionary<K,V>` | `List<T>`, `Map<K, V>` |
| `switch` ifadesi, `record` | `switch` ifadesi, `record`, `sealed class` |
| NuGet, `.csproj` | pub.dev, `pubspec.yaml` |

Kaynak: [dart.dev/language](https://dart.dev/language). Shelf: [pub.dev/packages/shelf](https://pub.dev/packages/shelf).

## Haftalık plan

### Hafta 3 (28 Eyl - 4 Eki)
- Kurulum; Dart dil turu (yukarıdaki tablo ve kaynak).
- **Kampüs bilgisi:** haritadan İSTE kampüsünü kapsayan dikdörtgenin güneybatı ve kuzeydoğu köşe koordinatları ve kampüsteki 5 bina (ad, merkez koordinat). [Domain tasarımına](../03-domain-design.md) tablo olarak ekleyen bir doküman PR'ı.
- İlk PR: [şablonla](../Templates/gunluk-rapor.md) ilk günlük raporun (`raporlar/murat-yaman/`) ve plan dosyandaki Raporlar listesine bağlantısı.

### Hafta 4 (5 - 11 Eki): contracts
- `packages/contracts`: `LoginRequest`, `LoginResponse`, `ReportResponse`, `ReportListResponse`, `NotificationResponse`, `NotificationListResponse`, `BuildingResponse`, `ErrorResponse`, `ErrorCode`. Her biri `fromJson` ve `toJson` (elle; kod üretimi yok).
- Her sınıf için gidiş-dönüş testi: `toJson` sonra `fromJson` aynı nesneyi verir; [API tasarımındaki](../05-api-design.md) örnek JSON okunabilir.

### Hafta 5 (12 - 18 Eki): sunucu iskeleti ve altın dilim
- `server`: `bin/main.dart` (bağlama), `GET /health`, hata eşleme (`AppError` → HTTP durum ve `ErrorResponse`; `switch` ifadesi), JSON gövde yardımcıları.
- `PUT /api/reports/{id}/assignment` (Hüseyin'in yazdığı HTTP kabul testlerini yeşile çevir).
- `GET /api/reports` (sayfalı).

### Hafta 6 (19 - 25 Eki)
- `POST /api/auth/login`; kimlik doğrulama ara katmanı (`Authorization: Bearer <token>`, `Authenticate` servisi ile; yoksa `401`).
- `PUT /api/reports/{id}/resolution` (`multipart/form-data`: sonuç fotoğrafı zorunlu, not isteğe bağlı).

### Hafta 7 (26 Eki - 1 Kas)
- `POST /api/reports` (`multipart`: fotoğraf, kategori, açıklama, konum kaynağı, koordinat veya bina, yer tarifi).
- `GET /api/me/reports`, `GET /api/reports/{id}`, `GET /api/me/notifications`, `PUT /api/me/notifications/{id}/read`, `GET /api/buildings`.
- [API tasarımı](../05-api-design.md) dokümanındaki her `curl` örneğini gerçek sunucuda çalıştır; tutmayanı dokümanda düzelt.

### Hafta 8 (2 - 8 Kas): Flutter'a geçiş
- `packages/app`: **görevli ekranları**: gelen bildirimler listesi (filtre: durum, kategori), görev detayı (fotoğraf, konum, yer tarifi), "İlgileniyorum" düğmesi (`409` gelirse "başka görevli üstlendi" mesajı).
- Hüseyin'le yetki testleri (Rule 00, 01, 03).

### Hafta 9 (9 - 15 Kas): 1. sunum
- Sunumda API ve görevli akışını sen anlat; `curl` ile canlı örnek.

### Hafta 10 (16 - 22 Kas)
- Görevli "çözüldü" ekranı: sonuç fotoğrafı çekme (Ertuğrul'un fotoğraf bileşenini yeniden kullan), not, gönder.
- Liste sayfalama (aşağı kaydırınca sonraki sayfa).

### Hafta 11 (23 - 29 Kas)
- Rate limit ara katmanı (dakikada 60 istek, kullanıcı başına); testi.
- Kendi paketlerindeki SonarQube bulguları.

### Hafta 12 (30 Kas - 6 Ara)
- Sunucunun konteyner imajı (`Dockerfile`), Ertuğrul'un compose'una eklenmesi.

### Hafta 13 (7 - 13 Ara)
- API dokümanının son hali; README "API özeti" ve yapılandırma tablosu.

### Hafta 14 (14 - 20 Ara): test haftası
- Tüm endpoint'ler için yetki matrisi testi: her rol × her endpoint, beklenen durum kodu.

### Hafta 15 (21 - 27 Ara): teslim
- Katkı raporu, sunumdaki kendi bölümün.

## Raporlar

Çalıştığın **her gün** için bir rapor: `ekip/raporlar/murat-yaman/YYYY-AA-GG.md`. Şablon: [günlük rapor şablonu](../Templates/gunluk-rapor.md). Rapor o günün iş branch'inde, işin PR'ıyla birlikte girer; PR açılmayan günün raporu bir sonraki PR'a eklenir. Yalnızca kendi klasörüne yaz. Dönem sonundaki katkı raporun bu raporlardan derlenir.

Yeni rapor ekleyince bu listeye bir satır ekle (en yeni üstte):

- (İlk raporun hafta 3'te buraya eklenecek.)
