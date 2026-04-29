import 'package:flutter/material.dart';

enum FeedbackType { success, error, warning, info }

class FicFeedback {
  static void show(
    BuildContext context, {
    required String message,
    FeedbackType type = FeedbackType.info,
  }) {
    final colors = {
      FeedbackType.success: Colors.green.shade800,
      FeedbackType.error: Colors.red.shade800,
      FeedbackType.warning: Colors.orange.shade900,
      FeedbackType.info: Colors.blue.shade800,
    };

    final icons = {
      FeedbackType.success: Icons.check_circle_outline,
      FeedbackType.error: Icons.error_outline,
      FeedbackType.warning: Icons.warning_amber_rounded,
      FeedbackType.info: Icons.info_outline,
    };

    ScaffoldMessenger.of(context)
        .clearSnackBars(); // Remove o anterior antes de mostrar novo

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        backgroundColor: colors[type],
        margin: const EdgeInsets.all(20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        content: Row(
          children: [
            Icon(icons[type], color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
