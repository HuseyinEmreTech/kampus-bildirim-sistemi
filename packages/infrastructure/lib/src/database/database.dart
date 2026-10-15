import 'package:postgres/postgres.dart';

/// PostgreSQL bağlantı havuzu. Repository'ler bütün sorgularını buradan çalıştırır.
///
/// SQL yalnızca `$1`, `$2` parametreleriyle yazılır; değer SQL metnine eklenmez.
class Database {
  /// Hazır bir havuzla kurar. Uygulamada [Database.fromUrl] kullanılır; bu yapıcı
  /// testlerde sahte havuz vermek içindir (veritabanı olmadan birim test).
  Database(this._pool);

  final Pool<Object?> _pool;

  /// Havuzu bağlantı adresinden kurar. Örnek (`.env.example`):
  /// `postgres://campus:sifre@localhost:5440/campus?sslmode=disable&max_connection_count=10`
  ///
  /// - `sslmode=disable`: yerel PostgreSQL'de SSL yok; paket varsayılan olarak SSL ister.
  /// - `max_connection_count`: havuzdaki en fazla bağlantı; verilmezse paket 1 kullanır.
  factory Database.fromUrl(String url) => Database(Pool.withUrl(url));

  /// Tek sorgu çalıştırır. Sonuçtaki `affectedRows`, değişen satır sayısıdır.
  Future<Result> execute(String sql, [List<Object?> parameters = const []]) =>
      _pool.execute(sql, parameters: parameters);

  /// [action] içindeki sorgular tek işlemdir: hata olursa hepsi geri alınır.
  Future<T> transaction<T>(Future<T> Function(TxSession tx) action) =>
      _pool.runTx(action);

  /// Havuzdaki bütün bağlantıları kapatır.
  Future<void> close() => _pool.close();
}
