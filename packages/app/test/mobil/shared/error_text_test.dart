import 'package:campus_app/mobil/shared/error_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('errorText_isAnnouncedByScreenReader', (tester) async {
    final semantics = tester.ensureSemantics();

    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: ErrorText('Bağlantı kurulamadı'))),
    );

    expect(
      tester.getSemantics(find.text('Bağlantı kurulamadı')),
      matchesSemantics(label: 'Bağlantı kurulamadı', isLiveRegion: true),
    );
    semantics.dispose();
  });

  testWidgets('errorText_usesErrorColor', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: ErrorText('Hata'))),
    );

    final context = tester.element(find.text('Hata'));
    final text = tester.widget<Text>(find.text('Hata'));
    expect(text.style?.color, Theme.of(context).colorScheme.error);
  });
}
