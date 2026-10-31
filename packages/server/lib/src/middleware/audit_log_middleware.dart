import 'package:shelf/shelf.dart';

import '../logging/logger.dart';
import 'auth_middleware.dart';

/// Veriyi değiştiren istek yöntemleri. GET yalnızca okur, kayda girmez.
const _mutatingMethods = {'POST', 'PUT', 'PATCH', 'DELETE'};

/// Denetim kaydı: veriyi değiştiren her isteği kimin yaptığı ve sonucuyla
/// birlikte yazar: `{"audit":true,"userId","method","path","status"}`.
/// [authMiddleware]'den sonra kullanılır; kullanıcı bilgisi ondan gelir.
Middleware auditLog({LogWriter? write}) {
  return (Handler inner) {
    return (Request request) async {
      final response = await inner(request);
      if (!_mutatingMethods.contains(request.method)) return response;

      final fields = {
        'audit': true,
        'userId': currentUser(request).userId,
        'method': request.method,
        'path': '/${request.url.path}',
        'status': response.statusCode,
      };
      if (write == null) {
        writeLog('info', fields);
      } else {
        writeLog('info', fields, write: write);
      }
      return response;
    };
  };
}
