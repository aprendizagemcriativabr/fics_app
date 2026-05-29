import 'package:flutter/material.dart';
import '../../../data/models/tutorial_flow_model.dart';
import '../fic_button.dart';
import 'fic_secondary_navbutton.dart';
import 'fic_step_indicator.dart';
import 'fic_stepcard.dart';

class FicTutorialDetail extends StatefulWidget {
  final TutorialFlow flow;
  final VoidCallback onComplete;

  const FicTutorialDetail({
    super.key,
    required this.flow,
    required this.onComplete,
  });

  @override
  State<FicTutorialDetail> createState() => _FicTutorialDetailState();
}

class _FicTutorialDetailState extends State<FicTutorialDetail> {
  int _currentStep = 0;

  bool get _isLast => _currentStep == widget.flow.steps.length - 1;
  bool get _isFirst => _currentStep == 0;

  @override
  Widget build(BuildContext context) {
    final step = widget.flow.steps[_currentStep];
    final total = widget.flow.steps.length;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: FicStepIndicator(
            totalSteps: total,
            currentStep: _currentStep,
          ),
        ),
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: FicStepcard(
              key: ValueKey(_currentStep),
              step: step,
              stepNumber: _currentStep + 1,
              total: total,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
          child: Row(
            children: [
              if (!_isFirst) ...[
                Expanded(
                  child: FicSecondaryNavbutton(
                    label: 'ANTERIOR',
                    onTap: () => setState(() => _currentStep--),
                  ),
                ),
                const SizedBox(width: 12),
              ],
              Expanded(
                flex: 2,
                child: FicButton(
                  label: _isLast ? 'CONCLUIR ✓' : 'PRÓXIMO',
                  isLoading: false,
                  onPressed: _isLast
                      ? widget.onComplete
                      : () => setState(() => _currentStep++),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
