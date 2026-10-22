import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'cubits/auth_cubit.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/home_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/emotion_history_screen.dart';
import 'screens/activity_history_screen.dart';
import 'screens/information_screen.dart';
import 'screens/counselor_screen.dart';
import 'screens/setting_history.dart';
import 'screens/feedback_screen.dart';
import 'screens/dass_questions_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    BlocProvider(
      create: (_) => AuthCubit()..restoreSession(),
      child: const MeOkKitApp(),
    ),
  );
}

class MeOkKitApp extends StatelessWidget {
  const MeOkKitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MeOkKit',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFD94B4B),
        ),
        pageTransitionsTheme: const PageTransitionsTheme(
          builders: {
            TargetPlatform.android: CupertinoPageTransitionsBuilder(),
            TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
            TargetPlatform.windows: CupertinoPageTransitionsBuilder(),
            TargetPlatform.macOS: CupertinoPageTransitionsBuilder(),
            TargetPlatform.linux: CupertinoPageTransitionsBuilder(),
          },
        ),
      ),
      builder: (context, child) {
        final mediaQuery = MediaQuery.of(context);
        final isWide = mediaQuery.size.width > 300;
        final effectiveWidth = mediaQuery.size.width;

        return ColoredBox(
          color: const Color(0xFFF7EBEA),
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 500),
              decoration: isWide
                  ? BoxDecoration(
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFBD3546).withOpacity(0.12),
                          blurRadius: 30,
                          spreadRadius: 2,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    )
                  : null,
              child: ClipRect(
                child: MediaQuery(
                  data: mediaQuery.copyWith(
                    size: Size(effectiveWidth, mediaQuery.size.height),
                  ),
                  child: child ?? const SizedBox.shrink(),
                ),
              ),
            ),
          ),
        );
      },
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/forgot-password': (context) => const ForgotPasswordScreen(),
        '/home': (context) => const HomeScreen(initialIndex: 0),
        '/profile': (context) => const ProfileScreen(),
        '/methods': (context) => const HomeScreen(initialIndex: 1),
        '/emotion-history': (context) => const EmotionHistoryScreen(),
        '/activity-history': (context) => const ActivityHistoryScreen(),
        '/information': (context) => const InformationScreen(),
        '/counselor': (context) => const CounselorScreen(),
        '/setting-history': (context) => const SettingHistoryScreen(),
        '/setting': (context) => const HomeScreen(initialIndex: 2),
        '/feedback': (context) => const FeedbackScreen(),
        '/dass-questions': (context) => const DassQuestionsScreen(),
      },
    );
  }
}
