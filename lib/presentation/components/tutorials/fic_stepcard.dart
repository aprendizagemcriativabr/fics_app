import 'package:flutter/material.dart';
import '../../../data/models/tutorial_step_model.dart';
import '../../utility/color.dart';

class FicStepcard extends StatelessWidget {
  final TutorialStep step;
  final int stepNumber;
  final int total;

  const FicStepcard({
    super.key,
    required this.step,
    required this.stepNumber,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    const kButton = AppColors.button;

    return Scrollbar(
      thumbVisibility: true,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 24),
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: kButton,
                borderRadius: BorderRadius.circular(32),
              ),
              child: Icon(
                step.icon,
                size: 60,
                color: AppColors.primaryYellow,
              ),
            ),
            const SizedBox(height: 28),
            Text(
              'PASSO $stepNumber DE $total',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 2,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              step.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: Colors.black,
                letterSpacing: -0.3,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                step.description,
                textAlign: TextAlign.left,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                  height: 1.6,
                ),
              ),
            ),
            if (step.image != null && step.image!.trim().isNotEmpty) ...[
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  step.image!,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.07),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Text(
                        'Imagem do tutorial não encontrada.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black54,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
