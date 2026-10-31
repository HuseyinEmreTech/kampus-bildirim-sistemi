import 'package:campus_infrastructure/campus_infrastructure.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../http/json_http.dart';
import '../middleware/auth_middleware.dart';

/// `GET /api/users/me`: giriş yapan kullanıcının kendi bilgileri.
class UserEndpoints {
  UserEndpoints(this._users);

  final UserRepositoryImpl _users;

  Router get router => Router()..get('/api/users/me', _me);

  Future<Response> _me(Request request) async {
    final current = currentUser(request);
    final user = await _users.findById(current.userId);
    if (user == null) {
      return errorResponse(404, 'NOT_FOUND', 'Kullanıcı bulunamadı.');
    }
    return jsonResponse(200, {
      'userId': user.userId,
      'fullName': user.fullName,
      'email': user.email,
      'role': user.role,
    });
  }
}
