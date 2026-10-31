import 'dart:convert';

import 'package:campus_application/campus_application.dart';
import 'package:campus_infrastructure/campus_infrastructure.dart';
import 'package:campus_server/src/endpoint/report_resolution_endpoint.dart';
import 'package:campus_server/src/middleware/auth_middleware.dart';
import 'package:campus_server/src/service/token_service.dart';
import 'package:shelf/shelf.dart';
import 'package:test/test.dart';

import '../support/fake_photos.dart';
import '../support/fake_report_repository.dart';
import '../support/multipart_body.dart';
import '../support/test_values.dart';

const otherStaffId = 'a0000000-0000-4000-8000-000000000004';
const jpeg = [0xFF, 0xD8, 0xFF, 0xE0, 1, 2, 3, 4];

final tokens = TokenService(testJwtConfig);
final staffToken = tokens.createAccessToken(staffId, 'Staff');

late FakeReportRepository reports;
late FakePhotos photos;
late Handler app;
late String reportId;

void main() {
  setUp(() {
    reports = FakeReportRepository()
      ..stored = assignedReport(studentId, staffId);
    reportId = reports.stored!.id.value;
    photos = FakePhotos();
    app = const Pipeline()
        .addMiddleware(authMiddleware(tokens))
        .addHandler(
          ReportResolutionEndpoint(
            resolveReport: ReportResolveUseCase(reports),
            photos: photos,
          ).router.call,
        );
  });

  test('resolve_assigneeWithPhotoAndNote_returns200', () async {
    final res = await app(
      _resolve(staffToken, [
        textPart('note', 'Lamba değiştirildi.'),
        filePart('resolutionPhoto', 'image/jpeg', jpeg),
      ]),
    );

    expect(res.statusCode, 200);
    expect(jsonDecode(await res.readAsString()), {
      'reportId': reportId,
      'status': 'Cozuldu',
    });
    expect(reports.lastResolve, (
      reportId: reportId,
      photoUrl: photos.saved.single,
      note: 'Lamba değiştirildi.',
    ));
    expect(photos.deleted, isEmpty);
  });

  test('resolve_withoutPhoto_returns400', () async {
    // Rule 04: sonuç fotoğrafı zorunlu.
    final res = await app(_resolve(staffToken, [textPart('note', 'Bitti')]));

    expect(res.statusCode, 400);
    expect((await _errorOf(res))['details'], 'resolutionPhoto');
    expect(reports.lastResolve, isNull);
  });

  test('resolve_byOtherStaff_returns403AndDeletesPhoto', () async {
    // Rule 03: yalnızca üstlenen görevli çözebilir.
    final other = tokens.createAccessToken(otherStaffId, 'Staff');
    final res = await app(
      _resolve(other, [filePart('resolutionPhoto', 'image/jpeg', jpeg)]),
    );

    expect(res.statusCode, 403);
    expect(photos.deleted, photos.saved);
    expect(reports.lastResolve, isNull);
  });

  test('resolve_reportNotAssigned_returns409AndDeletesPhoto', () async {
    reports.stored = newReport(studentId);

    final res = await app(
      _resolve(staffToken, [filePart('resolutionPhoto', 'image/jpeg', jpeg)]),
    );

    expect(res.statusCode, 409);
    expect((await _errorOf(res))['code'], 'INVALID_TRANSITION');
    expect(photos.deleted, photos.saved);
  });

  test('resolve_photoTooLarge_returns400', () async {
    photos.nextReject = PhotoError.sizeExceeded;

    final res = await app(
      _resolve(staffToken, [filePart('resolutionPhoto', 'image/jpeg', jpeg)]),
    );

    expect(res.statusCode, 400);
    expect((await _errorOf(res))['details'], 'resolutionPhoto');
    expect(reports.lastResolve, isNull);
  });

  test('resolve_noteTooLong_returns400', () async {
    final res = await app(
      _resolve(staffToken, [
        textPart('note', 'a' * (ReportResolutionEndpoint.maxNoteBytes + 1)),
        filePart('resolutionPhoto', 'image/jpeg', jpeg),
      ]),
    );

    expect(res.statusCode, 400);
    expect((await _errorOf(res))['details'], 'note');
    expect(photos.saved, isEmpty);
  });

  test('resolve_notMultipart_returns400', () async {
    final res = await app(
      Request(
        'PUT',
        Uri.parse('http://localhost/api/reports/$reportId/resolution'),
        body: '{}',
        headers: {
          'authorization': 'Bearer $staffToken',
          'content-type': 'application/json',
        },
      ),
    );

    expect(res.statusCode, 400);
  });

  test('resolve_byStudent_returns403', () async {
    final student = tokens.createAccessToken(studentId, 'Student');
    final res = await app(
      _resolve(student, [filePart('resolutionPhoto', 'image/jpeg', jpeg)]),
    );

    expect(res.statusCode, 403);
    expect(photos.saved, isEmpty);
  });

  test('resolve_withoutToken_returns401', () async {
    final res = await app(_resolve(null, []));

    expect(res.statusCode, 401);
  });
}

Request _resolve(String? token, List<TestPart> parts) => multipartRequest(
  'PUT',
  '/api/reports/$reportId/resolution',
  parts,
  token: token,
);

Future<Map<String, Object?>> _errorOf(Response res) async {
  final body = jsonDecode(await res.readAsString()) as Map<String, Object?>;
  return body['error']! as Map<String, Object?>;
}
