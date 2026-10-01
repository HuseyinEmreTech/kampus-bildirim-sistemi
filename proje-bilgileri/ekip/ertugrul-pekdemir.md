---
title: "Plan: Ertuğrul Pekdemir"
durum: Güncel
son-guncelleme: 2026-10-02
---

# Plan: Ertuğrul Pekdemir (veri ve altyapı)

← [Ekip ve yol haritası](../10-ekip-ve-yol-haritasi.md) · [Başlangıç rehberi](00-baslangic-rehberi.md)

**Sorumluluk:** `packages/infrastructure` (PostgreSQL repository'leri, dosya depolama, EXIF temizleme, parola hash), `db/migrations`, `db/seed`, `compose.yaml`; hafta 8'den sonra Flutter'da **yeni bildirim ekranı** (kamera, GPS, bina listesi).

**Neden sen:** Ekipte Dart ve PostgreSQL bilen tek kişisin. Projenin en kritik iki kuralı (Rule 02 yarış, Rule 04 tek işlem) veritabanında çözülüyor.

**Dokunmayacağın yerler (sorulmadan):** `packages/domain`, `packages/application`, `packages/contracts`, `test/architecture_test.dart`, `.github/`. Arayüz (imza) değişmesi gerekiyorsa issue'da Hüseyin'e yaz; arayüzü sen değiştirme.

**Hocanın sorabileceği:** "İki görevli aynı anda üstlenirse ne olur, nerede engelliyorsunuz?", "SQL Injection'a karşı ne yaptınız?", "Durum ve bildirim neden aynı işlemde?" Bu üç sorunun cevabı senin kodunda.

## Haftalık plan

### Hafta 3 (28 Eyl - 4 Eki)
- Kurulum ([rehber](00-baslangic-rehberi.md#2-kurulum)); `flutter doctor` temiz.
- PostgreSQL 16'yı konteynerde çalıştır, `psql` ile bağlan:
  ```bash
  podman run --rm -d --name pg-deneme -e POSTGRES_PASSWORD=deneme -p 5440:5432 postgres:16
  podman exec -it pg-deneme psql -U postgres -c "select version();"
  ```
- İlk PR: [şablonla](../Templates/gunluk-rapor.md) ilk günlük raporun (`raporlar/ertugrul-pekdemir/`) ve plan dosyandaki Raporlar listesine bağlantısı.

### Hafta 4 (5 - 11 Eki): şema ve seed
- `compose.yaml`: yalnızca PostgreSQL 16, host portu `5440`, şifre `.env`'den; `.env.example` (gerçek şifre yok).
- `db/migrations/001_baslangic.sql`: tablolar `users`, `buildings`, `reports`, `status_history`, `notifications`, `sessions`.
  - Kurallar veritabanında da korunur: `CHECK (status IN ('Yeni','Ustlenildi','Cozuldu'))`, `CHECK (category IN (...))`, `CHECK (status <> 'Cozuldu' OR resolution_photo_path IS NOT NULL)`, `UNIQUE (email)`, yabancı anahtarlar.
- `db/seed/001_ornek.sql`: 2 öğrenci, 2 görevli (sahte ad ve e-posta, parola hash'i), 5 bina, 3 örnek bildirim. Yusuf'un hazırladığı sahte veri listesiyle aynı.
- Kabul: `podman compose up -d` sonrası migration ve seed hatasız çalışır; README'ye iki komut eklenir.

### Hafta 5 (12 - 18 Eki): altın dilimin veri tarafı
- `PostgresReportRepository.findById` ve `tryAssign`:
  ```sql
  UPDATE reports SET status = 'Ustlenildi', assignee_id = $2, taken_at = $3
  WHERE id = $1 AND status = 'Yeni' AND assignee_id IS NULL
  ```
  Etkilenen satır 0 ise `false` döner (servis bunu `409`'a çevirir).
- Hüseyin'in yazdığı yarış testini (`bekliyor`) yeşile çevir: iki bağlantı aynı anda üstlenir, yalnızca biri `true` alır.
- CI'a PostgreSQL servis konteyneri ve `db` etiketli testlerin koşması (Hüseyin'le birlikte, `.github/` onu ister).

### Hafta 6 (19 - 25 Eki)
- `ReportRepository.resolve(...)`: `reports` güncellemesi, `status_history` satırı ve `notifications` satırı **tek işlemde** (`BEGIN ... COMMIT`; hata olursa hiçbiri yazılmaz). Testi: bildirim yazımı başarısız olursa durum da değişmemiş olmalı.
- `PostgresNotificationRepository`, `PostgresUserRepository`, `PostgresSessionRepository`.
- Parola hash gerçeklemesi (`PasswordHasher`): paket seçimini pub.dev'de kontrol et (güncellik, bakım, indirme), seçimi [teknoloji değişikliklerine](../kayitlar/teknoloji-degisiklikleri.md) yaz.

### Hafta 7 (26 Eki - 1 Kas)
- `FileSystemPhotoStorage`: dosya adı sunucu üretir (UUID), yalnızca `image/jpeg` ve `image/png`, 5 MB üstü reddedilir, **EXIF temizlenir**. Testi: konum bilgisi içeren örnek fotoğraf kaydedilince EXIF'siz çıkar.
- `PostgresBuildingRepository`, `ReportRepository.add`, `listByReporter`, `list` (sayfalı).

### Hafta 8 (2 - 8 Kas): Flutter'a geçiş
- `packages/app`: **yeni bildirim ekranı**. Kamera veya galeriden fotoğraf; GPS ile konum; izin verilmezse bina listesi (`GET /api/buildings`); kategori, açıklama, yer tarifi; "fotoğrafta kişi olmamasına dikkat edin" uyarısı.
- Konum ve kamera paketlerini pub.dev'de kontrol et, issue'ya yaz, Hüseyin onaylasın.
- Emülatörde sahte konumla test (kampüs içi ve dışı).

### Hafta 9 (9 - 15 Kas): 1. sunum
- Demo için seed verisini hazırla; sunumda veri ve yarış durumu kısmını sen anlat.

### Hafta 10 (16 - 22 Kas)
- Yeni bildirim ekranında hata ve boş durumlar (`422 OUTSIDE_CAMPUS`, fotoğraf çok büyük, ağ yok).
- Sıfır veri ve sayfalama entegrasyon testleri.

### Hafta 11 (23 - 29 Kas)
- Kendi paketindeki SonarQube bulguları, tek tek; her biri için ne yaptığını PR'a yaz.

### Hafta 12 (30 Kas - 6 Ara)
- Dağıtım denemesi: sunucu ve PostgreSQL için compose (VPS varsa VPS'te, yoksa yerelde); APK derlemesi (`flutter build apk`).

### Hafta 13 (7 - 13 Ara)
- `infrastructure` kapsamı; dağıtım belgesi (README "Kurulum" bölümünün veritabanı kısmı).

### Hafta 14 (14 - 20 Ara): test haftası
- Entegrasyon testlerinin tamamı, yarış testi 20 kez üst üste, temiz veritabanından kurulum denemesi.

### Hafta 15 (21 - 27 Ara): teslim
- Katkı raporu (günlük raporlarından), sunumdaki kendi bölümün.

## Raporlar

Çalıştığın **her gün** için bir rapor: `ekip/raporlar/ertugrul-pekdemir/YYYY-AA-GG.md`. Şablon: [günlük rapor şablonu](../Templates/gunluk-rapor.md). Rapor o günün iş branch'inde, işin PR'ıyla birlikte girer; PR açılmayan günün raporu bir sonraki PR'a eklenir. Yalnızca kendi klasörüne yaz. Dönem sonundaki katkı raporun bu raporlardan derlenir.

Yeni rapor ekleyince bu listeye bir satır ekle (en yeni üstte):

- (İlk raporun hafta 3'te buraya eklenecek.)
