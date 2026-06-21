import 'package:flutter/material.dart';
import '../utility/color.dart';

class FicCounter extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;

  const FicCounter({super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final isDecrementDisabled = value <= 0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildStepButton(
          icon: Icons.remove,
          onTap: isDecrementDisabled ? null : () => onChanged(value - 1),
          isDisabled: isDecrementDisabled,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            value.toString().padLeft(2, '0'),
            style: const TextStyle(
              fontSize: 40,
              fontWeight: FontWeight.bold,
              color: AppColors.text,
            ),
          ),
        ),
        _buildStepButton(
          icon: Icons.add,
          onTap: () => onChanged(value + 1),
          isDisabled: false,
        ),
      ],
    );
  }

  Widget _buildStepButton({
    required IconData icon,
    required VoidCallback? onTap,
    required bool isDisabled,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDisabled ? AppColors.disabledButton : AppColors.button,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: isDisabled ? AppColors.disabledButtonText : AppColors.white,
          size: 30,
        ),
      ),
    );
  }
}
