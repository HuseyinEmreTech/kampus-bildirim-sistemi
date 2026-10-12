# Issue #5: Auth Endpoints - Login, Refresh, JWT Middleware, Role Guard

**Milestone:** Hafta 05 (12-18 Eki)
**Atanan:** @Cagdas3307
**Etiketler:** `server`, `feat`, `sart`
**Branch:** `feature/hafta05-auth-endpoints`

## Kabul Ölçütleri
- [ ] `POST /api/auth/login`
  - Request: `LoginRequest { email: String, password: String }`
  - Response: `AuthResponse { accessToken: String, refreshToken: String, user: UserDto }`
  - BCrypt verify (cost 12), user not found / wrong password → `401 InvalidCredentials`
  - JWT Access: 15 min, HS256, claims: `sub=userId`, `role=Student|Staff`, `iat`, `exp`
  - JWT Refresh: 7 gün, ayrı secret, rotation (eski revoke)
- [ ] `POST /api/auth/refresh`
  - Request: `RefreshRequest { refreshToken: String }`
  - Response: `AuthResponse` (yeni access + refresh)
  - Refresh token DB'de saklanır (hash), kullanıldığında revoke + yeni üretilir
- [ ] **Auth Middleware** (Pipeline)
  - `Authorization: Bearer <accessToken>` header parse
  - JWT verify (signature, exp, issuer)
  - `request.context['user'] = UserContext { userId, role }`
  - Token geçersiz/süresi dolmuş → `401 Unauthorized`
- [ ] **Role Guard Middleware**
  - `@requireRole('Staff')` annotation veya middleware
  - Role uyuşmazsa → `403 Forbidden`

## Dokunulacak Dosyalar
```
packages/server/lib/src/
├── middleware/
│   ├── auth_middleware.dart
│   └── role_guard_middleware.dart
├── endpoint/
│   └── auth_endpoints.dart
├── service/
│   └── auth_service.dart (JWT create/verify, BCrypt)
├── dto/
│   ├── login_request.dart
│   ├── refresh_request.dart
│   └── auth_response.dart
└── config/
    └── jwt_config.dart (secret, expiry from env)
```

## Dokunulmayacak Dosyalar
- `packages/domain/` - User entity, Role enum
- `packages/application/` - AuthUseCase (yok, server'da direkt service)
- `packages/contracts/` - DTO'lar (contracts paketinde tanımlı, import edilir)
- `packages/infrastructure/` - UserRepository (inject edilir)

## Bağlı Testler
- `packages/server/test/auth_endpoints_test.dart`
  - `login_validCredentials_returnsTokens`
  - `login_wrongPassword_returns401`
  - `login_unknownUser_returns401` (timing attack prevention: aynı mesaj)
  - `refresh_validToken_returnsNewTokens`
  - `refresh_revokedToken_returns401`
  - `refresh_expiredToken_returns401`
  - `middleware_validToken_setsUserContext`
  - `middleware_expiredToken_returns401`
  - `roleGuard_staffRequiredStudentToken_returns403`

## Güvenlik Notları
- **BCrypt cost 12** (minimum)
- JWT secret: `JWT_ACCESS_SECRET`, `JWT_REFRESH_SECRET` (env, 32+ char random)
- Refresh token DB'de **bcrypt hash** ile saklanır
- Access token **payload'da şifre/email YOK** (sadece userId, role)
- Rate limit: Login/IP 5 req/dakika (middleware'de)

## Bağımlılık
- `campus_contracts` DTO'lar hazır olmalı
- `campus_infrastructure` UserRepositoryImpl hazır olmalı (Issue #3 bağımlılığı)
- `dart_jsonwebtoken` veya `package:jwt` paketi
- `bcrypt` paketi