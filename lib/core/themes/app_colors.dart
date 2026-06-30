// ignore_for_file: public_member_api_docs

import 'package:feggy_core/imports_bindings.dart';

enum AppThemeMode { light, dark, cream }

///* Store colors using this application
@immutable
abstract class AppColors {
  static AppThemeMode currentTheme = AppThemeMode.light;

  //*Theme primary color
  static const Color primary = Color(0xffCF0B10);
  static const Color lightPrimary = Color(0xffFFD0D0);
  static const Color disabledButton = Color(0xffD0D0D0);
  static const Color error = Color(0xffFF3434);

  static Color get light => currentTheme == AppThemeMode.dark ? const Color(0xFF1E1E1E) : (currentTheme == AppThemeMode.cream ? const Color(0xFFFFFDF5) : Colors.white);
  static Color get dark => currentTheme == AppThemeMode.dark ? Colors.white : const Color(0xFF020202);
  static Color get button => currentTheme == AppThemeMode.dark ? const Color(0xFFF7F7F7) : const Color(0xff222222);
  static Color get grey => currentTheme == AppThemeMode.dark ? const Color(0xFF2C2C2C) : const Color(0xffEEEEEE);

  // Add new colors
  static Color get textDark => currentTheme == AppThemeMode.dark ? Colors.white : const Color(0xFF020202);
  static Color get textGrey => currentTheme == AppThemeMode.dark ? const Color(0xFFB0B0B0) : const Color(0xFF666666);
  static Color get borderGrey => currentTheme == AppThemeMode.dark ? const Color(0xFF2C2C2C) : const Color(0xFFE8E8E8);
  static Color get iconBackground => currentTheme == AppThemeMode.dark ? const Color(0xFF2C2C2C) : const Color(0xffE6E6E6);
  static Color get lightGrey => currentTheme == AppThemeMode.dark ? const Color(0xFF2C2C2C) : const Color(0xFFE8E8E8);
  static Color get fieldFillColor => currentTheme == AppThemeMode.dark ? const Color(0xFF1E1E1E) : (currentTheme == AppThemeMode.cream ? const Color(0xFFF5F0E6) : const Color(0xFFF4F5FA));
  static Color get bgcolorgrey => currentTheme == AppThemeMode.dark ? const Color(0xFF121212) : (currentTheme == AppThemeMode.cream ? const Color(0xFFFDF9F2) : const Color(0xFFF7F7F7));
}
