import '../../../shared/photo/photo_picker.dart';
import 'report_list_item.dart';

/// Açıklamanın en az ve en çok karakter sayısı (05-api-design: VALIDATION_ERROR).
const reportDescriptionMinLength = 5;
const reportDescriptionMaxLength = 500;

/// Öğrencinin oluşturma ekranında doldurduğu bildirim.
///
/// Konum #21'in sonraki parçasında eklenecek.
class NewReport {
  const NewReport({
    required this.category,
    required this.description,
    required this.photo,
  });

  final ReportCategory category;
  final String description;

  /// Sorunun fotoğrafı (USR 01; Rule 07: JPEG/PNG, en fazla 5 MB).
  final PickedPhoto photo;
}
