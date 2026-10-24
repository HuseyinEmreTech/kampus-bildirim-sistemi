import 'dart:async';
import 'dart:collection';

/// Aynı anda en fazla [maxRunning] işin çalışmasına izin verir; fazlası sırayla
/// bekler. Fotoğraf çözme gibi çok bellek isteyen işler aynı anda yüklenince
/// sunucunun belleği dolmasın diye kullanılır.
class ConcurrencyLimit {
  ConcurrencyLimit(this.maxRunning) : assert(maxRunning > 0);

  final int maxRunning;
  int _running = 0;
  final _waiting = Queue<Completer<void>>();

  /// Şu anda çalışan iş sayısı.
  int get running => _running;

  Future<T> run<T>(Future<T> Function() task) async {
    if (_running < maxRunning) {
      _running++;
    } else {
      // Yer açılınca biten iş sırayı doğrudan bekleyene devreder; sayaç değişmez.
      final turn = Completer<void>();
      _waiting.add(turn);
      await turn.future;
    }
    try {
      return await task();
    } finally {
      if (_waiting.isNotEmpty) {
        _waiting.removeFirst().complete();
      } else {
        _running--;
      }
    }
  }
}
