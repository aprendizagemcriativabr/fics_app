import 'package:flutter/material.dart';
import '../utility/color.dart';

class FicDialog {
  static Future<bool?> show({
    required BuildContext context,
    required String title,
    required String message,
    String confirmText = "CONFIRMAR",
    String cancelText = "CANCELAR",
    bool showCancel = true,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (_) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(message),
          actions: [
            if (showCancel)
              TextButton(
                onPressed: () {
                  Navigator.pop(context, false);
                },
                child: Text(
                  cancelText,
                  style: const TextStyle(
                    color: Colors.black54,
                  ),
                ),
              ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryYellow,
                foregroundColor: Colors.black,
                elevation: 0,
              ),
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: Text(confirmText),
            ),
          ],
        );
      },
    );
  }
}
