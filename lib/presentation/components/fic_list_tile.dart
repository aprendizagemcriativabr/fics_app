import 'package:flutter/material.dart';
import '../../domain/entities/pessoa.dart';
import '../utility/color.dart';

class FicListTile extends StatelessWidget {
  final Pessoa pessoa;
  final VoidCallback? onTap; 
  final bool isCheckinFlow;  

  const FicListTile({
    super.key,
    required this.pessoa,
    this.onTap,
    this.isCheckinFlow = false, 
  });

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
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "${pessoa.acompanhantes} acompanhantes",
              style: TextStyle(
                color: pessoa.confirmado ? AppColors.disabledText : AppColors.text,
              ),
            ),
            if (pessoa.horaEntrada != null) ...[
              const SizedBox(height: 2),
              Text(
                "Entrada às ${pessoa.horaEntrada}",
                style: TextStyle(
                  color: pessoa.confirmado ? AppColors.disabledText : AppColors.text,
                ),
              ),
            ],
          ],
        ),
        
        /// NOVA REGRA DA DIREITA (TRAILING)
        trailing: pessoa.confirmado
            ? const Icon(Icons.check_circle, color: Colors.green, size: 24) // Check sempre aparece se confirmado
            : (isCheckinFlow 
                ? null // Se for fluxo de leitura de check-in e não estiver confirmado, não mostra nada
                : const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.button)), // Seta só no fluxo de validação
                
        onTap: pessoa.confirmado ? null : onTap,
      ),
    );
  }
}