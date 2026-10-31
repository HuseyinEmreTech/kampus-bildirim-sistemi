import 'package:campus_application/campus_application.dart';
import 'package:campus_domain/campus_domain.dart'
    show Failure, ReportId, Success;
import 'package:campus_infrastructure/campus_infrastructure.dart';
import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../exception/exception_mapper.dart';
import '../http/json_http.dart';
import '../http/multipart.dart';
import '../http/photo_responses.dart';
import '../middleware/auth_middleware.dart';
import '../middleware/role_guard_middleware.dart';

/// `POST /api/reports`: öğrenci yeni bildirim oluşturur. İstek
/// `multipart/form-data`: `photo`, `category`, `description`,
/// `locationSource` (`Gps` ya da `Building`), `latitude`/`longitude` (Gps)
/// veya `buildingId` (Building), isteğe bağlı `place`. Kurallar
/// [ReportCreateUseCase]'te (Report.create); burası alanları okur, fotoğrafı
/// kaydeder ve bina kaynağında binanın var olduğunu denetler (Rule 06).
class ReportCreationEndpoint {
  ReportCreationEndpoint({
    required this._createReport,
    required this._photos,
    required this._buildings,
  });

  final ReportCreateUseCase _createReport;
  final LocalFileStorage _photos;
  final BuildingRepositoryImpl _buildings;

  /// Metin alanlarının en büyük boyutu (bayt). Açıklama en fazla 500
  /// karakterdir; Türkçe harfler 2 bayt tuttuğu için pay bırakıldı.
  static const maxFieldBytes = 2000;
  static const photoField = 'photo';
  static const textFields = {
    'category',
    'description',
    'locationSource',
    'latitude',
    'longitude',
    'place',
    'buildingId',
  };

  Router get router => Router()
    ..post(
      '/api/reports',
      const Pipeline()
          .addMiddleware(requireRole('Student'))
          .addHandler(_create),
    );

  Future<Response> _create(Request request) async {
    final boundary = multipartBoundary(request);
    if (boundary == null) {
      return validationError(
        'İstek multipart/form-data olmalı.',
        'content-type',
      );
    }

    final fields = <String, String>{};
    StoredPhoto? photo;
    Response? rejected;
    await for (final part in formParts(request, boundary)) {
      if (rejected != null) {
        await part.body.drain<void>();
      } else if (textFields.contains(part.name)) {
        final value = await readTextField(part.body, maxFieldBytes);
        if (value == null) {
          rejected = validationError('${part.name} çok uzun.', part.name);
        } else {
          fields[part.name] = value;
        }
      } else if (part.name == photoField && photo == null) {
        // Bildirimin kimliği kayıtta üretildiği için fotoğraf ayrı bir
        // yükleme kimliğiyle klasörlenir.
        final saved = await _photos.save(
          ReportId.generate().value,
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

    final response = rejected ?? await _save(request, fields, photo);
    if (response.statusCode != 201) await _discard(photo);
    return response;
  }

  Future<Response> _save(
    Request request,
    Map<String, String> fields,
    StoredPhoto? photo,
  ) async {
    for (final name in const ['category', 'description', 'locationSource']) {
      if ((fields[name] ?? '').trim().isEmpty) {
        return validationError('$name zorunlu.', name);
      }
    }
    if (photo == null) {
      return validationError('Fotoğraf zorunlu.', photoField);
    }

    final location = await _location(fields);
    if (location is Response) return location;
    final (latitude, longitude) = location as (double, double);

    final result = await _createReport.execute(
      CreateReportCommand(
        reporterId: currentUser(request).userId,
        category: fields['category']!,
        description: fields['description']!,
        photoUrl: photo.url,
        photoContentType: photo.contentType,
        photoSizeBytes: photo.sizeBytes,
        latitude: latitude,
        longitude: longitude,
        locationSource: fields['locationSource']!,
        place: fields['place'],
        buildingId: fields['buildingId'],
      ),
    );
    return switch (result) {
      Success(value: final id) => jsonResponse(201, {
        'reportId': id.value,
        'status': 'Yeni',
      }),
      Failure(:final error) => appErrorResponse(error),
    };
  }

  /// Gps'te gönderilen koordinatlar; Building'de seçilen binanın
  /// koordinatları. Hata varsa yanıtın kendisi döner.
  Future<Object> _location(Map<String, String> fields) async {
    if (fields['locationSource']!.trim().toLowerCase() == 'building') {
      final buildingId = fields['buildingId']?.trim() ?? '';
      if (buildingId.isEmpty) {
        return validationError(
          'Bina kaynağında buildingId zorunlu.',
          'buildingId',
        );
      }
      final building = await _buildings.findById(buildingId);
      if (building == null) {
        return errorResponse(
          422,
          'BUILDING_NOT_FOUND',
          'Seçilen bina bulunamadı.',
          details: 'buildingId',
        );
      }
      return (building.latitude, building.longitude);
    }

    final latitude = double.tryParse(fields['latitude'] ?? '');
    if (latitude == null) {
      return validationError('latitude sayı olmalı.', 'latitude');
    }
    final longitude = double.tryParse(fields['longitude'] ?? '');
    if (longitude == null) {
      return validationError('longitude sayı olmalı.', 'longitude');
    }
    return (latitude, longitude);
  }

  Future<void> _discard(StoredPhoto? photo) async {
    if (photo != null) await _photos.delete(photo.url);
  }
}
