import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubits/auth_cubit.dart';
import '../cubits/auth_state.dart';
import '../widgets/app_background.dart';
import 'home_screen.dart';
import 'login_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late AnimationController _motionController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _titleFadeAnimation;
  late Animation<double> _wordmarkFadeAnimation;
  late Animation<double> _logoFloatAnimation;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _wordmarkFloatAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _scaleAnimation = Tween<double>(begin: 0.88, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
      ),
    );
    _titleFadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.25, 0.8, curve: Curves.easeOut),
    );
    _wordmarkFadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.45, 1, curve: Curves.easeOut),
    );

    _motionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    final gentleMotion = CurvedAnimation(
      parent: _motionController,
      curve: Curves.easeInOut,
    );
    _logoFloatAnimation =
        Tween<double>(begin: 0, end: -5).animate(gentleMotion);
    _logoScaleAnimation =
        Tween<double>(begin: 1, end: 1.025).animate(gentleMotion);
    _wordmarkFloatAnimation =
        Tween<double>(begin: 0, end: -3).animate(gentleMotion);

    _controller.forward();
    _motionController.repeat(reverse: true);
    _startApp();
  }

  @override
  void dispose() {
    _controller.dispose();
    _motionController.dispose();
    super.dispose();
  }

  Future<void> _startApp() async {
    final authCubit = context.read<AuthCubit>();

    // Give time for logo entrance and a comfortable viewing moment
    await Future.delayed(
      const Duration(milliseconds: 2200),
    );

    await authCubit.restoreSession();

    final loggedIn = authCubit.state.status == AuthStatus.authenticated;

    if (!mounted) return;

    final Widget nextScreen =
        loggedIn ? const HomeScreen(initialIndex: 0) : const LoginScreen();

    // Smooth fade transition to next screen
    Navigator.pushReplacement(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 900),
        pageBuilder: (context, animation, secondaryAnimation) => nextScreen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOutCubic,
            ),
            child: child,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(26, 250, 26, 0),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: Column(
                  children: [
                    AnimatedBuilder(
                      animation: _motionController,
                      child: Image.asset(
                        'assets/icon/logo_nobg.png',
                        width: 220,
                        fit: BoxFit.contain,
                      ),
                      builder: (context, child) => Transform.translate(
                        offset: Offset(0, _logoFloatAnimation.value),
                        child: Transform.scale(
                          scale: _logoScaleAnimation.value,
                          child: child,
                        ),
                      ),
                    ),
                    FadeTransition(
                      opacity: _titleFadeAnimation,
                      child: Text(
                        'SELAMAT DATANG\nKe Halaman',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'CooperBT',
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFFFF3849),
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                    FadeTransition(
                      opacity: _wordmarkFadeAnimation,
                      child: AnimatedBuilder(
                        animation: _motionController,
                        child: Transform.translate(
                          offset: const Offset(0, -6),
                          child: Image.asset(
                            'assets/icon/app_name.png',
                            width: 200,
                            fit: BoxFit.contain,
                          ),
                        ),
                        builder: (context, child) => Transform.translate(
                          offset: Offset(0, _wordmarkFloatAnimation.value),
                          child: child,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
