import 'package:flutter/material.dart';

final appTheme = ThemeData(
  primarySwatch: Colors.blue,
);

class AppTheme {
  AppTheme._();
  static final lightTheme = ThemeData(
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: AppBarTheme(
        color: Colors.white,
        iconTheme: IconThemeData(
          color: Colors.black,
        ),
      ),
      backgroundColor: Colors.black,
      textTheme: TextTheme(
        bodyText2: TextStyle(
          color: Colors.black,
        ),
      ),
      buttonTheme: ButtonThemeData(buttonColor: Colors.black));
  static final darkTheme = ThemeData(
      backgroundColor: Colors.white,
      scaffoldBackgroundColor: Color(0xFF141221),
      // Colors.black,
      // Color(0xFF192734),
      appBarTheme: AppBarTheme(
        color: Colors.black,
        iconTheme: IconThemeData(
          color: Colors.white,
        ),
      ),
      textTheme: TextTheme(
        bodyText2: TextStyle(
          color: Colors.white,
        ),
      ),
      buttonTheme: ButtonThemeData(buttonColor: Colors.white));
}
