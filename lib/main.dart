import 'package:compass_vn/screen/home_screen.dart';
import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          backgroundColor: Color.fromARGB(222, 190, 10, 10),
          elevation: 0,
          iconTheme: IconThemeData(color: Colors.white),
        ),
      ),
      home: const HomeScreen(),
    );
  }
}
