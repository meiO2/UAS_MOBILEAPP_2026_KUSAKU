import 'package:flutter/material.dart';
import 'package:frontend_kusaku/Screens/Splash_Screen-frontend/splash_screen.dart'; 

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kusaku',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Color(0xFF93C5FD)),
        useMaterial3: true,
      ),
      home: const SplashScreen(), 
    );
  }
}