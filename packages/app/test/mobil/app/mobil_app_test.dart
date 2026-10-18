import 'package:campus_app/mobil/app/mobil_app.dart';
import 'package:campus_app/mobil/demo/demo_backend.dart';
import 'package:campus_app/mobil/demo/memory_session_store.dart';
import 'package:campus_app/mobil/features/auth/presentation/login_screen.dart';
import 'package:campus_app/mobil/features/auth/state/auth_controller.dart';
import 'package:campus_app/mobil/features/notifications/presentation/notifications_screen.dart';
import 'package:campus_app/mobil/features/reports/presentation/staff/resolve_screen.dart';
import 'package:campus_app/mobil/features/reports/presentation/staff/staff_reports_screen.dart';
import 'package:campus_app/mobil/features/reports/presentation/student/report_detail_screen.dart';
import 'package:campus_app/mobil/features/reports/presentation/student/reports_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> pumpApp(WidgetTester tester) async {
  await tester.pumpWidget(
    MobilApp(
      auth: AuthController(MemorySessionStore()),
      sources: MobilSources.demo(DemoBackend()),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> login(WidgetTester tester, String email) async {
  await tester.enterText(find.widgetWithText(TextFormField, 'E-posta'), email);
  await tester.enterText(
    find.widgetWithText(TextFormField, 'Şifre'),
    'parola1',
  );
  await tester.tap(find.text('Giriş yap'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('showsLogin_whenLoggedOut', (tester) async {
    await pumpApp(tester);

    expect(find.byType(LoginScreen), findsOneWidget);
  });

  testWidgets('studentLogin_showsMyReportsThenNotifications', (tester) async {
    await pumpApp(tester);

    await login(tester, 'ayse@ornek.edu');
    expect(find.byType(ReportsListScreen), findsOneWidget);

    await tester.tap(find.text('Bildirimler'));
    await tester.pumpAndSettle();
    expect(find.byType(NotificationsScreen), findsOneWidget);
  });

  testWidgets('staffLogin_showsStaffReports', (tester) async {
    await pumpApp(tester);

    await login(tester, 'gorevli@ornek.edu');

    expect(find.byType(StaffReportsScreen), findsOneWidget);
  });

  testWidgets('signOut_returnsToLogin', (tester) async {
    await pumpApp(tester);
    await login(tester, 'ayse@ornek.edu');

    await tester.tap(find.text('Çıkış'));
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsOneWidget);
  });

  testWidgets('tappingReport_opensDetail', (tester) async {
    await pumpApp(tester);
    await login(tester, 'ayse@ornek.edu');

    await tester.tap(find.textContaining('B Blok 2. kat'));
    await tester.pumpAndSettle();

    expect(find.byType(ReportDetailScreen), findsOneWidget);
  });

  testWidgets('tappingNotification_opensResolvedDetail', (tester) async {
    await pumpApp(tester);
    await login(tester, 'ayse@ornek.edu');
    await tester.tap(find.text('Bildirimler'));
    await tester.pumpAndSettle();

    await tester.tap(find.textContaining('Bildiriminiz çözüldü'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('Sonuç'), 200);

    expect(find.text('Sonuç'), findsOneWidget);
  });

  testWidgets('staffAssignsAndResolves_thenStudentIsNotified', (tester) async {
    await pumpApp(tester);
    await login(tester, 'gorevli@ornek.edu');

    // Ayşe'nin B Blok bildirimini kartındaki düğmeyle üstlen.
    final bBlokCard = find.ancestor(
      of: find.textContaining('B Blok 2. kat'),
      matching: find.byType(Card),
    );
    await tester.tap(
      find.descendant(of: bBlokCard, matching: find.text('Üstlen')),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Benimkiler'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Çöz'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Fotoğraf çek'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Çözüldü olarak işaretle'));
    await tester.pumpAndSettle();
    expect(find.byType(ResolveScreen), findsNothing);

    await tester.tap(find.text('Çıkış'));
    await tester.pumpAndSettle();
    await login(tester, 'ayse@ornek.edu');
    await tester.tap(find.text('Bildirimler'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Bildiriminiz çözüldü'), findsNWidgets(2));
  });
}
