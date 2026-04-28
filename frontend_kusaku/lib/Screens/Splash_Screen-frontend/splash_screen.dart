import 'dart:async';
import 'package:flutter/material.dart';
import '../Login_Screen-frontend/login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _sequenceController; 
  late AnimationController _rotationController; 

  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _rotationController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );

    // untuk Urutan Animasi
    _sequenceController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );

    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: ConstantTween(0.5), weight: 50),
      TweenSequenceItem(
        tween: Tween(begin: 0.5, end: 1.0).chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 50,
      ),
    ]).animate(_sequenceController);

    _fadeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: ConstantTween(0.0), weight: 15),
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 1.0).chain(CurveTween(curve: Curves.easeIn)),
        weight: 35,
      ),
      TweenSequenceItem(tween: ConstantTween(1.0), weight: 50),
    ]).animate(_sequenceController);

    _sequenceController.forward();

    Future.delayed(const Duration(milliseconds: 1250), () {
      if (mounted) {
        _rotationController.repeat();
      }
    });

    Timer(const Duration(seconds: 4), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const LoginScreen(),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _sequenceController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF93C5FD), // Latar belakang biru muda
      body: Stack(
        children: [
          // Logo (Berputar) dan Judul "KUSAKU"
          Center(
            // untuk mengatur ukuran dari kecil ke besar
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo berputar
                  RotationTransition(
                    turns: _rotationController,
                    child: Image.asset(
                      'assets/images/Logo.png',
                      width: 100, // Ukuran maksimal logo
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Gambar Teks "KUSAKU"
                  Image.asset(
                    'assets/images/KUSAKU.png',
                    width: 150, // Ukuran maksimal tulisan
                  ),
                ],
              ),
            ),
          ),

          // Gambar Tagline "Ayo..."
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 50.0),
              // Di-wrap dengan FadeTransition untuk mengatur kemunculannya
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: Image.asset(
                  'assets/images/Ayo Atur Pengeluaranmu!.png',
                  width: 250,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
