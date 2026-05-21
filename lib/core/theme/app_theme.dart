import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary       = Color(0xFF1B5E20);
  static const Color primaryLight  = Color(0xFF2E7D32);
  static const Color accent        = Color(0xFFFFB300);
  static const Color background    = Color(0xFF121212);
  static const Color surface       = Color(0xFF1E1E1E);
  static const Color surfaceAlt    = Color(0xFF2A2A2A);
  static const Color textPrimary   = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFAAAAAA);

  // Status colours
  static const Color statusDispatched   = Color(0xFF1565C0);
  static const Color statusUndispatched = Color(0xFFE65100);
  static const Color statusRescheduled  = Color(0xFF6A1B9A);
  static const Color statusDelivered    = Color(0xFF1B5E20);
  static const Color statusPendingCash  = Color(0xFFFFB300);
  static const Color statusAwaiting     = Color(0xFF00838F);
  static const Color statusAwaitingReturn = Color(0xFF8E24AA);
  static const Color statusFailed       = Color(0xFFB71C1C);
  static const Color statusPink         = Color(0xFFE91E8C);

  static Color fromApiColor(String color) {
    switch (color.toLowerCase()) {
      case 'green':  return statusDelivered;
      case 'blue':   return statusDispatched;
      case 'orange': return statusUndispatched;
      case 'pink':   return statusPink;
      case 'purple': return statusRescheduled;
      case 'red':    return statusFailed;
      case 'gray':
      case 'grey':   return textSecondary;
      case 'violet':
case 'indigo':
  return statusAwaitingReturn;
      default:       return textSecondary;
    }
  }

  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: background,
    colorScheme: const ColorScheme.dark(
      primary: primary,
      secondary: accent,
      surface: surface,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: surface,
      foregroundColor: textPrimary,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: textPrimary,
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    ),
    cardTheme: CardThemeData(
      color: surface,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: textSecondary,
        minimumSize: const Size(double.infinity, 52),
        side: BorderSide(color: Colors.white.withOpacity(0.12)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceAlt,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: primary, width: 1.5),
      ),
      labelStyle: const TextStyle(color: textSecondary),
      hintStyle: TextStyle(color: textSecondary.withOpacity(0.5)),
      prefixIconColor: textSecondary,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: surface,
      indicatorColor: primary.withOpacity(0.2),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const TextStyle(color: primary, fontSize: 11, fontWeight: FontWeight.w600);
        }
        return const TextStyle(color: textSecondary, fontSize: 11);
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: primary);
        }
        return const IconThemeData(color: textSecondary);
      }),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
  );
}
