import 'package:material_ui/material_ui.dart';

/// Cores do Protótipo de alta fidelidade v02.
abstract final class AppColors {
  static const primary = Color(0xFF0F6B57);
  static const primarySoft = Color(0xFFEAF1EE);
  static const primarySoftStrong = Color(0xFFD6ECE5);
  static const background = Color(0xFFF3F6F5);
  static const surface = Color(0xFFFFFFFF);
  static const border = Color(0xFFE1E7E4);
  static const borderStrong = Color(0xFFC9D2CE);
  static const text = Color(0xFF14201B);
  static const textSecondary = Color(0xFF2F3C37);
  static const textMuted = Color(0xFF55625D);
  static const danger = Color(0xFFA8261C);
  static const dangerBackground = Color(0xFFFFF8F7);
  static const warning = Color(0xFF7A4300);
  static const warningBackground = Color(0xFFF7E3CC);
  static const info = Color(0xFF3B3F8F);
  static const infoBackground = Color(0xFFE3E4F7);
}

/// Espaçamentos usados entre e dentro dos componentes.
abstract final class AppSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
}

/// Raios dos cantos dos campos, botões e cartões.
abstract final class AppRadius {
  static const field = 12.0;
  static const button = 14.0;
  static const card = 18.0;
}

/// Tema Material 3 da aplicação, com as cores e as formas do protótipo.
final appTheme = ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(
    seedColor: AppColors.primary,
    primary: AppColors.primary,
    onPrimary: Colors.white,
    primaryContainer: AppColors.primarySoftStrong,
    onPrimaryContainer: AppColors.primary,
    secondaryContainer: AppColors.primarySoft,
    onSecondaryContainer: AppColors.primary,
    surface: AppColors.surface,
    onSurface: AppColors.text,
    onSurfaceVariant: AppColors.textMuted,
    outline: AppColors.borderStrong,
    outlineVariant: AppColors.border,
    error: AppColors.danger,
  ),
  scaffoldBackgroundColor: AppColors.background,
  appBarTheme: const AppBarTheme(
    backgroundColor: AppColors.surface,
    foregroundColor: AppColors.text,
    surfaceTintColor: Colors.transparent,
    elevation: 0,
    scrolledUnderElevation: 0,
    titleTextStyle: TextStyle(
      color: AppColors.text,
      fontSize: 20,
      fontWeight: FontWeight.w700,
    ),
  ),
  textTheme: const TextTheme(
    headlineSmall: TextStyle(
      color: AppColors.text,
      fontSize: 26,
      fontWeight: FontWeight.w700,
    ),
    titleMedium: TextStyle(
      color: AppColors.text,
      fontSize: 17,
      fontWeight: FontWeight.w700,
    ),
    bodyMedium: TextStyle(color: AppColors.textSecondary, fontSize: 15),
    bodySmall: TextStyle(color: AppColors.textMuted, fontSize: 13),
  ),
  cardTheme: const CardThemeData(
    color: AppColors.surface,
    elevation: 0,
    margin: EdgeInsets.zero,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(AppRadius.card)),
      side: BorderSide(color: AppColors.border),
    ),
  ),
  inputDecorationTheme: const InputDecorationTheme(
    filled: true,
    fillColor: AppColors.surface,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(AppRadius.field)),
      borderSide: BorderSide(color: AppColors.borderStrong),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(AppRadius.field)),
      borderSide: BorderSide(color: AppColors.borderStrong),
    ),
  ),
  filledButtonTheme: FilledButtonThemeData(
    style: FilledButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      minimumSize: const Size.fromHeight(52),
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(AppRadius.button)),
      ),
    ),
  ),
  outlinedButtonTheme: OutlinedButtonThemeData(
    style: OutlinedButton.styleFrom(
      foregroundColor: AppColors.primary,
      minimumSize: const Size.fromHeight(52),
      side: const BorderSide(color: AppColors.primary),
      textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(AppRadius.button)),
      ),
    ),
  ),
  textButtonTheme: TextButtonThemeData(
    style: TextButton.styleFrom(
      foregroundColor: AppColors.primary,
      textStyle: const TextStyle(fontWeight: FontWeight.w700),
    ),
  ),
  navigationBarTheme: const NavigationBarThemeData(
    backgroundColor: AppColors.surface,
    indicatorColor: AppColors.primarySoftStrong,
    surfaceTintColor: Colors.transparent,
  ),
);
