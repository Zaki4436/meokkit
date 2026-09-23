import 'package:flutter/material.dart';

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

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const MeOkKitApp());
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
      ),

      initialRoute: '/',

      routes: {
        '/': (context) => const SplashScreen(),

        '/login': (context) =>
            const LoginScreen(),

        '/signup': (context) =>
            const SignupScreen(),

        '/forgot-password': (context) =>
            const ForgotPasswordScreen(),

        '/home': (context) =>
            const HomeScreen(),

        '/profile': (context) =>
            const ProfileScreen(),

        '/emotion-history': (context) =>
            const EmotionHistoryScreen(),

        '/activity-history': (context) =>
            const ActivityHistoryScreen(),

        '/information': (context) =>
            const InformationScreen(),

        '/counselor': (context) =>
            const CounselorScreen(),

        '/setting-history': (context) =>
            const SettingHistoryScreen(),
      },
    );
  }
}