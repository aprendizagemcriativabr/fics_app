import 'package:flutter/material.dart';
import 'tutorial_faq_model.dart';
import 'tutorial_step_model.dart';

class TutorialFlow {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final List<TutorialFaq> faqs;
  final List<TutorialStep> steps;

  TutorialFlow({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.faqs,
    required this.steps,
  });

  factory TutorialFlow.fromMap(
    Map<String, dynamic> map,
    IconData flowIcon,
    List<TutorialStep> steps,
  ) {
    return TutorialFlow(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      subtitle: map['subtitle'] ?? '',
      icon: flowIcon,
      faqs: (map['faqs'] as List? ?? [])
          .map((f) => TutorialFaq.fromMap(f as Map<String, dynamic>))
          .toList(),
      steps: steps,
    );
  }
}