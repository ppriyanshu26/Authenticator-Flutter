import 'package:flutter/material.dart';
import '../utils/biometric_service.dart';
import '../utils/runtime_key.dart';
import 'home_screen.dart';
import 'login_screen.dart';

class BiometricLoginScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;

  const BiometricLoginScreen({super.key, required this.onToggleTheme});

  @override
  State<BiometricLoginScreen> createState() => BiometricLoginScreenState();
}

class BiometricLoginScreenState extends State<BiometricLoginScreen> {
  String? error;
  bool isAuthenticating = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _attemptBiometricAuth();
    });
  }

  Future<void> _attemptBiometricAuth() async {
    setState(() => isAuthenticating = true);
    final (authenticated, authError) =
        await BiometricService.authenticateWithError();

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
          error = 'Password not found. Please enter manually.';
          isAuthenticating = false;
        });
      }
    } else {
      setState(() {
        error = authError ?? 'Biometric authentication failed';
        isAuthenticating = false;
      });
    }
  }

  void _fallbackToPassword() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => LoginScreen(onToggleTheme: widget.onToggleTheme),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Unlock')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(Icons.fingerprint, size: 80, color: Colors.blue),
              const SizedBox(height: 24),
              const Text(
                'Unlock with Biometric',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              if (error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      border: Border.all(color: Colors.red.shade300),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      error!,
                      style: TextStyle(
                        color: Colors.red.shade900,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ElevatedButton.icon(
                onPressed: isAuthenticating ? null : _attemptBiometricAuth,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: _fallbackToPassword,
                child: const Text('Use Master Password Instead'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
