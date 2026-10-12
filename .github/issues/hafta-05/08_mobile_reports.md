# Issue #8: Mobil - Bildirim Listesi (Student) + Oluşturma Ekranı

**Milestone:** Hafta 05 (12-18 Eki)
**Atanan:** @yusufekenel
**Etiketler:** `app:mobile`, `feat`, `sart`
**Branch:** `feature/hafta05-mobile-reports`

## Kabul Ölçütleri
- [ ] **Bildirim Listesi** (`/reports` - Student)
  - `ListView.builder` + `RefreshIndicator` (pull-to-refresh)
  - **Bildirim Kartı**: Kategori rengi (chip), durum rozeti (Yeni/Üstlenildi/Çözüldü), thumbnail foto, konum (place), oluşturma tarihi
  - **Boş durum**: "Henüz bildiriminiz yok" + ilustrasyon + "Bildirim Oluştur" FAB
  - **Hata durumu**: "Yüklenemedi" + "Tekrar Dene" butonu
  - **Infinite scroll**: `ScrollController` + `onLoadMore` (cursor pagination)
- [ ] **Bildirim Oluşturma** (`/reports/create` - Student)
  - **Fotoğraf**: `ImagePicker` (camera/gallery), preview, yeniden çek, **5MB/client-side check**
  - **Konum**: 
    - GPS: `Geolocator.getCurrentPosition()` + izin isteği
    - İzin reddedilirse → **Bina Listesi** (Dropdown, `GET /api/buildings`)
    - Seçilen bina → koordinat otomatik doldurulur
  - **Kategori**: `SegmentedButton` veya `RadioListTile` (4 seçenek)
  - **Açıklama**: `TextField` (maxLength: 500, counter)
  - **Gönder**: Loading overlay, başarı → listeye dön + snackbar "Bildirim oluşturuldu"
  - **Validasyon**: Client-side (foto, konum, kategori, açıklama) + Server hata gösterimi

## Dokunulacak Dosyalar
```
packages/app/lib/features/reports/
├── presentation/
│   ├── student/
│   │   ├── reports_list_screen.dart
│   │   ├── widgets/report_card.dart
│   │   ├── report_create_screen.dart
│   │   ├── widgets/photo_picker.dart
│   │   ├── widgets/location_picker.dart (GPS + Building dropdown)
│   │   └── widgets/category_selector.dart
│   └── shared/
│       └── empty_state.dart
├── data/
│   ├── reports_api.dart (contracts DTO)
│   └── reports_repository.dart (API call wrapper)
└── domain/
    └── report_state.dart (ChangeNotifier: list, loading, error, pagination)
```

## Dokunulmayacak Dosyalar
- `packages/app/lib/features/auth/` - Auth (Issue #7)
- `packages/app/lib/features/reports/staff/` - Görevli ekranları (Hafta 6+)
- `packages/contracts/` - Import only

## Bağlı Testler
- `packages/app/test/features/reports/student/reports_list_test.dart`
  - `showsEmptyState_whenNoReports`
  - `showsReports_whenDataExists`
  - `loadsMore_onScroll`
  - `refresh_updatesList`
- `packages/app/test/features/reports/student/report_create_test.dart`
  - `showsValidationError_whenPhotoMissing`
  - `showsValidationError_whenLocationMissing`
  - `submitsSuccessfully_withValidData`
  - `showsServerError_on422`

## Teknik Detaylar
```dart
// LocationPicker - GPS + Building fallback
class LocationPicker extends StatefulWidget {
  final Function(LocationData) onLocationSelected;
  
  // GPS izni varsa: Geolocator.getCurrentPosition()
  // Yoksa: BuildingDropdown (FutureBuilder -> GET /api/buildings)
  // Seçim: LocationData(lat, lng, place, source: Gps|Building, buildingId?)
}

// PhotoPicker - Client-side 5MB check
class PhotoPicker extends StatefulWidget {
  final Function(Uint8List, String) onPhotoSelected; // bytes, contentType
  
  // ImagePicker.pickImage(source: camera|gallery)
  // Uint8List.length <= 5MB kontrol
  // Mime type: image/jpeg | image/png
}
```

## API Entegrasyonu
- `ReportsApi.create(CreateReportRequest)` → `ReportResponse`
- `ReportsApi.list(ListReportsQuery)` → `PaginatedResponse<ReportSummary>`
- Contracts DTO: `CreateReportRequest.fromDomain()`, `ReportSummary.toDomain()`

## Bağımlılık
- Issue #7 (Auth) **önce** - token interceptor hazır
- Issue #6 (Server report endpoints) **hazır olmalı** (mock ile başlanabilir)
- `campus_contracts` DTO'lar
- Paketler: `image_picker`, `geolocator`, `permission_handler`

## Notlar
- **Web'de de çalışmalı** (Fatma ile paylaşılan widget'lar: `PhotoPicker`, `LocationPicker`, `CategorySelector`)
- Responsive: Mobile tek kolon, Tablet/Desktop yan panel (Fatma sorumluluğu)
- EXIF temizleme **client-side opsiyonel** (sunucu zaten yapar), yapılırsa `image` paketi ile