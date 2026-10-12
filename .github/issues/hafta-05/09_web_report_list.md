# Issue #9: Web - Responsive Bildirim Listesi (Yan Panel) + Widget Testleri

**Milestone:** Hafta 05 (12-18 Eki)
**Atanan:** @muberrayener
**Etiketler:** `app:web`, `feat`, `test`, `sart`
**Branch:** `feature/hafta05-web-report-list`

## Kabul Ölçütleri
- [ ] **Responsive Bildirim Listesi** (`/reports`)
  - **Desktop (>900px)**: Yan panel (sol: liste, sağ: detay/boş) - `Row` + `Expanded`
  - **Tablet (600-900px)**: Yan panel daraltılmış, detay modal/bottom sheet
  - **Mobile (<600px)**: Tek kolon, detay `Navigator.push` (Mobil ile aynı davranış)
  - **Breakpoint'ler**: `LayoutBuilder` + `MediaQuery` + paylaşılan `ResponsiveBreakpoints` class
- [ ] **Liste Paneli (Sol)**
  - `ListView` + `RefreshIndicator` (web'de mouse wheel scroll)
  - **Kart**: Hover efekti, kategori rengi, durum badge, thumbnail, konum, tarih
  - **Filtreler** (Staff için): Status, Kategori, Tarih aralığı - `DropdownButton` / `DateRangePicker`
  - **Boş durum**: "Henüz bildirim yok" + CTA butonu (Student: "Bildirim Oluştur", Staff: "Yenile")
- [ ] **Detay Paneli (Sağ - Desktop)**
  - Seçili bildirimin: Büyük foto, konum (harita - Leaflet/MapLibre), açıklama, durum zaman çizelgesi
  - **Staff**: "Üstlen" / "Çöz" butonları (modal confirm)
  - **Student**: Sadece görüntüleme
- [ ] **Widget Testleri** (Flutter Test)
  - `test/widget/reports_list_desktop_test.dart`
  - `test/widget/reports_list_mobile_test.dart`
  - `test/widget/report_card_test.dart`

## Dokunulacak Dosyalar
```
packages/app/lib/
├── core/
│   └── responsive/
│       ├── breakpoints.dart (mobile: <600, tablet: 600-900, desktop: >900)
│       └── responsive_layout.dart (LayoutBuilder wrapper)
├── features/reports/
│   ├── presentation/
│   │   ├── web/
│   │   │   ├── reports_list_web.dart (ResponsiveLayout child)
│   │   │   ├── widgets/reports_sidebar.dart
│   │   │   ├── widgets/report_detail_panel.dart
│   │   │   └── widgets/filter_bar.dart
│   │   └── shared/
│   │       ├── report_card.dart (Mobile ile PAYLAŞILIR)
│   │       ├── photo_viewer.dart
│   │       └── status_badge.dart
│   └── domain/
│       └── reports_state.dart (ChangeNotifier - Mobile ile PAYLAŞILIR)
└── shared/widgets/
    ├── responsive_scaffold.dart
    └── adaptive_navigation.dart
```

## Dokunulmayacak Dosyalar
- `packages/app/lib/features/auth/` - Auth (Issue #7, Yusuf ile paylaşılıyor)
- `packages/app/lib/features/reports/student/report_create_screen.dart` - Oluşturma (Hafta 6+)
- `packages/contracts/` - Import only

## Paylaşılan Kod (Yusuf ile Senkron)
| Dosya | Sahip | Not |
|-------|-------|-----|
| `report_card.dart` | **Ortak** | Mobile/Web aynı kart |
| `reports_state.dart` | **Ortak** | State logic aynı |
| `photo_picker.dart` | **Ortak** | Web: drag&drop, Mobile: camera/gallery |
| `location_picker.dart` | **Ortak** | Web: map click, Mobile: GPS |
| `category_selector.dart` | **Ortak** | Aynı widget |

## Bağlı Testler
- `packages/app/test/widget/reports_list_desktop_test.dart`
  - `showsSidebarAndDetail_onDesktop`
  - `selectsReport_showsDetailInPanel`
  - `filtersWork_onStaffView`
- `packages/app/test/widget/reports_list_mobile_test.dart`
  - `navigatesToDetail_onTap`
  - `showsEmptyState_whenNoReports`
- `packages/app/test/widget/report_card_test.dart`
  - `displaysCategoryColor`
  - `displaysStatusBadge`
  - `showsThumbnail`

## Teknik Detaylar
```dart
// ResponsiveLayout - Her ekran için kullanılan ortak widget
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget desktop;
  
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 600) return mobile;
        if (constraints.maxWidth < 900) return tablet ?? mobile;
        return desktop;
      },
    );
  }
}

// ReportsListWeb - Desktop: Sidebar + Detail Panel
class ReportsListWeb extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ResponsiveLayout(
      mobile: ReportsListMobile(), // Yusuf'un ekranı
      desktop: Row(
        children: [
          Expanded(flex: 2, child: ReportsSidebar()),
          Expanded(flex: 3, child: ReportDetailPanel()),
        ],
      ),
    );
  }
}
```

## Harita (Web) - Leaflet/MapLibre GL JS
- `web/index.html` → Leaflet CDN script
- Dart-JS interop: `dart:js_interop` ile harita oluşturma
- Veya `flutter_map` paketi (pure Flutter, web'de canvas renderer)

## Bağımlılık
- Issue #7 (Auth) **paylaşılıyor** - Yusuf ile aynı `core/auth/`
- Issue #6 (Server report endpoints) **hazır olmalı**
- `campus_contracts` DTO'lar
- `flutter_test` (widget testleri)

## Notlar
- **PWA**: `web/manifest.json`, `flutter build web` PWA desteği (Hafta 9+)
- **SEO**: Meta tags, `index.html` title/description (Hafta 9+)
- **Cross-browser test**: Chrome, Firefox, Safari (Hafta 14)