import '../core/domain_error.dart';
import '../core/result.dart';

enum Role { student, staff }

enum Category { ariza, temizlik, guvenlik, diger }

enum ReportStatus { yeni, ustlenildi, cozuldu }

enum LocationSource { gps, building }

enum NotificationType { reportResolved }

Result<Category, DomainError> parseCategory(String value) {
  final lowered = value.trim().toLowerCase();
  return switch (lowered) {
    'ariza' => Success(Category.ariza),
    'temizlik' => Success(Category.temizlik),
    'guvenlik' => Success(Category.guvenlik),
    'diger' => Success(Category.diger),
    _ => const Failure(InvalidDescription('kategori geçersiz')),
  };
}

Result<Role, DomainError> parseRole(String value) {
  final lowered = value.trim().toLowerCase();
  return switch (lowered) {
    'student' => Success(Role.student),
    'staff' => Success(Role.staff),
    _ => const Failure(InvalidRole()),
  };
}

Result<ReportStatus, DomainError> parseReportStatus(String value) {
  final lowered = value.trim().toLowerCase();
  return switch (lowered) {
    'yeni' => Success(ReportStatus.yeni),
    'ustlenildi' => Success(ReportStatus.ustlenildi),
    'cozuldu' => Success(ReportStatus.cozuldu),
    _ => const Failure(InvalidTransition()),
  };
}
