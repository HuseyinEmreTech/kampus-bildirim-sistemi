import 'package:campus_infrastructure/campus_infrastructure.dart';
import 'package:shelf/shelf.dart';

import 'json_http.dart';

/// `400 VALIDATION_ERROR`; [field] hatalı alanın adıdır.
Response validationError(String message, String field) =>
    errorResponse(400, 'VALIDATION_ERROR', message, details: field);

/// Fotoğraf deposunun reddini istemciye anlatır. `default` dalı yok:
/// [PhotoError]'a yeni neden eklenince derleyici burayı gösterir.
Response photoRejected(PhotoError reason, String field) => switch (reason) {
  PhotoError.invalidFormat => validationError(
    'Fotoğraf yalnızca JPEG veya PNG olabilir.',
    field,
  ),
  PhotoError.sizeExceeded => validationError(
    'Fotoğraf 5 MB\'ı geçemez.',
    field,
  ),
  PhotoError.invalidReportId => validationError('Kimlik geçersiz.', 'id'),
};
