import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../service/auth_service.dart';
import '../dto/auth_response.dart';
import '../dto/login_request.dart';
import '../dto/refresh_request.dart';
import '../http/json_http.dart';

/// `/api/auth/login` ve `/api/auth/refresh`. İş mantığı [AuthService]'tedir;
/// burası yalnızca HTTP isteğini okur ve sonucu HTTP yanıtına çevirir.
class AuthEndpoints {
  AuthEndpoints(this._auth);

  final AuthService _auth;

  Router get router => Router()
    ..post('/api/auth/login', _login)
    ..post('/api/auth/refresh', _refresh);

  Future<Response> _login(Request request) async {
    final json = await readJsonObject(request);
    final body = json == null ? null : LoginRequest.fromJson(json);
    if (body == null) {
      return _validationError('E-posta ve parola zorunlu.', 'email,password');
    }
    return _toResponse(await _auth.login(body.email, body.password));
  }

  Future<Response> _refresh(Request request) async {
    final json = await readJsonObject(request);
    final body = json == null ? null : RefreshRequest.fromJson(json);
    if (body == null) {
      return _validationError('refreshToken zorunlu.', 'refreshToken');
    }
    return _toResponse(await _auth.refresh(body.refreshToken));
  }

  Response _toResponse(AuthOutcome outcome) => switch (outcome) {
    AuthSuccess(:final accessToken, :final refreshToken, :final user) =>
      jsonResponse(
        200,
        AuthResponse(
          accessToken: accessToken,
          refreshToken: refreshToken,
          user: user,
        ).toJson(),
      ),
    AuthFailure(:final reason) => _failure(reason),
  };

  Response _failure(AuthFailureReason reason) => switch (reason) {
    AuthFailureReason.invalidCredentials => errorResponse(
      401,
      'INVALID_CREDENTIALS',
      'E-posta veya parola hatalı.',
    ),
    AuthFailureReason.invalidRefreshToken => errorResponse(
      401,
      'UNAUTHORIZED',
      'Oturum geçersiz, tekrar giriş yapın.',
    ),
  };

  Response _validationError(String message, String details) =>
      errorResponse(400, 'VALIDATION_ERROR', message, details: details);
}
