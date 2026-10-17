import 'package:campus_domain/campus_domain.dart';
import 'package:test/test.dart';

void main() {
  group('parseCategory', () {
    test('validCategory_returnsSuccess', () {
      expect(parseCategory('Ariza'), isA<Success<Category, DomainError>>());
    });

    test('invalidCategory_returnsFailure', () {
      expect(parseCategory('Yok'), isA<Failure<Category, DomainError>>());
    });
  });

  group('parseRole', () {
    test('validRole_returnsSuccess', () {
      expect(parseRole('Staff'), isA<Success<Role, DomainError>>());
    });

    test('invalidRole_returnsFailure', () {
      expect(parseRole('Admin'), isA<Failure<Role, DomainError>>());
    });
  });

  group('parseReportStatus', () {
    test('validStatus_returnsSuccess', () {
      expect(
        parseReportStatus('Yeni'),
        isA<Success<ReportStatus, DomainError>>(),
      );
    });

    test('invalidStatus_returnsFailure', () {
      expect(
        parseReportStatus('Kapandi'),
        isA<Failure<ReportStatus, DomainError>>(),
      );
    });
  });
}
