import 'package:campus_app/mobil/demo/demo_backend.dart';
import 'package:campus_app/mobil/features/auth/data/auth_source.dart';
import 'package:campus_app/mobil/features/auth/data/session.dart';
import 'package:campus_app/mobil/features/notifications/data/notifications_source.dart';
import 'package:campus_app/mobil/features/reports/data/new_report.dart';
import 'package:campus_app/mobil/features/reports/data/report_assigner.dart';
import 'package:campus_app/mobil/features/reports/data/report_detail_source.dart';
import 'package:campus_app/mobil/features/reports/data/report_list_item.dart';
import 'package:campus_app/mobil/features/reports/data/report_resolver.dart';
import 'package:campus_app/mobil/features/reports/data/reports_source.dart';
import 'package:campus_app/mobil/features/reports/data/staff_reports_source.dart';
import 'package:campus_app/mobil/shared/photo/photo_picker.dart';
import 'package:flutter_test/flutter_test.dart';

Future<List<ReportListItem>> staffList(
  DemoBackend demo,
  StaffReportsView view,
) async {
  final result = await demo.staffReports.fetchPage(
    view,
    page: 1,
    pageSize: reportsPageSize,
  );
  return (result as ReportsPageLoaded).items;
}

void main() {
  test('login_returnsStaff_whenEmailStartsWithGorevli', () async {
    final demo = DemoBackend();

    final staff = await demo.auth.login(
      email: 'gorevli@ornek.edu',
      password: 'parola1',
    );
    final student = await demo.auth.login(
      email: 'ayse@ornek.edu',
      password: 'parola1',
    );

    expect((staff as LoginSucceeded).session.role, UserRole.staff);
    expect((student as LoginSucceeded).session.role, UserRole.student);
  });

  test('createdReport_appearsInStudentListAndIncoming', () async {
    final demo = DemoBackend();

    await demo.creator.create(
      const NewReport(
        category: ReportCategory.temizlik,
        description: 'Kantin masaları kirli',
      ),
    );

    final mine = await demo.myReports.fetchPage(page: 1, pageSize: 20);
    final first = (mine as ReportsPageLoaded).items.first;
    expect(first.category, ReportCategory.temizlik);
    final incoming = await staffList(demo, StaffReportsView.incoming);
    expect(incoming.map((report) => report.id), contains(first.id));
  });

  test('assign_movesReportToMine_andSecondAssignIsTaken', () async {
    final demo = DemoBackend();
    final report = (await staffList(demo, StaffReportsView.incoming)).first;

    final first = await demo.assigner.assign(report.id);
    final second = await demo.assigner.assign(report.id);

    expect(first, isA<ReportAssigned>());
    expect(second, isA<ReportAlreadyTaken>());
    final mine = await staffList(demo, StaffReportsView.mine);
    final assigned = mine.singleWhere((item) => item.id == report.id);
    expect(assigned.status, ReportStatus.ustlenildi);
  });

  test('markRead_decreasesUnreadCount', () async {
    final demo = DemoBackend();
    final before = await demo.notifications.fetchFirstPage();
    final unread = (before as NotificationsLoaded).items.firstWhere(
      (item) => !item.isRead,
    );

    final marked = await demo.notifications.markRead(unread.id);

    final after = await demo.notifications.fetchFirstPage();
    expect(marked, isTrue);
    expect((after as NotificationsLoaded).unreadCount, before.unreadCount - 1);
  });

  test('detail_includesResolution_forResolvedReport', () async {
    final demo = DemoBackend();
    final notices = await demo.notifications.fetchFirstPage();
    final reportId = (notices as NotificationsLoaded).items.first.reportId;

    final result = await demo.reportDetail.fetch(reportId);

    final detail = (result as ReportDetailLoaded).detail;
    expect(detail.status, ReportStatus.cozuldu);
    expect(detail.resolution?.note, isNotNull);
    expect(detail.history.last.to, ReportStatus.cozuldu);
  });

  test('resolve_marksResolved_andNotifiesStudent', () async {
    final demo = DemoBackend();
    final report = (await staffList(demo, StaffReportsView.incoming)).first;
    await demo.assigner.assign(report.id);
    final photo = await demo.photoPicker.pick(PhotoSource.camera);

    final result = await demo.resolver.resolve(
      reportId: report.id,
      photo: (photo as PhotoPicked).photo,
      note: 'Bariyer onarıldı.',
    );

    expect(result, isA<ReportResolved>());
    final detail = await demo.reportDetail.fetch(report.id);
    expect(
      (detail as ReportDetailLoaded).detail.resolution?.note,
      'Bariyer onarıldı.',
    );
  });

  test('resolve_isRejected_whenNotAssigned', () async {
    final demo = DemoBackend();
    final report = (await staffList(demo, StaffReportsView.incoming)).first;
    final photo = await demo.photoPicker.pick(PhotoSource.gallery);

    final result = await demo.resolver.resolve(
      reportId: report.id,
      photo: (photo as PhotoPicked).photo,
    );

    expect(result, isA<ReportResolveRejected>());
  });
}
