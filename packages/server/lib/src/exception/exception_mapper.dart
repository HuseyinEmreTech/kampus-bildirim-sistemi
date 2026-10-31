import 'package:campus_application/campus_application.dart';
import 'package:shelf/shelf.dart';

import '../http/json_http.dart';
import '../logging/logger.dart';

/// Uygulama katmanı hatasını ortak HTTP hata yanıtına çevirir
/// (proje-bilgileri/05-api-design.md, "Hata biçimi ve durum kodları").
/// `default` dalı yok: [AppError]'a yeni hata eklenince derleyici burayı
/// gösterir.
Response appErrorResponse(AppError error, {LogWriter? write}) =>
    switch (error) {
      ValidationError(:final field, :final message) => errorResponse(
        400,
        'VALIDATION_ERROR',
        message,
        details: field,
      ),
      UnauthorizedError() => errorResponse(
        401,
        'UNAUTHORIZED',
        'Giriş yapmanız gerekiyor.',
      ),
      ForbiddenError() => errorResponse(
        403,
        'FORBIDDEN',
        'Bu işlem için yetkiniz yok.',
      ),
      NotFoundError() => errorResponse(404, 'NOT_FOUND', 'Kayıt bulunamadı.'),
      ConflictError(:final reason) => errorResponse(
        409,
        'CONFLICT',
        'Bildirim zaten üstlenilmiş.',
        details: reason,
      ),
      InvalidTransitionError() => errorResponse(
        409,
        'INVALID_TRANSITION',
        'Bildirimin şu anki durumunda bu işlem yapılamaz.',
      ),
      MissingResolutionPhotoError() => errorResponse(
        400,
        'VALIDATION_ERROR',
        'Sonuç fotoğrafı zorunlu.',
        details: 'resolutionPhoto',
      ),
      UnknownError(:final message) => _internalError(message, write),
    };

/// Beklenmeyen hatanın ayrıntısı yalnızca sunucu günlüğüne yazılır;
/// istemciye iç bilgi (SQL, yığın) gönderilmez.
Response _internalError(String message, LogWriter? write) {
  final fields = {'message': message};
  if (write == null) {
    writeLog('error', fields);
  } else {
    writeLog('error', fields, write: write);
  }
  return errorResponse(500, 'INTERNAL_ERROR', 'Beklenmeyen bir hata oluştu.');
}
