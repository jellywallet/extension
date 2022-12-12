part of '../theme.dart';

ThemeData createLightTheme() {
  return ThemeData(
    snackBarTheme: SnackBarThemeData(
      backgroundColor: Colors.white,
      actionTextColor: Colors.black,
    ),
    scaffoldBackgroundColor: AppColors.whiteLilac,
    dialogBackgroundColor: Color(0xffFAFAFA),
    primaryColorLight: Color(0xFF5D5D5D),
    selectedRowColor: AppColors.selectLight.withOpacity(0.07),
    shadowColor: Colors.grey[300]!,
    cardColor: Colors.white,
    backgroundColor: Colors.white,
    secondaryHeaderColor: AppColors.lightGreyColor,
    colorScheme: ColorScheme.light(
      primary: AppColors.pinkColor,
      primaryVariant: AppColors.pinkColor,
    ),
    iconTheme: IconThemeData(
      color: Colors.black,
    ),
    textTheme: createTextTheme(AppColors.darkTextColor),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        primary: Colors.white,
        onPrimary: AppColors.darkTextColor,
        shape: RoundedRectangleBorder(
          side: BorderSide(
            color: AppColors.lightGreyColor,
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        textStyle: TextStyle(
          color: AppColors.darkTextColor,
          fontSize: 14,
          fontWeight: FontWeight.normal,
        ),
        shadowColor: Colors.black.withOpacity(0.35),
        elevation: 8,
      ),
    ),
    dividerColor: Color(0xFFEDEDED),
    appBarTheme: AppBarTheme(
      elevation: 5,
      backgroundColor: Colors.white,
      shadowColor: Colors.black.withOpacity(0.35),
      titleTextStyle: TextStyle(
        color: AppColors.darkTextColor,
      ),
      actionsIconTheme: IconThemeData(
        color: AppColors.darkTextColor,
      ),
      foregroundColor: Color(0xFFEDEDED),
    ),
    inputDecorationTheme: InputDecorationTheme(
      hoverColor: Colors.transparent,
      contentPadding:
          const EdgeInsets.symmetric(vertical: 2.0, horizontal: 10.0),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(inputBorderRadius),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(inputBorderRadius),
        borderSide: BorderSide(
          width: 1,
          color: Color(0xFFF0EEF6),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(inputBorderRadius),
        borderSide: BorderSide(
          width: 1,
          color: AppColors.pinkColor,
        ),
      ),
      fillColor: Colors.white.withOpacity(0.65),
    ),
    textSelectionTheme:
        TextSelectionThemeData(selectionColor: Color(0xFF7D7D7D)),
  ).copyWith(splashColor: Colors.transparent);
}