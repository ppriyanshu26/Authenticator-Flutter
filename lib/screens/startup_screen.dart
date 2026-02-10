import 'package:flutter/material.dart';
import '../utils/storage.dart';
import '../utils/biometric_service.dart';
import 'create_password_screen.dart';
import 'login_screen.dart';
import 'biometric_login_screen.dart';

class StartupScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;
  const StartupScreen({super.key, required this.onToggleTheme});

  @override
  State<StartupScreen> createState() => StartupScreenState();
}

class StartupScreenState extends State<StartupScreen> {
  bool? hasPassword;
  bool? bioEnabled;

  @override
  void initState() {
    super.initState();
    check();
  }

  Future<void> check() async {
    hasPassword = await Storage.hasMasterPassword();
    if (hasPassword!) {
      bioEnabled = await BiometricService.isBiometricEnabled();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (hasPassword == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (!hasPassword!) {
      return CreatePasswordScreen(onToggleTheme: widget.onToggleTheme);
    }

    if (bioEnabled == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (bioEnabled!) {
      return BiometricLoginScreen(onToggleTheme: widget.onToggleTheme);
    }

    return LoginScreen(onToggleTheme: widget.onToggleTheme);
  }
}
