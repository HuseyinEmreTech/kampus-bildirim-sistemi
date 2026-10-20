import 'package:shelf/shelf.dart';

import '../service/token_service.dart';
import '../http/json_http.dart';

/// `request.context` içinde kullanıcı bilgisinin anahtarı.
const userContextKey = 'user';

const _bearerPrefix = 'Bearer ';

/// İstekteki kullanıcı bilgisi. [authMiddleware] arkasındaki
/// handler'larda her zaman doludur.
UserContext currentUser(Request request) =>
    request.context[userContextKey]! as UserContext;

/// `Authorization: Bearer <erişim belirteci>` başlığını doğrular.
/// Geçerliyse kullanıcıyı `request.context['user']` içine koyar,
/// değilse 401 döner.
Middleware authMiddleware(TokenService tokens) {
  return (Handler inner) {
    return (Request request) {
      final header = request.headers['authorization'];
      if (header == null || !header.startsWith(_bearerPrefix)) {
        return _unauthorized();
      }
      final user = tokens.verifyAccessToken(
        header.substring(_bearerPrefix.length).trim(),
      );
      if (user == null) return _unauthorized();
      return inner(request.change(context: {userContextKey: user}));
    };
  };
}

Response _unauthorized() =>
    errorResponse(401, 'UNAUTHORIZED', 'Giriş yapmanız gerekiyor.');
