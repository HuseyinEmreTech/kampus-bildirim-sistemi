import '../../../shared/location/location_source.dart';
import '../../../shared/photo/photo_picker.dart';
import 'report_list_item.dart';

/// Açıklamanın en az ve en çok karakter sayısı (05-api-design: VALIDATION_ERROR).
const reportDescriptionMinLength = 5;
const reportDescriptionMaxLength = 500;

/// Öğrencinin oluşturma ekranında doldurduğu bildirim (USR 01).
class NewReport {
  const NewReport({
    required this.category,
    required this.description,
    required this.photo,
    required this.location,
    required this.place,
  });

  final ReportCategory category;
  final String description;

  /// Sorunun fotoğrafı (USR 01; Rule 07: JPEG/PNG, en fazla 5 MB).
  final PickedPhoto photo;

  /// GPS noktası ya da bina; kampüs sınırını sunucu denetler (Rule 06).
  final LocationChoice location;

  /// Yer tarifi, ör. "B Blok 2. kat" (05-api-design: `place`).
  final String place;
}
