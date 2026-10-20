import 'package:shelf/shelf.dart';

import '../http/json_http.dart';
import '../service/token_service.dart';
import 'auth_middleware.dart';

/// Yalnızca [role] rolündeki kullanıcıyı geçirir, diğerlerine 403 döner.
/// [authMiddleware]'den sonra kullanılır. Örnek: `requireRole('Staff')`.
Middleware requireRole(String role) {
  return (Handler inner) {
    return (Request request) {
      final user = request.context[userContextKey];
      if (user is! UserContext) {
        return errorResponse(401, 'UNAUTHORIZED', 'Giriş yapmanız gerekiyor.');
      }
      if (user.role != role) {
        return errorResponse(403, 'FORBIDDEN', 'Bu işlem için yetkiniz yok.');
      }
      return inner(request);
    };
  };
}
