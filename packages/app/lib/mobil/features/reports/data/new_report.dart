import 'report_list_item.dart';

/// Açıklamanın en az ve en çok karakter sayısı (05-api-design: VALIDATION_ERROR).
const reportDescriptionMinLength = 5;
const reportDescriptionMaxLength = 500;

/// Öğrencinin oluşturma ekranında doldurduğu bildirim.
///
/// Fotoğraf ve konum #21'in sonraki parçasında eklenecek.
class NewReport {
  const NewReport({required this.category, required this.description});

  final ReportCategory category;
  final String description;
}
