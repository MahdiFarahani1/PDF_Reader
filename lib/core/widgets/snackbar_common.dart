import 'package:flutter/material.dart';
import 'package:flutter_application_1/core/utils/extension.dart';

class AppSnackBar {
  static void showSuccess(BuildContext context, String message) {
    _show(context, message, Colors.green, Icons.check_circle);
  }

  static void showError(BuildContext context, String message) {
    _show(context, message, Colors.redAccent, Icons.error);
  }

  static void showWarning(BuildContext context, String message) {
    _show(context, message, Colors.orange, Icons.warning_amber_rounded);
  }

  static void showInfo(BuildContext context, String message) {
    _show(context, message, Colors.blueAccent, Icons.info_outline);
  }

  static void _show(
    BuildContext context,
    String message,
    Color color,
    IconData icon,
  ) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(icon, color: context.theme.scaffoldBackgroundColor),
            const SizedBox(width: 12),
            Expanded(child: Text(message, style: TextStyle(fontSize: 15))),
          ],
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: Duration(seconds: 3),
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }
}
