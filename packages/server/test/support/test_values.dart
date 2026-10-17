import 'package:campus_server/src/config/jwt_config.dart';

// Testlerde kullanılan sahte değerler. Gerçek sır değildir.

const testAccessSecret = 'test-access-secret-en-az-otuz-iki-karakter';
const testRefreshSecret = 'test-refresh-secret-en-az-otuz-iki-karakter';
const testPassword = 'Demo.1234';
const studentId = 'a0000000-0000-4000-8000-000000000001';
const staffId = 'a0000000-0000-4000-8000-000000000003';

const testJwtConfig = JwtConfig(
  accessSecret: testAccessSecret,
  refreshSecret: testRefreshSecret,
);

/// Eksi ömür: üretilen belirtecin süresi zaten dolmuştur.
const expiredJwtConfig = JwtConfig(
  accessSecret: testAccessSecret,
  refreshSecret: testRefreshSecret,
  accessLifetime: Duration(minutes: -1),
  refreshLifetime: Duration(minutes: -1),
);

/// Başka bir sırla imzalanmış (sahte) belirteç üretmek için.
const otherJwtConfig = JwtConfig(
  accessSecret: 'baska-bir-access-sirri-en-az-otuz-iki-karakter',
  refreshSecret: 'baska-bir-refresh-sirri-en-az-otuz-iki-karakter',
);
