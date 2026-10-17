import 'package:campus_app/mobil/features/notifications/data/notification_item.dart';
import 'package:campus_app/mobil/features/notifications/data/notifications_source.dart';
import 'package:campus_app/mobil/features/notifications/presentation/notifications_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Sırayla verilen sonuçları döndüren ve okundu isteklerini kaydeden sahte kaynak.
class FakeNotificationsSource implements NotificationsSource {
  FakeNotificationsSource(this.results, {this.markReadSucceeds = true});

  final List<NotificationsResult> results;
  final bool markReadSucceeds;
  final markedIds = <String>[];

  @override
  Future<NotificationsResult> fetchFirstPage() async => results.removeAt(0);

  @override
  Future<bool> markRead(String notificationId) async {
    markedIds.add(notificationId);
    return markReadSucceeds;
  }
}

NotificationItem notification(String id, {bool isRead = false}) =>
    NotificationItem(
      id: id,
      reportId: 'rapor-$id',
      message: 'Bildiriminiz çözüldü: koridor lambası $id',
      createdAt: DateTime(2026, 10, 17),
      isRead: isRead,
    );

Future<void> pumpScreen(WidgetTester tester, NotificationsSource source) async {
  await tester.pumpWidget(
    MaterialApp(home: NotificationsScreen(source: source)),
  );
  await tester.pumpAndSettle();
}

/// Biri okunmamış, biri okunmuş iki bildirim.
FakeNotificationsSource oneUnread({bool markReadSucceeds = true}) =>
    FakeNotificationsSource([
      NotificationsLoaded(
        items: [notification('n1'), notification('n2', isRead: true)],
        unreadCount: 1,
      ),
    ], markReadSucceeds: markReadSucceeds);

void main() {
  testWidgets('showsNotifications_withUnreadCount', (tester) async {
    await pumpScreen(tester, oneUnread());

    expect(find.textContaining('koridor lambası n1'), findsOneWidget);
    expect(find.textContaining('koridor lambası n2'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
    expect(find.text('Okundu'), findsOneWidget);
  });

  testWidgets('showsEmptyState_whenNoNotifications', (tester) async {
    await pumpScreen(
      tester,
      FakeNotificationsSource([
        const NotificationsLoaded(items: [], unreadCount: 0),
      ]),
    );

    expect(find.text('Henüz bildirim yok'), findsOneWidget);
  });

  testWidgets('showsRetry_whenLoadFails', (tester) async {
    final source = FakeNotificationsSource([
      const NotificationsFailed(),
      NotificationsLoaded(items: [notification('n1')], unreadCount: 1),
    ]);
    await pumpScreen(tester, source);

    await tester.tap(find.text('Tekrar dene'));
    await tester.pumpAndSettle();

    expect(find.textContaining('koridor lambası n1'), findsOneWidget);
  });

  testWidgets('markRead_updatesUnreadCount_whenSucceeds', (tester) async {
    final source = oneUnread();
    await pumpScreen(tester, source);

    await tester.tap(find.text('Okundu'));
    await tester.pumpAndSettle();

    expect(source.markedIds, ['n1']);
    expect(find.text('Okundu'), findsNothing);
    expect(find.text('1'), findsNothing);
  });

  testWidgets('markRead_showsError_whenFails', (tester) async {
    await pumpScreen(tester, oneUnread(markReadSucceeds: false));

    await tester.tap(find.text('Okundu'));
    await tester.pumpAndSettle();

    expect(find.text('İşaretlenemedi, tekrar deneyin'), findsOneWidget);
    expect(find.text('Okundu'), findsOneWidget);
  });
}
