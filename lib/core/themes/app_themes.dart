import 'package:customer_mobile_app/imports_bindings.dart';

///*
@immutable
sealed class AppThemes {
  // ///* Set status bar color
  // static void setStatusBarColor() {
  //   SystemChrome.setSystemUIOverlayStyle(
  //     const SystemUiOverlayStyle(
  //       statusBarColor: AppColors.primary,
  //       statusBarIconBrightness: Brightness.light,
  //     ),
  //   );
  // }

  ///*
  static ThemeData get light => ThemeData(
        fontFamily: 'Poppins',
        scaffoldBackgroundColor: AppColors.bgcolorgrey,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            textStyle: AppStyles.text16Px.w500.light,
            padding: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            backgroundColor: AppColors.button,
            disabledBackgroundColor: AppColors.disabledButton,
            foregroundColor: AppColors.light,
            disabledForegroundColor: AppColors.light,
          ),
        ),
        splashColor: Colors.transparent,
        appBarTheme: AppBarTheme(
          centerTitle: true,
          toolbarHeight: 80,
          titleTextStyle: AppStyles.text18Px.w500.copyWith(color: AppColors.textDark, fontWeight: FontWeight.w500),
          iconTheme: IconThemeData(color: AppColors.textDark),
          backgroundColor: AppColors.bgcolorgrey,
          surfaceTintColor: AppColors.bgcolorgrey,
          elevation: 0,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.fieldFillColor,
          errorStyle: AppStyles.text14Px.poppins.w400.error,
          border: const OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.all(Radius.circular(8))),
          enabledBorder: const OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.all(Radius.circular(8))),
          disabledBorder: const OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.all(Radius.circular(8))),
          errorBorder: const OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.all(Radius.circular(8))),
          focusedErrorBorder: const OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.all(Radius.circular(8))),
          focusedBorder: const OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.all(Radius.circular(8))),
        ),
      );

  static ThemeData get dark => ThemeData(
        brightness: Brightness.dark,
        fontFamily: 'Poppins',
        scaffoldBackgroundColor: AppColors.bgcolorgrey,
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            textStyle: AppStyles.text16Px.w500.copyWith(color: Colors.black),
            padding: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            backgroundColor: AppColors.button,
            disabledBackgroundColor: AppColors.disabledButton,
            foregroundColor: Colors.black,
            disabledForegroundColor: Colors.black,
          ),
        ),
        splashColor: Colors.transparent,
        appBarTheme: AppBarTheme(
          centerTitle: true,
          toolbarHeight: 80,
          titleTextStyle: AppStyles.text18Px.w500.copyWith(color: AppColors.textDark, fontWeight: FontWeight.w500),
          iconTheme: IconThemeData(color: AppColors.textDark),
          backgroundColor: AppColors.bgcolorgrey,
          surfaceTintColor: AppColors.bgcolorgrey,
          elevation: 0,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.fieldFillColor,
          errorStyle: AppStyles.text14Px.poppins.w400.error,
          border: const OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.all(Radius.circular(8))),
          enabledBorder: const OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.all(Radius.circular(8))),
          disabledBorder: const OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.all(Radius.circular(8))),
          errorBorder: const OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.all(Radius.circular(8))),
          focusedErrorBorder: const OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.all(Radius.circular(8))),
          focusedBorder: const OutlineInputBorder(borderSide: BorderSide.none, borderRadius: BorderRadius.all(Radius.circular(8))),
        ),
      );
}
