import 'package:campus_application/campus_application.dart';
import 'package:campus_domain/campus_domain.dart' show Failure, Success;
import 'package:campus_infrastructure/campus_infrastructure.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../exception/exception_mapper.dart';
import '../http/json_http.dart';
import '../http/multipart.dart';
import '../http/photo_responses.dart';
import '../middleware/auth_middleware.dart';
import '../middleware/role_guard_middleware.dart';

/// `PUT /api/reports/{id}/resolution`: görevli bildirimi "çözüldü" işaretler.
/// İstek `multipart/form-data`: `resolutionPhoto` (zorunlu, Rule 04) ve
/// `note` (isteğe bağlı). Fotoğraf [LocalFileStorage] ile kaydedilir (tür
/// imzadan, 5 MB sınırı, EXIF temizlenir); kurallar [ReportResolveUseCase]'te.
class ReportResolutionEndpoint {
  ReportResolutionEndpoint({
    required this._resolveReport,
    required this._photos,
  });

  final ReportResolveUseCase _resolveReport;
  final LocalFileStorage _photos;

  /// Çözüm notunun en büyük boyutu (bayt).
  static const maxNoteBytes = 2000;
  static const photoField = 'resolutionPhoto';
  static const noteField = 'note';

  Router get router => Router()
    ..put(
      '/api/reports/<id>/resolution',
      const Pipeline().addMiddleware(requireRole('Staff')).addHandler(_resolve),
    );

  Future<Response> _resolve(Request request) async {
    final reportId = request.params['id']!;
    final boundary = multipartBoundary(request);
    if (boundary == null) {
      return validationError(
        'İstek multipart/form-data olmalı.',
        'content-type',
      );
    }

    StoredPhoto? photo;
    String? note;
    Response? rejected;
    await for (final part in formParts(request, boundary)) {
      if (part.name == noteField && rejected == null) {
        note = await readTextField(part.body, maxNoteBytes);
        if (note == null) {
          rejected = validationError(
            'Not en fazla $maxNoteBytes bayt olabilir.',
            'note',
          );
        }
      } else if (part.name == photoField && photo == null && rejected == null) {
        final saved = await _photos.save(
          reportId,
          part.body,
          part.contentType ?? '',
        );
        switch (saved) {
          case PhotoSaved(photo: final stored):
            photo = stored;
          case PhotoRejected(:final reason):
            rejected = photoRejected(reason, photoField);
        }
      } else {
        await part.body.drain<void>();
      }
    }

    if (rejected != null) {
      await _discard(photo);
      return rejected;
    }

    final user = currentUser(request);
    final result = await _resolveReport.execute(
      ResolveReportCommand(
        reportId: reportId,
        assigneeId: user.userId,
        role: user.role,
        resolutionPhotoUrl: photo?.url,
        resolutionPhotoContentType: photo?.contentType,
        resolutionPhotoSizeBytes: photo?.sizeBytes,
        note: note,
      ),
    );
    switch (result) {
      case Success():
        return jsonResponse(200, {'reportId': reportId, 'status': 'Cozuldu'});
      case Failure(:final error):
        // Kural reddettiyse kaydedilen fotoğraf diskte sahipsiz kalmasın.
        await _discard(photo);
        return appErrorResponse(error);
    }
  }

  Future<void> _discard(StoredPhoto? photo) async {
    if (photo != null) await _photos.delete(photo.url);
  }
}
