import 'package:flutter/material.dart';

ThemeData buildAppTheme() {

  const Color primaryColor = Colors.black;
  const Color secondaryColor = Colors.green;
  const Color backgroundColor = Color(0xFFF3F4F6);
  const Color errorColor = Color(0xFFB00020);


  const TextTheme textTheme = TextTheme(
    headlineLarge: TextStyle(fontSize: 32.0, fontWeight: FontWeight.bold, color: Colors.black),
    headlineMedium: TextStyle(fontSize: 24.0, fontWeight: FontWeight.w600, color: Colors.black),
    bodyLarge: TextStyle(fontSize: 14.0, fontWeight: FontWeight.normal, color: Colors.black),
    bodyMedium: TextStyle(fontSize: 12.0, fontWeight: FontWeight.normal, color: Colors.black),
  );

  return ThemeData(

    colorScheme: ColorScheme(
      primary: primaryColor,
      onPrimaryFixedVariant: Color(0xFF3700B3),
      secondary: secondaryColor,
      onSecondaryFixedVariant: Color(0xFF018786),
      surface: Colors.white,
      background: backgroundColor,
      error: errorColor,
      onPrimary: Colors.white,
      onSecondary: Colors.black,
      onSurface: Colors.black,
      onBackground: Colors.black,
      onError: Colors.white,
      brightness: Brightness.light,
    ),


    textTheme: textTheme,


    buttonTheme: ButtonThemeData(
      buttonColor: primaryColor,
      textTheme: ButtonTextTheme.primary,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
    ),


    appBarTheme: AppBarTheme(
      color: Colors.white,
      elevation: 1,
      titleTextStyle: textTheme.headlineLarge,
      iconTheme: IconThemeData(color: Colors.black),
    ),


    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(color: primaryColor),
      ),
    ),


    snackBarTheme: SnackBarThemeData(
      backgroundColor: secondaryColor,
      contentTextStyle: TextStyle(color: Colors.white),
    ),


    iconTheme: IconThemeData(
      color: primaryColor,
    ),


    cardTheme: CardTheme(
      color: Colors.white,
      shadowColor: Colors.black.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0), // 둥근 모서리 설정
      ),
      margin: EdgeInsets.all(16.0), // 카드 외부 여백
      elevation: 5, // 카드 그림자 설정
    ),


    visualDensity: VisualDensity.adaptivePlatformDensity, checkboxTheme: CheckboxThemeData(
     fillColor: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
     if (states.contains(MaterialState.disabled)) { return null; }
     if (states.contains(MaterialState.selected)) { return secondaryColor; }
     return null;
     }),
     ), radioTheme: RadioThemeData(
     fillColor: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
     if (states.contains(MaterialState.disabled)) { return null; }
     if (states.contains(MaterialState.selected)) { return secondaryColor; }
     return null;
     }),
     ), switchTheme: SwitchThemeData(
     thumbColor: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
     if (states.contains(MaterialState.disabled)) { return null; }
     if (states.contains(MaterialState.selected)) { return secondaryColor; }
     return null;
     }),
     trackColor: MaterialStateProperty.resolveWith<Color?>((Set<MaterialState> states) {
     if (states.contains(MaterialState.disabled)) { return null; }
     if (states.contains(MaterialState.selected)) { return secondaryColor; }
     return null;
     }),
     ),
      );
    }

var themeData = buildAppTheme();