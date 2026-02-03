import 'package:local_auth/local_auth.dart';
import '../services/storage_service.dart';

class AuthService {
  final StorageService _storageService;
  final LocalAuthentication _localAuth = LocalAuthentication();

  static const String _pinKey = 'app_pin';
  static const String _biometricEnabledKey = 'biometric_enabled';
  static const String _appLockedKey = 'app_locked';

  AuthService(this._storageService);

  // Check if PIN is set
  bool isPinSet() {
    return _storageService.hasData(_pinKey);
  }

  // Set PIN
  Future<void> setPin(String pin) async {
    await _storageService.write(_pinKey, pin);
  }

  // Verify PIN
  bool verifyPin(String pin) {
    final storedPin = _storageService.read<String>(_pinKey);
    return storedPin == pin;
  }

  // Get PIN Length
  int getPinLength() {
    final storedPin = _storageService.read<String>(_pinKey);
    return storedPin?.length ?? 4;
  }

  // Check if biometric is enabled
  bool isBiometricEnabled() {
    return _storageService.read<bool>(_biometricEnabledKey) ?? false;
  }

  // Enable/disable biometric
  Future<void> setBiometricEnabled(bool enabled) async {
    await _storageService.write(_biometricEnabledKey, enabled);
  }

  // Check if biometric is available on device
  Future<bool> canCheckBiometrics() async {
    try {
      return await _localAuth.canCheckBiometrics;
    } catch (e) {
      return false;
    }
  }

  // Get available biometric types
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _localAuth.getAvailableBiometrics();
    } catch (e) {
      return [];
    }
  }

  // Authenticate with biometrics
  Future<bool> authenticateWithBiometrics() async {
    try {
      return await _localAuth.authenticate(
        localizedReason: 'Please authenticate to access the app',
      );
    } catch (e) {
      return false;
    }
  }

  // Check if app is locked
  bool isAppLocked() {
    return _storageService.read<bool>(_appLockedKey) ?? false;
  }

  // Lock the app
  Future<void> lockApp() async {
    await _storageService.write(_appLockedKey, true);
  }

  // Unlock the app
  Future<void> unlockApp() async {
    await _storageService.write(_appLockedKey, false);
  }
}
