import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/utils/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/services/auth_service.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthService _authService;

  AuthCubit(this._authService) : super(const AuthState()) {
    _initialize();
  }

  Future<void> _initialize() async {
    final isPinSet = _authService.isPinSet();
    final isBiometricEnabled = _authService.isBiometricEnabled();
    final isBiometricAvailable = await _authService.canCheckBiometrics();
    final pinLength = _authService.getPinLength();

    // Always lock on startup if PIN is set
    final shouldBeLocked = isPinSet;

    emit(
      state.copyWith(
        isPinSet: isPinSet,
        isBiometricEnabled: isBiometricEnabled,
        isBiometricAvailable: isBiometricAvailable,
        pinLength: pinLength,
        status: shouldBeLocked ? AuthStatus.locked : AuthStatus.unlocked,
      ),
    );
  }

  // Set up PIN
  Future<void> setupPin(String pin) async {
    await _authService.setPin(pin);
    emit(state.copyWith(isPinSet: true, pinLength: pin.length));
  }

  // Verify PIN
  Future<bool> verifyPin(String pin, BuildContext context) async {
    final loc = AppLocalizations.of(context);

    emit(state.copyWith(status: AuthStatus.authenticating));

    final isValid = _authService.verifyPin(pin);

    if (isValid) {
      await _authService.unlockApp();
      emit(state.copyWith(status: AuthStatus.unlocked));
      return true;
    } else {
      emit(
        state.copyWith(status: AuthStatus.locked, errorMessage: loc.invalidPin),
      );
      return false;
    }
  }

  // Enable/disable biometric
  Future<void> setBiometricEnabled(bool enabled) async {
    await _authService.setBiometricEnabled(enabled);
    emit(state.copyWith(isBiometricEnabled: enabled));
  }

  // Authenticate with biometrics
  Future<bool> authenticateWithBiometrics(BuildContext context) async {
    final loc = AppLocalizations.of(context);
    emit(state.copyWith(status: AuthStatus.authenticating));

    final success = await _authService.authenticateWithBiometrics();

    if (success) {
      await _authService.unlockApp();
      emit(state.copyWith(status: AuthStatus.unlocked));
      return true;
    } else {
      emit(
        state.copyWith(
          status: AuthStatus.locked,
          errorMessage: loc.biometricAuthFailed,
        ),
      );
      return false;
    }
  }

  // Lock the app
  Future<void> lockApp() async {
    await _authService.lockApp();
    emit(state.copyWith(status: AuthStatus.locked));
  }

  // Unlock the app (after successful auth)
  Future<void> unlockApp() async {
    await _authService.unlockApp();
    emit(state.copyWith(status: AuthStatus.unlocked));
  }

  // Check if app should be locked on resume
  void checkLockStatus() {
    if (state.isPinSet && _authService.isAppLocked()) {
      emit(state.copyWith(status: AuthStatus.locked));
    }
  }
}
