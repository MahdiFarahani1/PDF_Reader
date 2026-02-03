import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/utils/app_localizations.dart';
import 'package:flutter_application_1/core/widgets/snackbar_common.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../logic/cubits/auth/auth_cubit.dart';

class PinSetupScreen extends StatefulWidget {
  const PinSetupScreen({super.key});

  @override
  State<PinSetupScreen> createState() => _PinSetupScreenState();
}

class _PinSetupScreenState extends State<PinSetupScreen> {
  final TextEditingController _pinController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  String? _errorMessage;

  @override
  void dispose() {
    _pinController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(title: Text(loc.setUpPin)),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_outline, size: 80, color: Colors.blue),
            const SizedBox(height: 32),
            Text(
              loc.createPin,
              style: Theme.of(context).textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _pinController,
              obscureText: true,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: InputDecoration(
                labelText: loc.enterPin,
                hintText: loc.digitPIN,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _confirmController,
              obscureText: true,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: InputDecoration(
                labelText: loc.confirm,
                hintText: loc.reenterPIN,
                border: OutlineInputBorder(),
              ),
            ),
            if (_errorMessage != null) ...[
              const SizedBox(height: 16),
              Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
            ],
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _setupPin,
                child: Text(loc.setPin),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _setupPin() async {
    final loc = AppLocalizations.of(context);

    final pin = _pinController.text;
    final confirm = _confirmController.text;

    if (pin.length < 4) {
      setState(() {
        _errorMessage = loc.pINmustbeatleastdigits;
      });
      return;
    }

    if (pin != confirm) {
      setState(() {
        _errorMessage = loc.pinsNotMatch;
      });
      return;
    }

    await context.read<AuthCubit>().setupPin(pin);

    if (mounted) {
      Navigator.pop(context);
      AppSnackBar.showSuccess(context, loc.pINsetsuccessfully);
    }
  }
}
