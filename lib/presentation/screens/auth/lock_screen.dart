import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/utils/app_localizations.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../logic/cubits/auth/auth_cubit.dart';
import '../../../logic/cubits/auth/auth_state.dart';
import '../../../core/utils/app_icons.dart';

class LockScreen extends StatefulWidget {
  const LockScreen({super.key});

  @override
  State<LockScreen> createState() => _LockScreenState();
}

class _LockScreenState extends State<LockScreen>
    with SingleTickerProviderStateMixin {
  String _enteredPin = '';
  late AnimationController _shakeController;
  late Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _shakeAnimation =
        Tween<double>(begin: 0.0, end: 24.0).animate(
          CurvedAnimation(parent: _shakeController, curve: Curves.elasticIn),
        )..addStatusListener((status) {
          if (status == AnimationStatus.completed) {
            _shakeController.reset();
            setState(() {
              _enteredPin = '';
            });
          }
        });
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  void _onNumberPress(String number, int pinLength) {
    if (_enteredPin.length < pinLength) {
      setState(() {
        _enteredPin += number;
      });
      if (_enteredPin.length == pinLength) {
        _verifyPin();
      }
    }
  }

  void _onDeletePress() {
    if (_enteredPin.isNotEmpty) {
      setState(() {
        _enteredPin = _enteredPin.substring(0, _enteredPin.length - 1);
      });
    }
  }

  Future<void> _verifyPin() async {
    final success = await context.read<AuthCubit>().verifyPin(
      _enteredPin,
      context,
    );
    if (!success) {
      _shakeController.forward();
    } else {
      setState(() {
        _enteredPin = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          return SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),
                Image.asset(
                  AppIcons.lock,
                  width: 64,
                  height: 64,
                  color: Colors.blueAccent,
                ),
                const SizedBox(height: 32),
                Text(
                  loc.enterPin,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 48),
                AnimatedBuilder(
                  animation: _shakeAnimation,
                  builder: (context, child) {
                    return Transform.translate(
                      offset: Offset(
                        _shakeAnimation.value *
                            (1 - (_shakeController.value * 2).floor() % 2 * 2),
                        0,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          state.pinLength,
                          (index) => Container(
                            margin: const EdgeInsets.symmetric(horizontal: 12),
                            width: 16,
                            height: 16,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: index < _enteredPin.length
                                  ? Colors.blueAccent
                                  : Theme.of(
                                      context,
                                    ).dividerColor.withValues(alpha: 0.3),
                              boxShadow: index < _enteredPin.length
                                  ? [
                                      BoxShadow(
                                        color: Colors.blueAccent.withValues(
                                          alpha: 0.4,
                                        ),
                                        blurRadius: 12,
                                        spreadRadius: 2,
                                      ),
                                    ]
                                  : null,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                if (state.errorMessage != null &&
                    state.status == AuthStatus.locked)
                  Padding(
                    padding: const EdgeInsets.only(top: 24.0),
                    child: Text(
                      state.errorMessage!,
                      style: const TextStyle(color: Colors.redAccent),
                    ),
                  ),
                const Spacer(),
                _buildNumberPad(context, state),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildNumberPad(BuildContext context, AuthState state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 48),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildNumberButton('1', state.pinLength),
              _buildNumberButton('2', state.pinLength),
              _buildNumberButton('3', state.pinLength),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildNumberButton('4', state.pinLength),
              _buildNumberButton('5', state.pinLength),
              _buildNumberButton('6', state.pinLength),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildNumberButton('7', state.pinLength),
              _buildNumberButton('8', state.pinLength),
              _buildNumberButton('9', state.pinLength),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              state.isBiometricEnabled && state.isBiometricAvailable
                  ? IconButton(
                      onPressed: () => context
                          .read<AuthCubit>()
                          .authenticateWithBiometrics(context),
                      icon: Image.asset(
                        AppIcons.priorityArrows,
                        width: 32,
                        height: 32,
                      ), // Using priorityArrows for biometric
                      style: IconButton.styleFrom(
                        padding: const EdgeInsets.all(24),
                      ),
                    )
                  : const SizedBox(width: 80),
              _buildNumberButton('0', state.pinLength),
              IconButton(
                onPressed: _onDeletePress,
                icon: Image.asset(
                  AppIcons.angleDoubleSmallLeft,
                  width: 28,
                  height: 28,
                ), // Using angle-double-left for delete/backspace
                style: IconButton.styleFrom(padding: const EdgeInsets.all(24)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNumberButton(String number, int pinLength) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () => _onNumberPress(number, pinLength),
          child: Center(
            child: Text(
              number,
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w500),
            ),
          ),
        ),
      ),
    );
  }
}
