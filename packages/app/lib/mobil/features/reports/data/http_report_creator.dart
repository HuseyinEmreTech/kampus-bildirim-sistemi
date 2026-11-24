import '../../../shared/api/api_client.dart';
import '../../../shared/api/multipart.dart';
import '../../../shared/location/location_source.dart';
import 'new_report.dart';
import 'report_creator.dart';
import 'report_json.dart';

/// Sunucunun kullanıcıya gösterilecek mesajla reddettiği durumlar
/// (doğrulama, kural, fotoğraf boyutu); üstlenme ve çözme de kullanır.
const rejectedStatuses = {400, 403, 404, 409, 413, 422};

/// Yeni bildirim: `POST /api/reports`, `multipart/form-data` (Çağdaş #121):
/// `photo`, `category`, `description`, `locationSource` (`Gps` ya da
/// `Building`), `latitude`/`longitude` ya da `buildingId`, `place`.
class HttpReportCreator implements ReportCreator {
  HttpReportCreator(this._api);

  final ApiClient _api;

  @override
  Future<ReportCreateResult> create(NewReport report) async {
    final response = await _api.send(
      multipartRequest(
        'POST',
        _api.url('/api/reports'),
        fields: {
          'category': categoryToJson(report.category),
          'description': report.description,
          'place': ?report.place,
          ..._locationFields(report.location),
        },
        fileField: 'photo',
        fileBytes: report.photo.bytes,
        fileContentType: report.photo.contentType,
        fileName: photoFileName(report.photo.contentType),
      ),
    );
    return switch (response) {
      ApiSuccess() => const ReportCreated(),
      ApiError(:final status, :final message)
          when rejectedStatuses.contains(status) =>
        ReportRejected(message),
      ApiError() || ApiUnreachable() => const ReportCreateFailed(),
    };
  }

  Map<String, String> _locationFields(LocationChoice location) =>
      switch (location) {
        GpsChoice(:final latitude, :final longitude) => {
          'locationSource': 'Gps',
          'latitude': '$latitude',
          'longitude': '$longitude',
        },
        BuildingChoice(:final building) => {
          'locationSource': 'Building',
          'buildingId': building.id,
        },
      };
}
