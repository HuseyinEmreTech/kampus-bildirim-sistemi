import 'package:flutter/material.dart';

/// Uygulamanın ana rengi; tüm palet Material 3 ile bu renkten türetilir.
/// Renk ekipte henüz konuşulmadı; değişirse yalnızca bu satır değişir.
const campusSeedColor = Color(0xFF1565C0);

/// Kartların ekran kenarından ve birbirinden boşluğu.
const _cardMargin = EdgeInsets.symmetric(horizontal: 12, vertical: 6);

/// Açık tema; telefon açık moddayken kullanılır.
ThemeData buildLightTheme() => _buildTheme(Brightness.light);

/// Koyu tema; telefon koyu moddayken kullanılır.
ThemeData buildDarkTheme() => _buildTheme(Brightness.dark);

/// İki tema aynı bileşen görünümlerini paylaşır, yalnızca renkler değişir.
ThemeData _buildTheme(Brightness brightness) {
  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: campusSeedColor,
      brightness: brightness,
    ),
    appBarTheme: const AppBarTheme(centerTitle: true),
    cardTheme: const CardThemeData(margin: _cardMargin),
    inputDecorationTheme: const InputDecorationTheme(
      border: OutlineInputBorder(),
    ),
    snackBarTheme: const SnackBarThemeData(behavior: SnackBarBehavior.floating),
  );
}
