import 'dart:async';

import 'package:flutter/material.dart';

import '../demo/demo_backend.dart';
import '../features/auth/data/auth_source.dart';
import '../features/auth/data/session.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/state/auth_controller.dart';
import '../features/notifications/data/notifications_source.dart';
import '../features/notifications/presentation/notifications_screen.dart';
import '../features/reports/data/report_assigner.dart';
import '../features/reports/data/report_creator.dart';
import '../features/reports/data/report_detail_source.dart';
import '../features/reports/data/report_resolver.dart';
import '../features/reports/data/reports_source.dart';
import '../features/reports/data/staff_reports_source.dart';
import '../features/reports/presentation/staff/staff_reports_screen.dart';
import '../features/reports/presentation/student/report_detail_screen.dart';
import '../features/reports/presentation/student/reports_list_screen.dart';
import '../shared/app_theme.dart';
import '../shared/photo/photo_picker.dart';

/// Ekranların kullandığı kaynaklar; şimdilik demo, sunucu hazır olunca gerçeği.
class MobilSources {
  const MobilSources({
    required this.auth,
    required this.myReports,
    required this.creator,
    required this.staffReports,
    required this.assigner,
    required this.notifications,
    required this.reportDetail,
    required this.resolver,
    required this.photoPicker,
  });

  MobilSources.demo(DemoBackend demo)
    : this(
        auth: demo.auth,
        myReports: demo.myReports,
        creator: demo.creator,
        staffReports: demo.staffReports,
        assigner: demo.assigner,
        notifications: demo.notifications,
        reportDetail: demo.reportDetail,
        resolver: demo.resolver,
        photoPicker: demo.photoPicker,
      );

  final AuthSource auth;
  final ReportsSource myReports;
  final ReportCreator creator;
  final StaffReportsSource staffReports;
  final ReportAssigner assigner;
  final NotificationsSource notifications;
  final ReportDetailSource reportDetail;
  final ReportResolver resolver;
  final PhotoPicker photoPicker;
}

/// Mobil uygulamanın kökü: tema; giriş yapılmadıysa giriş ekranı, yapıldıysa
/// role göre ana ekran (USR 07).
class MobilApp extends StatelessWidget {
  const MobilApp({super.key, required this.auth, required this.sources});

  final AuthController auth;
  final MobilSources sources;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kampüs Bildirim',
      theme: buildLightTheme(),
      darkTheme: buildDarkTheme(),
      home: ListenableBuilder(
        listenable: auth,
        builder: (context, _) => _buildHome(context),
      ),
    );
  }

  Widget _buildHome(BuildContext context) {
    void signOut() => unawaited(auth.signOut());
    void openDetail(String reportId) => unawaited(
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => ReportDetailScreen(
            reportId: reportId,
            source: sources.reportDetail,
          ),
        ),
      ),
    );
    return switch (auth.session?.role) {
      null => LoginScreen(
        source: sources.auth,
        onLoggedIn: (session) => unawaited(auth.signIn(session)),
      ),
      UserRole.student => _RoleHome(
        onSignOut: signOut,
        pages: [
          (
            'Bildirimlerim',
            Icons.list_alt,
            ReportsListScreen(
              source: sources.myReports,
              creator: sources.creator,
              onReportTap: (report) => openDetail(report.id),
            ),
          ),
          (
            'Bildirimler',
            Icons.notifications,
            NotificationsScreen(
              source: sources.notifications,
              onNotificationTap: (item) => openDetail(item.reportId),
            ),
          ),
        ],
      ),
      UserRole.staff => _RoleHome(
        onSignOut: signOut,
        pages: [
          (
            'Bildirimler',
            Icons.assignment,
            StaffReportsScreen(
              source: sources.staffReports,
              assigner: sources.assigner,
              resolver: sources.resolver,
              photoPicker: sources.photoPicker,
              onReportTap: (report) => openDetail(report.id),
            ),
          ),
        ],
      ),
    };
  }
}

/// Rolün sayfaları alt menüde; menünün sonunda "Çıkış".
class _RoleHome extends StatefulWidget {
  const _RoleHome({required this.pages, required this.onSignOut});

  final List<(String label, IconData icon, Widget page)> pages;
  final VoidCallback onSignOut;

  @override
  State<_RoleHome> createState() => _RoleHomeState();
}

class _RoleHomeState extends State<_RoleHome> {
  int _index = 0;

  void _select(int index) {
    // Son düğme "Çıkış"; sayfa değil.
    if (index == widget.pages.length) return widget.onSignOut();
    setState(() => _index = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.pages[_index].$3,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: _select,
        destinations: [
          for (final (label, icon, _) in widget.pages)
            NavigationDestination(icon: Icon(icon), label: label),
          const NavigationDestination(icon: Icon(Icons.logout), label: 'Çıkış'),
        ],
      ),
    );
  }
}
