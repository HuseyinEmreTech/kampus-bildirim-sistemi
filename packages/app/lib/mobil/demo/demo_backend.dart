import 'dart:convert';

import '../features/auth/data/auth_source.dart';
import '../features/auth/data/session.dart';
import '../features/notifications/data/notification_item.dart';
import '../features/notifications/data/notifications_source.dart';
import '../features/reports/data/new_report.dart';
import '../features/reports/data/report_assigner.dart';
import '../features/reports/data/report_creator.dart';
import '../features/reports/data/report_detail.dart';
import '../features/reports/data/report_detail_source.dart';
import '../features/reports/data/report_list_item.dart';
import '../features/reports/data/report_resolver.dart';
import '../features/reports/data/reports_source.dart';
import '../features/reports/data/staff_reports_source.dart';
import '../shared/photo/photo_picker.dart';

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
  ReportResolver get resolver => _staff;
  final PhotoPicker photoPicker = _DemoPhotoPicker();
  late final NotificationsSource notifications = _DemoNotifications(this);
  late final ReportDetailSource reportDetail = _DemoReportDetail(this);

  /// Demoda gerçek fotoğraf yok; detay ekranı yerinde kırık resim simgesi gösterir.
  static const _photoUrl = 'https://ornek.test/demo.jpg';

  /// Demo tarihleri Ekim 2026'nın günleri.
  static DateTime _day(int day) => DateTime(2026, 10, day);

  void _seed() {
    _add(
      studentId,
      ReportCategory.ariza,
      'B Blok 2. kat',
      _day(15),
    ).description = 'Koridor lambası yanmıyor';
    _add(
      'baska-ogrenci',
      ReportCategory.guvenlik,
      'Otopark girişi',
      _day(16),
    ).description = 'Bariyer kapanmıyor';
    final resolved =
        _add(studentId, ReportCategory.temizlik, 'Kütüphane', _day(12))
          ..description = 'Okuma salonunda çöp kutuları taşmış'
          ..status = ReportStatus.cozuldu
          ..assigneeId = staffId
          ..resolution = const Resolution(
            photoUrl: _photoUrl,
            note: 'Çöpler toplandı.',
          );
    resolved.history.addAll([
      StatusChange(to: ReportStatus.ustlenildi, changedAt: _day(12)),
      StatusChange(to: ReportStatus.cozuldu, changedAt: _day(13)),
    ]);
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
    report.history.add(
      StatusChange(to: ReportStatus.yeni, changedAt: createdAt),
    );
    _reports.add(report);
    return report;
  }

  _DemoReport? _find(String id) =>
      _reports.where((report) => report.id == id).firstOrNull;

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
  String description = '';
  ReportStatus status = ReportStatus.yeni;
  String? assigneeId;
  Resolution? resolution;
  final history = <StatusChange>[];

  ReportListItem toItem() => ReportListItem(
    id: id,
    category: category,
    status: status,
    place: place,
    createdAt: createdAt,
  );

  ReportDetail toDetail() => ReportDetail(
    id: id,
    category: category,
    status: status,
    description: description,
    place: place,
    createdAt: createdAt,
    photoUrl: DemoBackend._photoUrl,
    history: List.of(history),
    resolution: resolution,
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
    required int page,
    required int pageSize,
  }) async {
    final items = _demo._list((r) => r.reporterId == DemoBackend.studentId);
    final skipped = items.skip((page - 1) * pageSize);
    return ReportsPageLoaded(skipped.take(pageSize).toList());
  }

  @override
  Future<ReportCreateResult> create(NewReport report) async {
    _demo
            ._add(
              DemoBackend.studentId,
              report.category,
              'Konum seçilmedi',
              DateTime.now(),
            )
            .description =
        report.description;
    return const ReportCreated();
  }
}

/// Görevli listesi, üstlenme ve çözme; sunucudaki gibi üstlenilmiş bildirim
/// ikinci kez üstlenilemez (Rule 02), yalnızca üstlenen çözer (Rule 03) ve
/// çözülünce bildirimi açan öğrenciye "çözüldü" bildirimi düşer (Rule 04).
class _DemoStaffReports
    implements StaffReportsSource, ReportAssigner, ReportResolver {
  _DemoStaffReports(this._demo);

  final DemoBackend _demo;

  @override
  Future<ReportsPageResult> fetchPage(
    StaffReportsView view, {
    ReportCategory? category,
    required int page,
    required int pageSize,
  }) async {
    bool inView(_DemoReport report) => switch (view) {
      StaffReportsView.incoming => report.status == ReportStatus.yeni,
      StaffReportsView.mine => report.assigneeId == DemoBackend.staffId,
    };
    final items = _demo._list(
      (r) => inView(r) && (category == null || r.category == category),
    );
    final skipped = items.skip((page - 1) * pageSize);
    return ReportsPageLoaded(skipped.take(pageSize).toList());
  }

  @override
  Future<ReportAssignResult> assign(String reportId) async {
    final report = _demo._find(reportId);
    if (report == null) return const ReportAssignFailed();
    if (report.assigneeId != null) return const ReportAlreadyTaken();
    report
      ..assigneeId = DemoBackend.staffId
      ..status = ReportStatus.ustlenildi
      ..history.add(
        StatusChange(to: ReportStatus.ustlenildi, changedAt: DateTime.now()),
      );
    return const ReportAssigned();
  }

  @override
  Future<ReportResolveResult> resolve({
    required String reportId,
    required PickedPhoto photo,
    String? note,
  }) async {
    final report = _demo._find(reportId);
    if (report == null) return const ReportResolveFailed();
    if (report.assigneeId != DemoBackend.staffId ||
        report.status != ReportStatus.ustlenildi) {
      return const ReportResolveRejected('Bu bildirimi siz üstlenmediniz.');
    }
    report
      ..status = ReportStatus.cozuldu
      ..resolution = Resolution(photoUrl: DemoBackend._photoUrl, note: note)
      ..history.add(
        StatusChange(to: ReportStatus.cozuldu, changedAt: DateTime.now()),
      );
    _demo._notifications.insert(
      0,
      NotificationItem(
        id: 'n${_demo._nextId++}',
        reportId: report.id,
        message: 'Bildiriminiz çözüldü: ${report.place}',
        createdAt: DateTime.now(),
        isRead: false,
      ),
    );
    return const ReportResolved();
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

class _DemoReportDetail implements ReportDetailSource {
  _DemoReportDetail(this._demo);

  final DemoBackend _demo;

  @override
  Future<ReportDetailResult> fetch(String reportId) async {
    final report = _demo._find(reportId);
    if (report == null) return const ReportDetailNotFound();
    return ReportDetailLoaded(report.toDetail());
  }
}

/// Kamera yerine her seferinde 1x1 piksellik sahte bir PNG verir.
class _DemoPhotoPicker implements PhotoPicker {
  static final _png = base64Decode(
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==',
  );

  @override
  Future<PhotoPickResult> pick(PhotoSource source) async =>
      PhotoPicked(PickedPhoto(bytes: _png, contentType: 'image/png'));
}
