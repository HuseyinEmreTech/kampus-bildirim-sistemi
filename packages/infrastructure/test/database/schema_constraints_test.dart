// Gerçek PostgreSQL ister: DATABASE_URL ortam değişkeni (README §10, .env.example).
// V5 kısıtları: uygulama bir kuralı atlasa bile veritabanı bozuk satırı kabul etmez.
@Tags(['db'])
library;

import 'dart:io';

import 'package:campus_infrastructure/campus_infrastructure.dart';
import 'package:postgres/postgres.dart' show ServerException;
import 'package:test/test.dart';

// Seed ve diğer test dosyalarıyla çakışmayan sabit kimlikler.
const _student = 'a0000000-0000-4000-8000-0000000000f1';
const _staff = 'a0000000-0000-4000-8000-0000000000f2';
const _report = 'c0000000-0000-4000-8000-0000000000f2';
const _emailCheckUser = 'a0000000-0000-4000-8000-0000000000f3';

// Rule 07: 5 MB.
const _maxPhotoBytes = 5 * 1024 * 1024;

const _insertUser = r'''
INSERT INTO users (user_id, full_name, email, password_hash, role)
VALUES ($1, 'Kisit Testi', $2, 'test-hash', $3)
''';

const _insertReport = r'''
INSERT INTO reports (report_id, reporter_id, category, description, photo_url,
  photo_content_type, photo_size_bytes, latitude, longitude, location_source)
VALUES ($1, $2, 'Ariza', 'Kisit testi', '/files/k.jpg', 'image/jpeg', $3,
  36.58, 36.17, 'Gps')
''';

// Üstlenme zamanını oluşma zamanına göre [$3] saniye kaydırır.
const _takeReport = r'''
UPDATE reports SET status = 'Ustlenildi', assignee_id = $2,
  taken_at = created_at + make_interval(secs => $3)
WHERE report_id = $1
''';

// Çözülme zamanını üstlenme zamanına göre [$2] saniye kaydırır.
const _resolveReport = r'''
UPDATE reports SET status = 'Cozuldu', resolved_at = taken_at + make_interval(secs => $2),
  resolution_photo_url = '/files/s.jpg', resolution_photo_content_type = 'image/jpeg',
  resolution_photo_size_bytes = $3
WHERE report_id = $1
''';

const _insertHistory = r'''
INSERT INTO status_history (report_id, from_status, to_status, changed_by)
VALUES ($1, $2, $3, $4)
''';

Future<void> _deleteFixtures(Database db) async {
  await db.execute(r'DELETE FROM status_history WHERE report_id = $1', [
    _report,
  ]);
  await db.execute(r'DELETE FROM reports WHERE report_id = $1', [_report]);
  await db.execute(r'DELETE FROM users WHERE user_id IN ($1, $2, $3)', [
    _student,
    _staff,
    _emailCheckUser,
  ]);
}

Matcher _violates(String constraint) => throwsA(
  isA<ServerException>()
      .having((e) => e.code, 'code', '23514')
      .having((e) => e.constraintName, 'constraint', constraint),
);

void main() {
  final url = Platform.environment['DATABASE_URL'];

  group('V5 kısıtları', () {
    late Database db;

    setUpAll(() => db = Database.fromUrl(url!));
    tearDownAll(() => db.close());

    setUp(() async {
      await _deleteFixtures(db);
      await db.execute(_insertUser, [
        _student,
        'kisit.ogr@test.edu',
        'Student',
      ]);
      await db.execute(_insertUser, [_staff, 'kisit.gor@test.edu', 'Staff']);
    });
    tearDown(() => _deleteFixtures(db));

    // Rule 07: depolama katmanı sınırı zaten uyguluyor; veritabanı ikinci kilit.
    test('photoSize_overFiveMegabytes_rejected', () async {
      await expectLater(
        db.execute(_insertReport, [_report, _student, _maxPhotoBytes + 1]),
        _violates('reports_photo_size_max'),
      );
    });

    test('photoSize_exactlyFiveMegabytes_accepted', () async {
      await db.execute(_insertReport, [_report, _student, _maxPhotoBytes]);
    });

    test('resolutionPhotoSize_overFiveMegabytes_rejected', () async {
      await db.execute(_insertReport, [_report, _student, 1]);
      await db.execute(_takeReport, [_report, _staff, 1]);

      await expectLater(
        db.execute(_resolveReport, [_report, 1, _maxPhotoBytes + 1]),
        _violates('reports_resolution_photo_size_max'),
      );
    });

    test('takenAt_beforeCreatedAt_rejected', () async {
      await db.execute(_insertReport, [_report, _student, 1]);

      await expectLater(
        db.execute(_takeReport, [_report, _staff, -1]),
        _violates('reports_taken_after_created'),
      );
    });

    test('resolvedAt_beforeTakenAt_rejected', () async {
      await db.execute(_insertReport, [_report, _student, 1]);
      await db.execute(_takeReport, [_report, _staff, 1]);

      await expectLater(
        db.execute(_resolveReport, [_report, -1, 1]),
        _violates('reports_resolved_after_taken'),
      );
    });

    // Aynı işlemde (transaction) yazılan zamanlar eşit olabilir; bu geçerlidir.
    test('timestamps_equal_accepted', () async {
      await db.execute(_insertReport, [_report, _student, 1]);
      await db.execute(_takeReport, [_report, _staff, 0]);
      await db.execute(_resolveReport, [_report, 0, 1]);
    });

    // Rule 05: yalnızca diyagramdaki geçişler geçmişe yazılabilir.
    test('history_diagramTransitions_accepted', () async {
      await db.execute(_insertReport, [_report, _student, 1]);

      await db.execute(_insertHistory, [_report, null, 'Yeni', _student]);
      await db.execute(_insertHistory, [_report, 'Yeni', 'Ustlenildi', _staff]);
      await db.execute(_insertHistory, [
        _report,
        'Ustlenildi',
        'Cozuldu',
        _staff,
      ]);
    });

    test('history_transitionsOutsideDiagram_rejected', () async {
      await db.execute(_insertReport, [_report, _student, 1]);

      for (final (from, to) in [
        ('Yeni', 'Cozuldu'),
        ('Cozuldu', 'Yeni'),
        ('Ustlenildi', 'Yeni'),
        ('Yeni', 'Yeni'),
        (null, 'Ustlenildi'),
      ]) {
        await expectLater(
          db.execute(_insertHistory, [_report, from, to, _staff]),
          _violates('status_history_valid_transition'),
          reason: '$from -> $to',
        );
      }
    });

    test('email_withoutAtOrWithSpace_rejected', () async {
      for (final email in ['kisit.test.edu', 'kisit @test.edu', '@test.edu']) {
        await expectLater(
          db.execute(_insertUser, [_emailCheckUser, email, 'Student']),
          _violates('users_email_format'),
          reason: email,
        );
      }
    });
  }, skip: url == null ? 'DATABASE_URL tanımlı değil' : false);
}
