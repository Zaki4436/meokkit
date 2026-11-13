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
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

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

    _controller.forward();
    _startApp();
  }

  @override
  void dispose() {
    _controller.dispose();
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
                  children:[
                    Image.asset(
                      'assets/icon/logo_nobg.png',
                      width: 220,
                      fit: BoxFit.contain,
                    ),
                    Text(
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
                    Transform.translate(
                      offset: const Offset(0, -6),
                      child: Image.asset(
                        'assets/icon/app_name.png',
                        width: 200,
                        fit: BoxFit.contain,
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
