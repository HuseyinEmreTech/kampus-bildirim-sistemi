import 'package:postgres/postgres.dart';

/// Sağlık kontrolünde veritabanının cevap vermesi için beklenen en uzun süre.
const healthCheckTimeout = Duration(seconds: 2);

/// PostgreSQL bağlantı havuzu. Repository'ler bütün sorgularını buradan çalıştırır.
///
/// SQL yalnızca `$1`, `$2` parametreleriyle yazılır; değer SQL metnine eklenmez.
class Database {
  /// Hazır bir havuzla kurar. Uygulamada [Database.fromUrl] kullanılır; bu yapıcı
  /// testlerde sahte havuz vermek içindir (veritabanı olmadan birim test).
  Database(this._pool);

  final Pool<Object?> _pool;

  /// Havuzu bağlantı adresinden kurar. Örnek (`.env.example`):
  /// `postgres://campus:sifre@localhost:5440/campus?sslmode=disable&max_connection_count=10&connect_timeout=5&query_timeout=10`
  ///
  /// - `sslmode=disable`: yerel PostgreSQL'de SSL yok; paket varsayılan olarak SSL ister.
  /// - `max_connection_count`: havuzdaki en fazla bağlantı; verilmezse paket 1 kullanır.
  /// - `connect_timeout`: bağlanmak için en fazla saniye; verilmezse 15.
  /// - `query_timeout`: bir sorgu için en fazla saniye; verilmezse 5 dakika. Süre
  ///   dolunca paket sorguyu sunucuda da iptal eder ve bağlantı havuza döner.
  factory Database.fromUrl(String url) => Database(Pool.withUrl(url));

  /// Tek sorgu çalıştırır. Sonuçtaki `affectedRows`, değişen satır sayısıdır.
  Future<Result> execute(String sql, [List<Object?> parameters = const []]) =>
      _pool.execute(sql, parameters: parameters);

  /// [action] içindeki sorgular tek işlemdir: hata olursa hepsi geri alınır.
  Future<T> transaction<T>(Future<T> Function(TxSession tx) action) =>
      _pool.runTx(action);

  /// Veritabanı şu an cevap veriyor mu? Sunucunun `/health` ucu içindir.
  /// Bağlantı kurulamazsa ya da [timeout] içinde cevap gelmezse hata fırlatmaz,
  /// `false` döner.
  Future<bool> isReachable({Duration timeout = healthCheckTimeout}) async {
    try {
      // Süre sorguya da verilir: aşılırsa paket sorguyu sunucuda iptal eder ve
      // bağlantı havuza döner. Dıştaki sınır havuzda boş yer beklemeyi de keser.
      await _pool.execute('SELECT 1', timeout: timeout).timeout(timeout);
      return true;
    } on Exception {
      return false;
    }
  }

  /// Havuzdaki bütün bağlantıları kapatır.
  Future<void> close() => _pool.close();
}
