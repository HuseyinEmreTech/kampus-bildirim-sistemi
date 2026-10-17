import '../features/auth/data/auth_source.dart';
import '../features/auth/data/session.dart';
import '../features/notifications/data/notification_item.dart';
import '../features/notifications/data/notifications_source.dart';
import '../features/reports/data/new_report.dart';
import '../features/reports/data/report_assigner.dart';
import '../features/reports/data/report_creator.dart';
import '../features/reports/data/report_list_item.dart';
import '../features/reports/data/reports_source.dart';
import '../features/reports/data/staff_reports_source.dart';

/// Sunucu hazır olana kadar uygulamayı telefonda çalıştırmak için bellekte
/// duran sahte veri. Bütün ekranlar aynı veriyi paylaşır; uygulama kapanınca
/// sıfırlanır. Gerçek kişi verisi ve şifre yoktur.
class DemoBackend {
  DemoBackend() {
    _seed();
  }

  static const studentId = 'demo-ogrenci';
  static const staffId = 'demo-gorevli';

  final _reports = <_DemoReport>[];
  final _notifications = <NotificationItem>[];
  var _nextId = 1;

  late final AuthSource auth = _DemoAuth();
  late final _student = _DemoStudentReports(this);
  late final _staff = _DemoStaffReports(this);
  ReportsSource get myReports => _student;
  ReportCreator get creator => _student;
  StaffReportsSource get staffReports => _staff;
  ReportAssigner get assigner => _staff;
  late final NotificationsSource notifications = _DemoNotifications(this);

  /// Demo tarihleri Ekim 2026'nın günleri.
  static DateTime _day(int day) => DateTime(2026, 10, day);

  void _seed() {
    _add(studentId, ReportCategory.ariza, 'B Blok 2. kat', _day(15));
    _add('baska-ogrenci', ReportCategory.guvenlik, 'Otopark girişi', _day(16));
    final resolved =
        _add(studentId, ReportCategory.temizlik, 'Kütüphane', _day(12))
          ..status = ReportStatus.cozuldu
          ..assigneeId = staffId;
    _notifications.add(
      NotificationItem(
        id: 'n1',
        reportId: resolved.id,
        message: 'Bildiriminiz çözüldü: Kütüphane',
        createdAt: _day(13),
        isRead: false,
      ),
    );
  }

  _DemoReport _add(
    String reporterId,
    ReportCategory category,
    String place,
    DateTime createdAt,
  ) {
    final report = _DemoReport(
      id: 'r${_nextId++}',
      reporterId: reporterId,
      category: category,
      place: place,
      createdAt: createdAt,
    );
    _reports.add(report);
    return report;
  }

  /// En yeni bildirim önde.
  List<ReportListItem> _list(bool Function(_DemoReport report) where) =>
      _reports.where(where).map((r) => r.toItem()).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
}

/// Demo bildirimi; durumu ve üstlenen görevli değişebilir.
class _DemoReport {
  _DemoReport({
    required this.id,
    required this.reporterId,
    required this.category,
    required this.place,
    required this.createdAt,
  });

  final String id;
  final String reporterId;
  final ReportCategory category;
  final String place;
  final DateTime createdAt;
  ReportStatus status = ReportStatus.yeni;
  String? assigneeId;

  ReportListItem toItem() => ReportListItem(
    id: id,
    category: category,
    status: status,
    place: place,
    createdAt: createdAt,
  );
}

/// E-posta "gorevli" ile başlıyorsa görevli, değilse öğrenci olarak girer.
class _DemoAuth implements AuthSource {
  @override
  Future<LoginResult> login({
    required String email,
    required String password,
  }) async {
    final isStaff = email.startsWith('gorevli');
    return LoginSucceeded(
      Session(
        token: 'demo',
        userId: isStaff ? DemoBackend.staffId : DemoBackend.studentId,
        fullName: isStaff ? 'Demo Görevli' : 'Demo Öğrenci',
        role: isStaff ? UserRole.staff : UserRole.student,
      ),
    );
  }
}

/// Öğrencinin bildirimleri ve yeni bildirim. Konum 3. parçada geleceği için
/// yeni bildirimin yeri "Konum seçilmedi" yazılır.
class _DemoStudentReports implements ReportsSource, ReportCreator {
  _DemoStudentReports(this._demo);

  final DemoBackend _demo;

  @override
  Future<ReportsPageResult> fetchPage({
    required int offset,
    required int limit,
  }) async {
    final items = _demo._list((r) => r.reporterId == DemoBackend.studentId);
    return ReportsPageLoaded(items.skip(offset).take(limit).toList());
  }

  @override
  Future<ReportCreateResult> create(NewReport report) async {
    _demo._add(
      DemoBackend.studentId,
      report.category,
      'Konum seçilmedi',
      DateTime.now(),
    );
    return const ReportCreated();
  }
}

/// Görevli listesi ve üstlenme; sunucudaki Rule 02 gibi üstlenilmiş
/// bildirim ikinci kez üstlenilemez.
class _DemoStaffReports implements StaffReportsSource, ReportAssigner {
  _DemoStaffReports(this._demo);

  final DemoBackend _demo;

  @override
  Future<ReportsPageResult> fetchFirstPage(
    StaffReportsView view, {
    ReportCategory? category,
  }) async {
    bool inView(_DemoReport report) => switch (view) {
      StaffReportsView.incoming => report.status == ReportStatus.yeni,
      StaffReportsView.mine => report.assigneeId == DemoBackend.staffId,
    };
    return ReportsPageLoaded(
      _demo._list(
        (r) => inView(r) && (category == null || r.category == category),
      ),
    );
  }

  @override
  Future<ReportAssignResult> assign(String reportId) async {
    final report = _demo._reports.where((r) => r.id == reportId).firstOrNull;
    if (report == null) return const ReportAssignFailed();
    if (report.assigneeId != null) return const ReportAlreadyTaken();
    report
      ..assigneeId = DemoBackend.staffId
      ..status = ReportStatus.ustlenildi;
    return const ReportAssigned();
  }
}

class _DemoNotifications implements NotificationsSource {
  _DemoNotifications(this._demo);

  final DemoBackend _demo;

  @override
  Future<NotificationsResult> fetchFirstPage() async {
    final items = List.of(_demo._notifications);
    final unread = items.where((item) => !item.isRead).length;
    return NotificationsLoaded(items: items, unreadCount: unread);
  }

  @override
  Future<bool> markRead(String notificationId) async {
    final list = _demo._notifications;
    final index = list.indexWhere((item) => item.id == notificationId);
    if (index < 0) return false;
    list[index] = list[index].markedRead();
    return true;
  }
}
