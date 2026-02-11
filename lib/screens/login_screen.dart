import 'package:flutter/material.dart';
import '../utils/storage.dart';
import '../utils/runtime_key.dart';
import '../utils/biometric_service.dart';
import 'home_screen.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;
  const LoginScreen({super.key, required this.onToggleTheme});

  @override
  State<LoginScreen> createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final controller = TextEditingController();
  bool obscure = true;
  String? error;
  bool canUseBiometrics = false;
  bool isBioEnabled = false;
  bool isAuthenticating = false;

  @override
  void initState() {
    super.initState();
    checkBio();
  }

  Future<void> checkBio() async {
    final canUse = await BiometricService.canUseBiometrics();
    final bioEnabled = await BiometricService.isBiometricEnabled();
    setState(() {
      canUseBiometrics = canUse;
      isBioEnabled = bioEnabled;
    });
  }

  Future<void> bioAuth() async {
    setState(() => isAuthenticating = true);
    final (authenticated, _) = await BiometricService.authenticateWithError();

    if (!mounted) return;
    if (authenticated) {
      final password = await BiometricService.getStoredMasterPassword();
      if (!mounted) return;

      if (password != null) {
        RuntimeKey.rawPassword = password;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => HomeScreen(onToggleTheme: widget.onToggleTheme),
          ),
        );
      } else {
        setState(() {
          error = 'Biometric password not found. Please enter manually.';
          isAuthenticating = false;
        });
      }
    } else {
      setState(() {
        error = 'Biometric authentication failed';
        isAuthenticating = false;
      });
    }
  }

  Future<void> login() async {
    final ok = await Storage.verifyMasterPassword(controller.text);
    if (!ok) {
      setState(() => error = 'Wrong password');
      return;
    }

    RuntimeKey.rawPassword = controller.text;
    if (!mounted) return;
    navigateToHome();
  }

  void navigateToHome() {
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => HomeScreen(onToggleTheme: widget.onToggleTheme),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: controller,
              obscureText: obscure,
              onSubmitted: (_) => login(),
              decoration: InputDecoration(
                labelText: 'Master Password',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(obscure ? Icons.visibility : Icons.visibility_off),
                  onPressed: () => setState(() => obscure = !obscure),
                ),
              ),
            ),
            if (error != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(error!, style: const TextStyle(color: Colors.red)),
              ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: login,
                child: const Text('Login'),
              ),
            ),
            if (canUseBiometrics && isBioEnabled) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: isAuthenticating ? null : bioAuth,
                  icon: const Icon(Icons.fingerprint),
                  label: const Text('Try Biometric'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
