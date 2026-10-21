---
title: Yusuf Ekenel - Kişisel Plan
durum: Taslak
son-guncelleme: 2026-10-22
---

# Yusuf Ekenel (@yusufekenel) - Kişisel Plan

**Rol:** Flutter Mobil Uygulama Geliştirici (Android, iOS, Web)
**Ana Sorumluluk:** `campus_app` paketi - Öğrenci ve Görevli mobil ekranları

## Haftalık Hedefler

### Hafta 3 (28 Eyl - 4 Eki): Kurulum ve Flutter Temelleri
- [x] Flutter SDK kurulum, Android/iOS emulator/simulator
- [ ] `campus_app` paketi: `pubspec.yaml` bağımlılıklar (contracts, http, image_picker, geolocator, google_maps_flutter, provider/riverpod-basit) (kısmen: http, image_picker, geolocator, flutter_secure_storage eklendi; google_maps_flutter onaylı değil; provider/riverpod AGENTS.md gereği yasak)
- [x] Tema (light/dark), Material 3, renk paleti
- [x] Navigation: GoRouter veya basit Navigator 2.0 (Flutter `Navigator`; GoRouter onaylı değil)
- [x] Platform kanalları: Kamera, konum izinleri (native kod yok, eklentilerle)
- [x] PR: Flutter iskeleti çalışıyor, temel navigasyon (#35, #42)

### Hafta 4 (5 - 11 Eki): Temel Widget'lar ve State
- [x] Giriş ekranı: Email/şifre formu, validation, hata mesajları (#84)
- [x] Auth state management: Token saklama (flutter_secure_storage), auto-login (#97 açık, şifreli saklama yerel)
- [x] Ortak widget'lar: Loading, Error, Empty states, Custom AppBar
- [ ] Responsive layout: Web için breakpoint'ler (Fatma ile senkron)
- [x] PR'lar: Her ekran/widget ayrı PR

### Hafta 5 (12 - 18 Eki): Öğrenci - Bildirim Listesi
- [x] **USR 05 "Üstlen" uçtan uca** (ilk ekran önceliği) (#98 açık)
- [x] Bildirim listesi: Infinite scroll, pull-to-refresh
- [x] Bildirim kartı: Kategori rengi, durum rozeti, konum, thumbnail
- [x] Boş durum: "Henüz bildirim yok" illustrasyonu
- [x] Hata durumu: "Yeniden dene" butonu
- [ ] API entegrasyonu: `contracts` paketinden DTO kullanımı

### Hafta 6 (19 - 25 Eki): Öğrenci - Bildirim Oluşturma
- [x] **USR 01 "Bildirim Aç"**: Fotoğraf çekme/galeri seçme
- [x] Konum: GPS alma + izin reddedilirse bina listesi (dropdown)
- [x] Kategori seçici: Radio group (Arıza, Temizlik, Güvenlik, Diğer) (#70)
- [x] Açıklama: TextField (5-500 char, counter) (#70)
- [x] Gönder: Loading state, başarı/hata feedback, listeye dönüş (#70)
- [x] 5MB limit, jpeg/png validasyonu (client + server) (istemci tarafı; sunucu tarafı sunucu ekibinde)

### Hafta 7 (26 Eki - 1 Kas): Görevli Ekranları ve Detay
- [ ] Görevli giriş: Role kontrolü (Staff) (kısmen: kabuk role göre ekran açıyor; asıl yetki sunucuda)
- [x] Bildirim listesi (Tümü / Benimkiler filtresi) (#85)
- [x] **Üstlen butonu**: Optimistic UI, 409 hatası → toast "Başkası aldı"
- [ ] Bildirim detayı: Büyük fotoğraf, harita, konum tarifi (kısmen: büyük fotoğraf ve yer tarifi var; harita paketi onaylı değil)
- [x] **Çöz butonu**: Sonuç fotoğrafı zorunlu, not opsiyonel
- [x] Çözüldü bildirimi: Öğrenci tarafında rozet güncelleme (#86)

### Hafta 8 (2 - 8 Kas): Gerçek API Entegrasyonu
- [ ] Mock/localhost'tan production API'ye geçiş (kısmen: HTTP kaynakları hazır, sunucuda uç noktalar yok)
- [x] Token refresh, 401 handling → auto logout + login redirect
- [ ] Offline-first: Hata durumunda local cache, online olduğunda sync
- [ ] Yetki testleri: Student Staff endpoint'lerine erişemez

### Hafta 9 (9 - 15 Kas): 1. Sunum ve Web Desteği
- [ ] **1. Sunum** (varsayım): Mobil demo canlı
- [ ] Flutter Web: `flutter build web` çalışıyor mu? (kısmen: demo Chrome'da çalışıyor, derleme denenmedi)
- [ ] Responsive: Web'de yan panel (liste) + detay (sağ)
- [ ] PWA manifest, service worker (basit)
- [ ] Fatma ile web UI uyumu (paylaşılan widget'lar)

### Hafta 10 (16 - 22 Kas): Çözüm Fotoğrafı ve Pürüzler
- [x] Çözüm fotoğrafı: Kamera/galeri, preview, yeniden çek
- [ ] Boş/hata durumları: Ağ yok, kamera izni yok, konum alamaz (kısmen: ağ yok mesajı var)
- [x] Sayfalama: Cursor-based veya offset-based (`page` + `pageSize`)
- [x] Bildirimlerim ekranı (Öğrenci): Kendi bildirimleri + durum geçmişi

### Hafta 11 (23 - 29 Kas): Performans ve Erişilebilirlik
- [ ] Image caching: `cached_network_image` veya custom
- [ ] Lazy loading listeler, memory leak kontrolü (kısmen: listeler tembel; sızıntı yalnızca elle kontrol)
- [x] Erişilebilirlik: Semantik etiketler, kontrast, font boyutu (TalkBack ile cihazda denenmedi)
- [ ] iOS özel: Safe area, permission strings (Info.plist)

### Hafta 12 (30 Kas - 6 Ara): Build ve Release
- [ ] **Özellik dondurma** - Sadece hata
- [ ] Android: `flutter build apk --release` (arm64, armeabi-v7a) (kısmen: Gradle loopback hatası, NDK eksik)
- [ ] iOS: `flutter build ipa` (Developer account gerektirir - TestFlight)
- [ ] Web: `flutter build web --release` (Fatma ile)
- [ ] Versioning: `pubspec.yaml` version + build number
- [ ] GitHub Release: APK artifact, Web URL

### Hafta 13 (7 - 13 Ara): Cila ve Sunum
- [ ] Animasyonlar: Hero (fotoğraf), page transitions (kısmen: Hero var, sayfa geçişleri yok)
- [x] Splash screen, app icon (tüm çözünürlükler) (cihazda görülmedi)
- [ ] **2. Sunum** demo senaryosu yazımı (Fatma ile)
- [ ] Kullanım kılavuzu: Ekran görüntüleri + adımlar

### Hafta 14 (14 - 20 Ara): Test Haftası
- [ ] Sadece hata düzeltme
- [ ] Manuel test: Tüm akışlar (Student + Staff)
- [ ] Farklı cihaz boyutları: Phone, Tablet, Web desktop

### Hafta 15 (21 - 27 Ara): Teslim
- [ ] Final APK/Web linkleri hoca/ekibe
- [ ] Canlı demo telefonunda
- [ ] Katkı raporu: Kendi PR'ları, çözdüğü sorunlar

---

## Teknik Borç / Öğrenilecekler
- [ ] Flutter Web responsive patterns
- [ ] Platform channel (konum, kamera native)
- [ ] Secure storage + token refresh pattern
- [ ] Image compression + EXIF stripping (client-side ön temizleme)

## Bağımlılıklar
- **Hüseyin Emre**: Contracts (DTO), API spec, kabul testleri
- **Çağdaş/Ertuğrul**: API endpoint'leri hazır olmalı
- **Fatma**: Web UI ortak widget'lar, responsive breakpoint'ler

## Raporlar
- [2026-10-15](raporlar/yusufekenel/2026-10-15.md): Kurulum, öğrenci bildirim listesi ve oluşturma ekranları (#21)
- [2026-10-16](raporlar/yusufekenel/2026-10-16.md): Giriş ekranı ve oturum durumu, gh kurulumu
- [2026-10-21](raporlar/yusufekenel/2026-10-21.md): #84-86 ve #89 birleşti; oturum durumu ve Üstlen + filtre PR'ları hazırlandı
- [2026-10-22](raporlar/yusufekenel/2026-10-22.md): Haftalık görev durumu tablosu, plandaki kutular işaretlendi
