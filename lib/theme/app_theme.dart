import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primary = Color(0xFF2B7CEE);
  static const Color backgroundLight = Color(0xFFF3F5F8);
  static const Color backgroundDark = Color(0xFF101822);
  static const Color surfaceDark = Color(0xFF1C2632);
  static const Color surfaceCard = Color(0xFF1F2A36);
  static const Color textMuted = Color(0xFF94A3B8);

  static ThemeData lightTheme() {
    final base = ThemeData.light(useMaterial3: true);
    return base.copyWith(
      colorScheme: base.colorScheme.copyWith(
        primary: primary,
        secondary: const Color(0xFF3B82F6),
        surface: Colors.white,
      ),
      scaffoldBackgroundColor: backgroundLight,
      textTheme: GoogleFonts.interTextTheme(base.textTheme),
      appBarTheme: const AppBarTheme(
        backgroundColor: backgroundLight,
        foregroundColor: Colors.black,
        centerTitle: true,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: Colors.white,
        surfaceTintColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.white,
      ),
    );
  }

  static ThemeData darkTheme() {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      colorScheme: base.colorScheme.copyWith(
        primary: primary,
        secondary: const Color(0xFF3B82F6),
        surface: surfaceDark,
      ),
      scaffoldBackgroundColor: backgroundDark,
      textTheme: GoogleFonts.interTextTheme(base.textTheme).apply(
        bodyColor: Colors.white,
        displayColor: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: backgroundDark,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: surfaceCard,
        surfaceTintColor: surfaceCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primary,
        foregroundColor: Colors.white,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF0F1824),
        selectedItemColor: primary,
        unselectedItemColor: Color(0xFF6B7280),
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }

  static bool isDark(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }

  static Color surface(BuildContext context, {int level = 0}) {
    if (isDark(context)) {
      switch (level) {
        case 0:
          return const Color(0xFF1B2632);
        case 1:
          return const Color(0xFF16202B);
        case 2:
          return const Color(0xFF141E2A);
        default:
          return const Color(0xFF111B26);
      }
    }
    switch (level) {
      case 0:
        return Colors.white;
      case 1:
        return const Color(0xFFFCFDFF);
      case 2:
        return const Color(0xFFEEF2F7);
      default:
        return const Color(0xFFE4EAF2);
    }
  }

  static Color mutedText(BuildContext context) {
    return isDark(context) ? textMuted : const Color(0xFF64748B);
  }

  static Color outline(BuildContext context) {
    return isDark(context)
        ? Colors.white.withValues(alpha: 0.08)
        : const Color(0xFFD7E0EB);
  }

  static Color bottomBar(BuildContext context) {
    return isDark(context) ? const Color(0xFF0F1824) : Colors.white;
  }

  static List<BoxShadow> cardShadow(BuildContext context) {
    if (isDark(context)) return const [];
    return const [
      BoxShadow(
        color: Color(0x140F172A),
        blurRadius: 10,
        offset: Offset(0, 2),
      ),
    ];
  }
}
