import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/utils/extension.dart';
import 'dart:async';

import 'package:flutter_application_1/presentation/screens/library/library_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    // انیمیشن ورود لوگو
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);

    _controller.forward();

    // بعد 3 ثانیه صفحه اصلی اپ
    Timer(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LibraryScreen()),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FadeTransition(
          opacity: _animation,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // لوگو: می‌تونی PNG شفاف یا SVG بذاری
              Image.asset(
                'assets/icons/logo.png',
                fit: BoxFit.fill,
                width: MediaQuery.of(context).size.width * 0.8,
                height: MediaQuery.of(context).size.height * 0.4,
              ),
              const SizedBox(height: 10),
              Text(
                'خوان PDF|خوانا',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: context.theme.primaryColor,
                ),
              ),
              const SizedBox(height: 10),

              Padding(
                padding: .only(
                  left: context.screenSize.width * 0.3,
                  right: context.screenSize.width * 0.3,
                ),
                child: LinearProgressIndicator(
                  color: context.theme.primaryColor,
                  backgroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
