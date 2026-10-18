import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'erisilebilirlik_test.dart' show login, pumpPhoneApp, tapAndSettle;

/// Android ve WCAG kılavuzları: dokunma alanı en az 48x48, her düğmenin
/// ekran okuyucu adı var, metin kontrastı yeterli.
Future<void> expectGuidelines(WidgetTester tester) async {
  await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
  await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
  await expectLater(tester, meetsGuideline(textContrastGuideline));
}

void main() {
  testWidgets('loginScreen_meetsGuidelines', (tester) async {
    final semantics = tester.ensureSemantics();
    await pumpPhoneApp(tester);
    await expectGuidelines(tester);
    semantics.dispose();
  });

  testWidgets('studentScreens_meetGuidelines', (tester) async {
    final semantics = tester.ensureSemantics();
    await pumpPhoneApp(tester);
    await login(tester, 'ayse@ornek.edu');
    await expectGuidelines(tester);

    await tapAndSettle(tester, find.byTooltip('Bildirim oluştur'));
    await expectGuidelines(tester);
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tapAndSettle(tester, find.text('Bildirimler'));
    await expectGuidelines(tester);

    await tapAndSettle(tester, find.textContaining('Bildiriminiz çözüldü'));
    await expectGuidelines(tester);
    semantics.dispose();
  });

  testWidgets('studentScreens_meetGuidelines_inDarkMode', (tester) async {
    final semantics = tester.ensureSemantics();
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
    await pumpPhoneApp(tester);
    await expectGuidelines(tester);

    await login(tester, 'ayse@ornek.edu');
    expect(
      Theme.of(tester.element(find.byType(Scaffold).first)).brightness,
      Brightness.dark,
    );
    await expectGuidelines(tester);

    await tapAndSettle(tester, find.text('Bildirimler'));
    await expectGuidelines(tester);
    await tapAndSettle(tester, find.textContaining('Bildiriminiz çözüldü'));
    await expectGuidelines(tester);
    semantics.dispose();
  });

  testWidgets('staffScreens_meetGuidelines', (tester) async {
    final semantics = tester.ensureSemantics();
    await pumpPhoneApp(tester);
    await login(tester, 'gorevli@ornek.edu');
    await expectGuidelines(tester);

    await tapAndSettle(tester, find.text('Üstlen').first);
    await tapAndSettle(tester, find.text('Benimkiler'));
    await expectGuidelines(tester);

    await tapAndSettle(tester, find.text('Çöz').first);
    await expectGuidelines(tester);
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tapAndSettle(tester, find.byType(ListTile).first);
    await expectGuidelines(tester);
    semantics.dispose();
  });
}
