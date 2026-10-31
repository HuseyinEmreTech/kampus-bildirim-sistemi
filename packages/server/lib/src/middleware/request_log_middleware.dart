import 'dart:math';

import 'package:shelf/shelf.dart';

import '../logging/logger.dart';

/// Yanıtta ve günlükte isteği eşleştirmek için kullanılan başlık.
const requestIdHeader = 'x-request-id';

/// İstek kimliğinin bayt sayısı (16 karakter onaltılık).
const _requestIdBytes = 8;

/// Her isteği tek satır JSON olarak günlüğe yazar:
/// `{"time","level","requestId","method","path","status","durationMs"}`.
///
/// Gizlilik için yalnızca yol yazılır; sorgu, başlık ve gövde (parola,
/// belirteç) günlüğe girmez. 5xx yanıtlar `error`, diğerleri `info` seviyesidir.
Middleware requestLog({
  LogWriter? write,
  DateTime Function() now = DateTime.now,
  Random? random,
}) {
  final rng = random ?? Random.secure();
  void log(String level, Map<String, Object?> fields) => write == null
      ? writeLog(level, fields, now: now)
      : writeLog(level, fields, write: write, now: now);

  return (Handler inner) {
    return (Request request) async {
      final requestId = _newRequestId(rng);
      final started = now();
      Map<String, Object?> fields(int status) => {
        'requestId': requestId,
        'method': request.method,
        'path': '/${request.url.path}',
        'status': status,
        'durationMs': now().difference(started).inMilliseconds,
      };

      try {
        final response = await inner(request);
        final level = response.statusCode >= 500 ? 'error' : 'info';
        log(level, fields(response.statusCode));
        return response.change(headers: {requestIdHeader: requestId});
      } catch (error) {
        // Beklenmeyen hata: kaydedilir, shelf yine 500 döner.
        log('error', {...fields(500), 'error': error.runtimeType.toString()});
        rethrow;
      }
    };
  };
}

String _newRequestId(Random rng) => List.generate(
  _requestIdBytes,
  (_) => rng.nextInt(256).toRadixString(16).padLeft(2, '0'),
).join();
