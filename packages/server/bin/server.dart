import 'dart:io';

import 'package:campus_infrastructure/campus_infrastructure.dart';
import 'package:campus_server/src/service/auth_service.dart';
import 'package:campus_server/src/service/password_hasher.dart';
import 'package:campus_server/src/service/token_service.dart';
import 'package:campus_server/src/config/jwt_config.dart';
import 'package:campus_server/src/endpoint/auth_endpoints.dart';
import 'package:campus_server/src/endpoint/building_endpoints.dart';
import 'package:campus_server/src/endpoint/user_endpoints.dart';
import 'package:campus_server/src/logging/logger.dart';
import 'package:campus_server/src/middleware/audit_log_middleware.dart';
import 'package:campus_server/src/middleware/auth_middleware.dart';
import 'package:campus_server/src/middleware/rate_limit_middleware.dart';
import 'package:campus_server/src/middleware/request_log_middleware.dart';
import 'package:campus_server/src/middleware/security_headers_middleware.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_router/shelf_router.dart';

// CORS ayarlarını sağlayan middleware
Middleware corsHeaders() {
  return (Handler innerHandler) {
    return (Request request) async {
      if (request.method == 'OPTIONS') {
        return Response.ok(
          '',
          headers: {
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Methods':
                'GET, POST, PUT, DELETE, PATCH, OPTIONS',
            'Access-Control-Allow-Headers':
                'Origin, Content-Type, Authorization',
          },
        );
      }

      final response = await innerHandler(request);
      return response.change(
        headers: {
          'Access-Control-Allow-Origin': '*',
          'Access-Control-Allow-Methods':
              'GET, POST, PUT, DELETE, PATCH, OPTIONS',
          'Access-Control-Allow-Headers': 'Origin, Content-Type, Authorization',
        },
      );
    };
  };
}

void main() async {
  final env = Platform.environment;
  final jwtConfig = JwtConfig.fromEnvironment(env);
  final databaseUrl = env['DATABASE_URL'];
  if (jwtConfig == null || databaseUrl == null || databaseUrl.isEmpty) {
    serverLog(
      'Sunucu açılamadı: DATABASE_URL, JWT_ACCESS_SECRET ve '
      'JWT_REFRESH_SECRET tanımlı olmalı (sırlar en az '
      '${JwtConfig.minSecretLength} karakter ve birbirinden farklı).',
    );
    exitCode = 1;
    return;
  }

  final db = Database.fromUrl(databaseUrl);
  final tokens = TokenService(jwtConfig);
  final auth = AuthEndpoints(
    AuthService(
      users: UserRepositoryImpl(db),
      sessions: SessionRepositoryImpl(db),
      tokens: tokens,
      hasher: PasswordHasher(),
    ),
  );
  final users = UserEndpoints(UserRepositoryImpl(db));
  final buildings = BuildingEndpoints(BuildingRepositoryImpl(db));
  final protected = const Pipeline()
      .addMiddleware(authMiddleware(tokens))
      .addMiddleware(auditLog())
      .addHandler(
        Cascade().add(users.router.call).add(buildings.router.call).handler,
      );

  final health = Router()
    ..get('/health', (Request request) => Response.ok('OK'));

  final clientKey = clientIpBehind(trustedProxiesFrom(env));
  final handler = const Pipeline()
      .addMiddleware(requestLog())
      .addMiddleware(corsHeaders())
      .addMiddleware(securityHeaders())
      .addMiddleware(rateLimit(RateLimitRule.general, keyOf: clientKey))
      .addMiddleware(
        rateLimit(RateLimitRule.login, appliesTo: _isLogin, keyOf: clientKey),
      )
      .addHandler(
        Cascade().add(health.call).add(auth.router.call).add(protected).handler,
      );

  final server = await io.serve(handler, InternetAddress.anyIPv4, 8080);
  serverLog('Server listening on port ${server.port}');
}

bool _isLogin(Request request) =>
    request.method == 'POST' && request.url.path == 'api/auth/login';
