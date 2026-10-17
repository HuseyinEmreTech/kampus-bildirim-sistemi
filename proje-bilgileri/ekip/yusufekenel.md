---
title: Yusuf Ekenel - Kişisel Plan
durum: Taslak
son-guncelleme: 2026-10-15
---

# Yusuf Ekenel (@yusufekenel) - Kişisel Plan

**Rol:** Flutter Mobil Uygulama Geliştirici (Android, iOS, Web)
**Ana Sorumluluk:** `campus_app` paketi - Öğrenci ve Görevli mobil ekranları

## Haftalık Hedefler

### Hafta 3 (28 Eyl - 4 Eki): Kurulum ve Flutter Temelleri
- [ ] Flutter SDK kurulum, Android/iOS emulator/simulator
- [ ] `campus_app` paketi: `pubspec.yaml` bağımlılıklar (contracts, http, image_picker, geolocator, google_maps_flutter, provider/riverpod-basit)
- [ ] Tema (light/dark), Material 3, renk paleti
- [ ] Navigation: GoRouter veya basit Navigator 2.0
- [ ] Platform kanalları: Kamera, konum izinleri
- [ ] PR: Flutter iskeleti çalışıyor, temel navigasyon

### Hafta 4 (5 - 11 Eki): Temel Widget'lar ve State
- [ ] Giriş ekranı: Email/şifre formu, validation, hata mesajları
- [ ] Auth state management: Token saklama (flutter_secure_storage), auto-login
- [ ] Ortak widget'lar: Loading, Error, Empty states, Custom AppBar
- [ ] Responsive layout: Web için breakpoint'ler (Fatma ile senkron)
- [ ] PR'lar: Her ekran/widget ayrı PR

### Hafta 5 (12 - 18 Eki): Öğrenci - Bildirim Listesi
- [ ] **USR 05 "Üstlen" uçtan uca** (ilk ekran önceliği)
- [ ] Bildirim listesi: Infinite scroll, pull-to-refresh
- [ ] Bildirim kartı: Kategori rengi, durum rozeti, konum, thumbnail
- [ ] Boş durum: "Henüz bildirim yok" illustrasyonu
- [ ] Hata durumu: "Yeniden dene" butonu
- [ ] API entegrasyonu: `contracts` paketinden DTO kullanımı

### Hafta 6 (19 - 25 Eki): Öğrenci - Bildirim Oluşturma
- [ ] **USR 01 "Bildirim Aç"**: Fotoğraf çekme/galeri seçme
- [ ] Konum: GPS alma + izin reddedilirse bina listesi (dropdown)
- [ ] Kategori seçici: Radio group (Arıza, Temizlik, Güvenlik, Diğer)
- [ ] Açıklama: TextField (5-500 char, counter)
- [ ] Gönder: Loading state, başarı/hata feedback, listeye dönüş
- [ ] 5MB limit, jpeg/png validasyonu (client + server)

### Hafta 7 (26 Eki - 1 Kas): Görevli Ekranları ve Detay
- [ ] Görevli giriş: Role kontrolü (Staff)
- [ ] Bildirim listesi (Tümü / Benimkiler filtresi)
- [ ] **Üstlen butonu**: Optimistic UI, 409 hatası → toast "Başkası aldı"
- [ ] Bildirim detayı: Büyük fotoğraf, harita, konum tarifi
- [ ] **Çöz butonu**: Sonuç fotoğrafı zorunlu, not opsiyonel
- [ ] Çözüldü bildirimi: Öğrenci tarafında rozet güncelleme

### Hafta 8 (2 - 8 Kas): Gerçek API Entegrasyonu
- [ ] Mock/localhost'tan production API'ye geçiş
- [ ] Token refresh, 401 handling → auto logout + login redirect
- [ ] Offline-first: Hata durumunda local cache, online olduğunda sync
- [ ] Yetki testleri: Student Staff endpoint'lerine erişemez

### Hafta 9 (9 - 15 Kas): 1. Sunum ve Web Desteği
- [ ] **1. Sunum** (varsayım): Mobil demo canlı
- [ ] Flutter Web: `flutter build web` çalışıyor mu?
- [ ] Responsive: Web'de yan panel (liste) + detay (sağ)
- [ ] PWA manifest, service worker (basit)
- [ ] Fatma ile web UI uyumu (paylaşılan widget'lar)

### Hafta 10 (16 - 22 Kas): Çözüm Fotoğrafı ve Pürüzler
- [ ] Çözüm fotoğrafı: Kamera/galeri, preview, yeniden çek
- [ ] Boş/hata durumları: Ağ yok, kamera izni yok, konum alamaz
- [ ] Sayfalama: Cursor-based veya offset-based
- [ ] Bildirimlerim ekranı (Öğrenci): Kendi bildirimleri + durum geçmişi

### Hafta 11 (23 - 29 Kas): Performans ve Erişilebilirlik
- [ ] Image caching: `cached_network_image` veya custom
- [ ] Lazy loading listeler, memory leak kontrolü
- [ ] Erişilebilirlik: Semantik etiketler, kontrast, font boyutu
- [ ] iOS özel: Safe area, permission strings (Info.plist)

### Hafta 12 (30 Kas - 6 Ara): Build ve Release
- [ ] **Özellik dondurma** - Sadece hata
- [ ] Android: `flutter build apk --release` (arm64, armeabi-v7a)
- [ ] iOS: `flutter build ipa` (Developer account gerektirir - TestFlight)
- [ ] Web: `flutter build web --release` (Fatma ile)
- [ ] Versioning: `pubspec.yaml` version + build number
- [ ] GitHub Release: APK artifact, Web URL

### Hafta 13 (7 - 13 Ara): Cila ve Sunum
- [ ] Animasyonlar: Hero (fotoğraf), page transitions
- [ ] Splash screen, app icon (tüm çözünürlükler)
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
- [2026-10-17](raporlar/yusufekenel/2026-10-17.md): #70 açıldı, "Bildirim oluştur" düğmesi, görevli listesi, Üstlen, çözüldü bildirimleri, bildirim detayı
