import 'package:campus_app/mobil/shared/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('lightTheme_usesMaterial3AndCampusColors', () {
    final theme = buildLightTheme();

    expect(theme.useMaterial3, isTrue);
    expect(theme.brightness, Brightness.light);
    expect(
      theme.colorScheme.primary,
      ColorScheme.fromSeed(seedColor: campusSeedColor).primary,
    );
  });

  test('darkTheme_isDark', () {
    expect(buildDarkTheme().brightness, Brightness.dark);
  });

  test('themes_shareComponentStyles', () {
    for (final theme in [buildLightTheme(), buildDarkTheme()]) {
      expect(theme.snackBarTheme.behavior, SnackBarBehavior.floating);
      expect(theme.inputDecorationTheme.border, isA<OutlineInputBorder>());
    }
  });

  testWidgets('app_followsPhoneBrightness', (tester) async {
    tester.platformDispatcher.platformBrightnessTestValue = Brightness.dark;
    addTearDown(tester.platformDispatcher.clearPlatformBrightnessTestValue);
    late Brightness used;

    await tester.pumpWidget(
      MaterialApp(
        theme: buildLightTheme(),
        darkTheme: buildDarkTheme(),
        home: Builder(
          builder: (context) {
            used = Theme.of(context).brightness;
            return const SizedBox();
          },
        ),
      ),
    );

    expect(used, Brightness.dark);
  });
}
