import 'package:flutter/material.dart';
import '../utility/color.dart';

class FicEmptyState extends StatelessWidget {
  final String text;
  final IconData icon;

  const FicEmptyState({
    super.key,
    this.text = "Nenhum participante encontrado",
    this.icon = Icons.search_off,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 60,
            color: AppColors.text.withValues(alpha: 0.7),
          ),
          const SizedBox(height: 10),
          Text(
            text,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.text,
            ),
          ),
        ],
      ),
    );
  }
}
