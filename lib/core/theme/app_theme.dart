import 'package:flutter/material.dart';

/// Material-3-Themes (Light/Dark) der Gesundheitsplattform.
///
/// Ein Seed-Farbschema (Grün-Türkis, "Gesundheit") wird für beide Modi
/// abgeleitet; Karten- und Button-Stile sind app-weit einheitlich.
class AppTheme {
  const AppTheme._();

  static const Color _seed = Color(0xFF2E7D5B);

  /// Lichtes Theme.
  static ThemeData light() => _base(Brightness.light);

  /// Dunkles Theme.
  static ThemeData dark() => _base(Brightness.dark);

  static ThemeData _base(Brightness brightness) {
    final scheme = ColorScheme.fromSeed(
      seedColor: _seed,
      brightness: brightness,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: scheme.surfaceContainerLow,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        isDense: true,
      ),
      snackBarTheme: const SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
      ),
      listTileTheme: const ListTileThemeData(horizontalTitleGap: 8),
    );
  }

  /// Standard-Abstandsskala (8er-Raster).
  static const double spacingXs = 4;
  static const double spacingSm = 8;
  static const double spacingMd = 16;
  static const double spacingLg = 24;
}
