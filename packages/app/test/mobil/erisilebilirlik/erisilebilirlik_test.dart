import 'package:campus_app/mobil/app/mobil_app.dart';
import 'package:campus_app/mobil/demo/demo_backend.dart';
import 'package:campus_app/mobil/demo/memory_session_store.dart';
import 'package:campus_app/mobil/features/auth/state/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Telefon boyutu (360x800) ve isteğe bağlı büyük yazı; taşan bir öğe
/// olursa Flutter test hatası verir.
Future<void> pumpPhoneApp(WidgetTester tester, {double textScale = 1}) async {
  tester.view.physicalSize = const Size(1080, 2400);
  tester.view.devicePixelRatio = 3;
  tester.platformDispatcher.textScaleFactorTestValue = textScale;
  addTearDown(tester.view.reset);
  addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
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
  await tester.enterText(find.widgetWithText(TextFormField, 'Şifre'), '123456');
  await tester.tap(find.text('Giriş yap'));
  await tester.pumpAndSettle();
}

Future<void> tapAndSettle(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('studentScreens_doNotOverflow_withLargeText', (tester) async {
    await pumpPhoneApp(tester, textScale: 2);
    await login(tester, 'ayse@ornek.edu');

    await tapAndSettle(tester, find.byTooltip('Bildirim oluştur'));
    await tapAndSettle(tester, find.text('Fotoğraf çek'));
    await tapAndSettle(tester, find.text('Konumumu al'));
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tapAndSettle(tester, find.textContaining('B Blok 2. kat'));
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tapAndSettle(tester, find.text('Bildirimler').last);
  });

  testWidgets('staffScreens_doNotOverflow_withLargeText', (tester) async {
    await pumpPhoneApp(tester, textScale: 2);
    await login(tester, 'gorevli@ornek.edu');

    await tapAndSettle(tester, find.text('Üstlen').first);
    await tapAndSettle(tester, find.text('Benimkiler'));
    await tapAndSettle(tester, find.text('Çöz').first);
    await tapAndSettle(tester, find.text('Fotoğraf çek'));
  });

  testWidgets('icons_haveScreenReaderLabels', (tester) async {
    final semantics = tester.ensureSemantics();
    await pumpPhoneApp(tester);
    await login(tester, 'ayse@ornek.edu');
    await tapAndSettle(tester, find.text('Bildirimler'));

    expect(find.bySemanticsLabel('1 okunmamış bildirim'), findsOneWidget);
    // Simge satırla birleşir: "Okunmadı, <mesaj>, <tarih>".
    expect(find.bySemanticsLabel(RegExp('^Okunmadı')), findsOneWidget);

    await tapAndSettle(tester, find.textContaining('Bildiriminiz çözüldü'));
    expect(find.bySemanticsLabel('Bildirim fotoğrafı'), findsOneWidget);
    expect(find.bySemanticsLabel('Sonuç fotoğrafı'), findsOneWidget);
    semantics.dispose();
  });
}
