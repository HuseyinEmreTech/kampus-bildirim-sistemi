import 'dart:io';

/// Sunucu tarafı için en küçük ortak günlük kaydı.
///
/// Henüz `logging` gibi bir paket eklenmedi; gerektiğinde seviye ve
/// çıkış hedefi buradan değişir.
void serverLog(String message) {
  final now = DateTime.now().toUtc().toIso8601String();
  stdout.writeln('[$now] $message');
}
