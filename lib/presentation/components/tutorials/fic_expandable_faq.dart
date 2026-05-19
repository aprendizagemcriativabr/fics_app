import 'package:flutter/material.dart';
import '../../../data/models/tutorial_faq_model.dart';
import '../../../data/models/tutorial_flow_model.dart';
import '../../utility/color.dart';

class FicExpandableFaq extends StatelessWidget {
  final TutorialFaq faq;
  final TutorialFlow parentFlow;
  final ValueChanged<TutorialFlow> onSelectFlow;

  const FicExpandableFaq({
    super.key,
    required this.faq,
    required this.parentFlow,
    required this.onSelectFlow,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.button,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          key: PageStorageKey(faq.question),
          title: Text(
            faq.question,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: AppColors.white,
            ),
          ),
          iconColor: AppColors.primaryYellow,
          collapsedIconColor: AppColors.primaryYellow,
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              faq.answer,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.white,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => onSelectFlow(parentFlow),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Ver passo a passo em: ${parentFlow.title}',
                      style: const TextStyle(
                        color: AppColors.primaryYellow,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.arrow_forward_rounded, 
                      size: 14, 
                      color: AppColors.primaryYellow,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}