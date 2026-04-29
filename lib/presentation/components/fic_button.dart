import 'package:flutter/material.dart';
import '../utility/color.dart';

class FicButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed; // Permitir null para desabilitar
  final Color backgroundColor;
  final bool isLoading; // Nova propriedade

  const FicButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.backgroundColor = AppColors.button,
    this.isLoading = false, // Padrão é falso
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor:
              isLoading ? backgroundColor.withOpacity(0.7) : backgroundColor,
          foregroundColor: AppColors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 0,
        ),
        // Se estiver carregando, desabilitamos o clique
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
