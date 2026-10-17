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
    'ariza' => const Success(Category.ariza),
    'temizlik' => const Success(Category.temizlik),
    'guvenlik' => const Success(Category.guvenlik),
    'diger' => const Success(Category.diger),
    _ => const Failure(InvalidDescription('kategori geçersiz')),
  };
}

Result<Role, DomainError> parseRole(String value) {
  final lowered = value.trim().toLowerCase();
  return switch (lowered) {
    'student' => const Success(Role.student),
    'staff' => const Success(Role.staff),
    _ => const Failure(InvalidRole()),
  };
}

Result<ReportStatus, DomainError> parseReportStatus(String value) {
  final lowered = value.trim().toLowerCase();
  return switch (lowered) {
    'yeni' => const Success(ReportStatus.yeni),
    'ustlenildi' => const Success(ReportStatus.ustlenildi),
    'cozuldu' => const Success(ReportStatus.cozuldu),
    _ => const Failure(InvalidTransition()),
  };
}
