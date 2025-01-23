import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MyThemeData {
  static ThemeData myTheme() {
    // Đặt màu nền cho status bar
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Color(0xffd32f2f), // Màu đỏ Việt Nam
        statusBarIconBrightness: Brightness.light,
      ),
    );

    return ThemeData(
      fontFamily: "opensans",
      brightness: Brightness.light,
      primaryColor: const Color(0xffd32f2f), // Màu đỏ chủ đạo
      scaffoldBackgroundColor: Colors.transparent, // Nền trong suốt
      cardColor: Colors.transparent, // Nền Card trong suốt
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xffd32f2f), // Màu đỏ cho AppBar
        titleTextStyle: TextStyle(
          fontSize: 18,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(color: Color(0xffd32f2f)),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 57,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        bodyLarge: TextStyle(
          fontSize: 18,
          color: Colors.white,
        ),
        bodyMedium: TextStyle(
          fontSize: 16,
          color: Color(0xff212121), // Chữ màu đen đậm cho các nội dung phụ
        ),
        headlineMedium: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Color(0xffffcc00), // Màu vàng nổi bật cho tiêu đề
        ),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        filled: true,
        fillColor: Color(0xffd32f2f), // Nền nhạt màu đỏ
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xffd32f2f), width: 2),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xffffcc00), width: 2),
        ),
        labelStyle: TextStyle(color: Color(0xffd32f2f)),
        hintStyle: TextStyle(color: Colors.grey),
        suffixIconColor: Color(0xffffcc00),
        prefixIconColor: Color(0xffd32f2f),
      ),
      tabBarTheme: const TabBarTheme(
        indicatorColor: Color(0xffffcc00), // Màu vàng cho TabBar
        unselectedLabelStyle: TextStyle(
          color: Color(0xffd32f2f),
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
        labelStyle: TextStyle(
          color: Color(0xffffcc00),
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        indicatorSize: TabBarIndicatorSize.label,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.all(const Color(0xffd32f2f)),
          foregroundColor: WidgetStateProperty.all(const Color(0xFFEC8494)),
          elevation: WidgetStateProperty.all(5),
          shape: WidgetStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          textStyle: WidgetStateProperty.all(
            const TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
          ),
          shadowColor: WidgetStateProperty.all(
            const Color(0xffd32f2f).withOpacity(0.5),
          ),
          padding: WidgetStateProperty.all(
            const EdgeInsets.symmetric(horizontal: 30, vertical: 16),
          ),
        ),
      ),
      splashColor: const Color(0xffffcc00).withOpacity(0.3),
      highlightColor: Colors.transparent,
    );
  }
}
