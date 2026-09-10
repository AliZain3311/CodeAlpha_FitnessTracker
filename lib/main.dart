import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'screens/dashboard_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'services/activity_service.dart';
import 'services/auth_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  await AuthService.init();

  await ActivityService.init();

  runApp(const FitTrackApp());
}

class FitTrackApp extends StatelessWidget {
  const FitTrackApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FitTrack',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.green,
        scaffoldBackgroundColor: const Color(0xFFF7F9F7),
        appBarTheme: const AppBarTheme(elevation: 0, centerTitle: false),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _showRegister = false;

  void _showLogin() {
    setState(() {
      _showRegister = false;
    });
  }

  void _showRegisterScreen() {
    setState(() {
      _showRegister = true;
    });
  }

  void _handleLoginSuccess() {
    setState(() {
      _showRegister = false;
    });
  }

  void _handleRegisterSuccess() {
    // Registration is successful, but the user
    // is NOT automatically logged in.
    //
    // Therefore, return the user to Login screen.
    setState(() {
      _showRegister = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Account created successfully. '
          'Please login with your email and password.',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _handleLogout() async {
    await AuthService.logout();

    if (!mounted) {
      return;
    }

    setState(() {
      _showRegister = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    // User is already authenticated.
    if (AuthService.isLoggedIn) {
      return DashboardScreen(onLogout: _handleLogout);
    }

    // Show Register screen.
    if (_showRegister) {
      return RegisterScreen(
        onLoginTap: _showLogin,
        onRegisterSuccess: _handleRegisterSuccess,
      );
    }

    // Show Login screen.
    return LoginScreen(
      onRegisterTap: _showRegisterScreen,
      onLoginSuccess: _handleLoginSuccess,
    );
  }
}
