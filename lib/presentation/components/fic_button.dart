import 'package:flutter/material.dart';
import '../utility/color.dart';

class FicButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed; 
  final Color backgroundColor;
  final bool isLoading; 

  const FicButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.backgroundColor = AppColors.button,
    this.isLoading = false, 
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: isLoading
              ? backgroundColor.withValues(alpha: 0.7)
              : backgroundColor,
          foregroundColor: AppColors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 3,
                ),
              )
            : Text(
                label.toUpperCase(),
                style: const TextStyle(
                    fontWeight: FontWeight.bold, letterSpacing: 1.1),
              ),
      ),
    );
  }
}
