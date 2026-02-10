import 'package:local_auth/local_auth.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class BiometricService {
  static const passStore = FlutterSecureStorage();
  static const bioKey = 'biometric_enabled';
  static const passKey = 'biometric_password';

  static final _localAuth = LocalAuthentication();
  static Future<bool> canUseBiometrics() async {
    try {
      return await _localAuth.canCheckBiometrics;
    } catch (_) {
      return false;
    }
  }

  static Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (_) {
      return [];
    }
  }

  static Future<(bool authenticated, String? error)>
  authenticateWithError() async {
    try {
      final result = await _localAuth.authenticate(
        localizedReason: 'Unlock CipherAuth with your biometric',
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
          useErrorDialogs: true,
        ),
      );
      return (result, null);
    } catch (e) {
      return (false, e.toString());
    }
  }

  static Future<bool> authenticate() async {
    final (result, _) = await authenticateWithError();
    return result;
  }

  static Future<void> enableBiometric(String masterPassword) async {
    await passStore.write(key: passKey, value: masterPassword);
    await passStore.write(key: bioKey, value: 'true');
  }

  static Future<void> disableBiometric() async {
    await passStore.delete(key: bioKey);
    await passStore.delete(key: passKey);
  }

  static Future<bool> isBiometricEnabled() async {
    final value = await passStore.read(key: bioKey);
    return value == 'true';
  }

  static Future<String?> getStoredMasterPassword() async {
    return await passStore.read(key: passKey);
  }
}
