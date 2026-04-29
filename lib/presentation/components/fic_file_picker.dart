import 'package:flutter/material.dart';
import '../utility/color.dart';

class FicFilePicker extends StatelessWidget {
  final VoidCallback onTap;
  final String? fileName;

  const FicFilePicker({super.key, required this.onTap, this.fileName});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
        decoration: BoxDecoration(
          color: AppColors.secondaryYellow, 
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          children: [
            const Icon(Icons.upload_outlined, size: 60, color: AppColors.text),
            const SizedBox(height: 16),
            Text(
              fileName ?? "Formatos suportados: .xlsx\nAté 1 arquivo",
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.text,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}