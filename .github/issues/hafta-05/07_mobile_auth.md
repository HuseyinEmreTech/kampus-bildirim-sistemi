# Issue #7: Mobil - Giriş Ekranı + Auth State (Token Storage)

**Milestone:** Hafta 05 (12-18 Eki)
**Atanan:** @yusufekenel
**Etiketler:** `app:mobile`, `feat`, `sart`
**Branch:** `feature/hafta05-mobile-auth`

## Kabul Ölçütleri
- [ ] **Giriş Ekranı** (`/login`)
  - Email/Şifre formu (validation: email format, şifre min 6 char)
  - Loading state (button disabled, spinner)
  - Hata mesajı: "Geçersiz email veya şifre" (401), "Sunucu hatası" (500)
  - Başarılı → `/reports` (Student) veya `/staff/reports` (Staff) redirect
- [ ] **Auth State Management**
  - `AuthProvider` (ChangeNotifier) veya basit singleton
  - `accessToken`, `refreshToken` → `flutter_secure_storage` (encrypted)
  - **Auto-login**: App başlangıçta secure storage'dan token okur, validse ana ekrana
  - **Token Refresh**: 401 alındığında auto refresh → retry (max 1 kez)
  - **Logout**: Tokens sil, `/login` redirect
- [ ] **Role-based Navigation**
  - `UserContext` (userId, role, fullName) memory'de tutulur
  - Student → Öğrenci akışı, Staff → Görevli akışı

## Dokunulacak Dosyalar
```
packages/app/lib/
├── core/
│   ├── auth/
│   │   ├── auth_provider.dart
│   │   ├── token_storage.dart (flutter_secure_storage wrapper)
│   │   └── auth_interceptor.dart (Dio/HTTP interceptor)
│   └── router/
│       └── app_router.dart (GoRouter: login, reports, staff)
├── features/
│   └── auth/
│       ├── presentation/
│       │   ├── login_screen.dart
│       │   └── widgets/login_form.dart
│       └── data/
│           └── auth_api.dart (contracts DTO kullanır)
└── shared/
    └── widgets/
        ├── loading_button.dart
        └── error_snackbar.dart
```

## Dokunulmayacak Dosyalar
- `packages/app/lib/features/reports/` - Bildirim ekranları (Issue #8)
- `packages/contracts/` - Sadece import (DTO'lar)
- `packages/application/` - Import YASAK (App paketi contracts kullanır)

## Bağlı Testler
- `packages/app/test/features/auth/login_screen_test.dart`
  - `showsValidationError_whenEmailInvalid`
  - `showsError_whenLoginFails`
  - `navigatesToReports_onSuccess`
- `packages/app/test/core/auth/auth_provider_test.dart`
  - `autoLogin_whenValidTokenStored`
  - `refreshToken_on401_thenRetry`
  - `logout_clearsStorage`

## Teknik Detaylar
```yaml
# pubspec.yaml ek bağımlılıklar
dependencies:
  go_router: ^14.0.0
  flutter_secure_storage: ^9.0.0
  dio: ^5.4.0  # veya http
  campus_contracts: ^1.0.0  # workspace dependency
```

```dart
// AuthInterceptor (Dio)
class AuthInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = AuthProvider.instance.accessToken;
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401 && !err.requestOptions.path.contains('/auth/')) {
      final refreshed = await AuthProvider.instance.refreshToken();
      if (refreshed) {
        // Retry original request
        final opts = err.requestOptions;
        opts.headers['Authorization'] = 'Bearer ${AuthProvider.instance.accessToken}';
        final response = await Dio().fetch(opts);
        return handler.resolve(response);
      }
    }
    handler.next(err);
  }
}
```

## Bağımlılık
- `campus_contracts` DTO'lar (LoginRequest, AuthResponse, UserDto)
- Server Issue #5 (Auth endpoints) **hazır olmalı** (mock ile başlanabilir)
- Theme, shared widgets (ayrı PR)

## Notlar
- **Platform kanalları** (kamera, konum) bu issue'da YOK (Issue #8)
- Web'de de aynı auth flow çalışmalı (Fatma ile paylaşılan `core/auth/`)
- `flutter_secure_storage` iOS/Android/Web (web'de IndexedDB fallback)