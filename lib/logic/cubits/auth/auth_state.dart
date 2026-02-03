import 'package:equatable/equatable.dart';

enum AuthStatus { initial, locked, unlocked, authenticating }

class AuthState extends Equatable {
  final AuthStatus status;
  final bool isPinSet;
  final bool isBiometricEnabled;
  final bool isBiometricAvailable;
  final int pinLength;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.initial,
    this.isPinSet = false,
    this.isBiometricEnabled = false,
    this.isBiometricAvailable = false,
    this.pinLength = 4,
    this.errorMessage,
  });

  AuthState copyWith({
    AuthStatus? status,
    bool? isPinSet,
    bool? isBiometricEnabled,
    bool? isBiometricAvailable,
    int? pinLength,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      isPinSet: isPinSet ?? this.isPinSet,
      isBiometricEnabled: isBiometricEnabled ?? this.isBiometricEnabled,
      isBiometricAvailable: isBiometricAvailable ?? this.isBiometricAvailable,
      pinLength: pinLength ?? this.pinLength,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    isPinSet,
    isBiometricEnabled,
    isBiometricAvailable,
    pinLength,
    errorMessage,
  ];
}
