import 'dart:typed_data';

import 'package:campus_app/mobil/demo/demo_backend.dart';
import 'package:campus_app/mobil/features/auth/data/auth_source.dart';
import 'package:campus_app/mobil/features/auth/data/session.dart';
import 'package:campus_app/mobil/features/notifications/data/notifications_source.dart';
import 'package:campus_app/mobil/features/reports/data/new_report.dart';
import 'package:campus_app/mobil/features/reports/data/report_assigner.dart';
import 'package:campus_app/mobil/features/reports/data/report_list_item.dart';
import 'package:campus_app/mobil/features/reports/data/reports_source.dart';
import 'package:campus_app/mobil/features/reports/data/staff_reports_source.dart';
import 'package:campus_app/mobil/shared/photo/photo_picker.dart';
import 'package:flutter_test/flutter_test.dart';

Future<List<ReportListItem>> staffList(
  DemoBackend demo,
  StaffReportsView view,
) async {
  final result = await demo.staffReports.fetchFirstPage(view);
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
      NewReport(
        category: ReportCategory.temizlik,
        description: 'Kantin masaları kirli',
        photo: PickedPhoto(
          bytes: Uint8List.fromList([1, 2, 3]),
          contentType: 'image/png',
        ),
      ),
    );

    final mine = await demo.myReports.fetchPage(offset: 0, limit: 20);
    final first = (mine as ReportsPageLoaded).items.first;
    expect(first.category, ReportCategory.temizlik);
    final incoming = await staffList(demo, StaffReportsView.incoming);
    expect(incoming.map((report) => report.id), contains(first.id));
  });

  test('assign_movesReportToMine_andSecondAssignIsTaken', () async {
    final demo = DemoBackend();
    final report = (await staffList(demo, StaffReportsView.incoming)).first;

    final first = await demo.assigner.assign(report.id!);
    final second = await demo.assigner.assign(report.id!);

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
}
