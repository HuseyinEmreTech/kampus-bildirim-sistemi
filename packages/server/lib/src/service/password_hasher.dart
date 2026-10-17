import 'package:bcrypt/bcrypt.dart';

/// Parola özeti (bcrypt). Parola hiçbir yerde düz metin saklanmaz.
class PasswordHasher {
  /// [cost] bcrypt'in iş yükü; her +1 süreyi iki katına çıkarır.
  /// Testlerde hız için küçük değer verilir.
  PasswordHasher({this.cost = defaultCost})
    : _dummyHash = BCrypt.hashpw(
        'kullanici-yok',
        BCrypt.gensalt(logRounds: cost),
      );

  /// Issue #5: en az 12.
  static const defaultCost = 12;

  final int cost;

  /// Kullanıcı bulunamadığında da aynı sürede cevap vermek için
  /// karşılaştırılan sahte özet (zamanlama saldırısını önler).
  final String _dummyHash;

  String hash(String password) =>
      BCrypt.hashpw(password, BCrypt.gensalt(logRounds: cost));

  /// Parola özetle eşleşiyorsa `true`.
  bool verify(String password, String hash) => BCrypt.checkpw(password, hash);

  /// Kullanıcı yokken çağrılır: yine bir bcrypt karşılaştırması yapar ve
  /// her zaman `false` döner.
  bool verifyAgainstDummy(String password) {
    BCrypt.checkpw(password, _dummyHash);
    return false;
  }
}
