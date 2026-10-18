import 'package:campus_app/mobil/features/reports/data/report_assigner.dart';
import 'package:campus_app/mobil/features/reports/data/report_detail.dart';
import 'package:campus_app/mobil/features/reports/data/report_detail_source.dart';
import 'package:campus_app/mobil/features/reports/data/report_list_item.dart';
import 'package:campus_app/mobil/features/reports/data/report_resolver.dart';
import 'package:campus_app/mobil/features/reports/presentation/staff/resolve_screen.dart';
import 'package:campus_app/mobil/features/reports/presentation/staff/staff_report_actions.dart';
import 'package:campus_app/mobil/features/reports/presentation/student/report_detail_screen.dart';
import 'package:campus_app/mobil/shared/photo/photo_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Sırayla verilen durumlarda detay döndüren sahte kaynak.
class FakeDetails implements ReportDetailSource {
  FakeDetails(this.statuses);

  final List<ReportStatus> statuses;

  @override
  Future<ReportDetailResult> fetch(String reportId) async => ReportDetailLoaded(
    ReportDetail(
      id: reportId,
      category: ReportCategory.ariza,
      status: statuses.removeAt(0),
      description: 'Koridor lambası yanmıyor',
      place: 'B Blok 2. kat',
      createdAt: DateTime(2026, 10, 18),
      photoUrl: 'https://ornek.test/demo.jpg',
      history: const [],
    ),
  );
}

class FakeAssigner implements ReportAssigner {
  final assigned = <String>[];

  @override
  Future<ReportAssignResult> assign(String reportId) async {
    assigned.add(reportId);
    return const ReportAssigned();
  }
}

class UnusedResolver implements ReportResolver {
  @override
  Future<ReportResolveResult> resolve({
    required String reportId,
    required PickedPhoto photo,
    String? note,
  }) async => const ReportResolveFailed();
}

class UnusedPicker implements PhotoPicker {
  @override
  Future<PhotoPickResult> pick(PhotoSource source) async =>
      const PhotoPickCancelled();
}

Future<void> pumpDetail(
  WidgetTester tester,
  List<ReportStatus> statuses, {
  FakeAssigner? assigner,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: ReportDetailScreen(
        reportId: 'r7',
        source: FakeDetails(statuses),
        actionBuilder: (detail, reload) => StaffReportActions(
          detail: detail,
          assigner: assigner ?? FakeAssigner(),
          resolver: UnusedResolver(),
          photoPicker: UnusedPicker(),
          onChanged: reload,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('assign_fromDetail_thenOffersResolve', (tester) async {
    final assigner = FakeAssigner();
    await pumpDetail(tester, [
      ReportStatus.yeni,
      ReportStatus.ustlenildi,
    ], assigner: assigner);

    await tester.tap(find.text('Üstlen'));
    await tester.pumpAndSettle();

    expect(assigner.assigned, ['r7']);
    expect(find.text('Bildirim üstlenildi'), findsOneWidget);
    expect(find.text('Çöz'), findsOneWidget);
  });

  testWidgets('resolve_fromDetail_opensResolveScreen', (tester) async {
    await pumpDetail(tester, [ReportStatus.ustlenildi]);

    await tester.tap(find.text('Çöz'));
    await tester.pumpAndSettle();

    expect(find.byType(ResolveScreen), findsOneWidget);
  });

  testWidgets('showsNoAction_whenResolved', (tester) async {
    await pumpDetail(tester, [ReportStatus.cozuldu]);

    expect(find.text('Üstlen'), findsNothing);
    expect(find.text('Çöz'), findsNothing);
  });

  test('assignResultMessage_coversEveryResult', () {
    expect(assignResultMessage(const ReportAssigned()), 'Bildirim üstlenildi');
    expect(
      assignResultMessage(const ReportAlreadyTaken()),
      'Bu bildirimi başka bir görevli üstlendi',
    );
    expect(
      assignResultMessage(const ReportAssignFailed()),
      'Üstlenilemedi, tekrar deneyin',
    );
  });
}
