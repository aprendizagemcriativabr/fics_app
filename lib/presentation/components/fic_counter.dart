import 'package:flutter/material.dart';
import '../utility/color.dart';

class FicCounter extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;

  const FicCounter({super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildStepButton(Icons.remove, () => onChanged(value - 1)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            value.toString().padLeft(2, '0'), 
            style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
          ),
        ),
        _buildStepButton(Icons.add, () => onChanged(value + 1)),
      ],
    );
  }

  Widget _buildStepButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: const BoxDecoration(
          color: AppColors.button,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 30),
      ),
    );
  }
}