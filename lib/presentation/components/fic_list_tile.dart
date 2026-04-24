import 'package:flutter/material.dart';
import '../../domain/entities/pessoa.dart';
import '../utility/color.dart';

class FicListTile extends StatelessWidget {
  final Pessoa pessoa;
  final VoidCallback onTap;

  const FicListTile({super.key, required this.pessoa, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.text)),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(
          pessoa.nome.toUpperCase(),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: pessoa.confirmado ? AppColors.disabledText : AppColors.text,
          ),
        ),
        subtitle: Text(
          "${pessoa.acompanhantes} acompanhantes",
          style: TextStyle(color: pessoa.confirmado ? AppColors.disabledText : AppColors.text),
        ),
        trailing: pessoa.confirmado
            ? const Icon(Icons.check_circle, color: Colors.green, size: 24)
            : const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.button),
        onTap: pessoa.confirmado ? null : onTap,
      ),
    );
  }
}