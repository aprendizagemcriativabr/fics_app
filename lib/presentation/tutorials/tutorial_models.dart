import 'package:flutter/material.dart';

class TutorialStep {
  final IconData icon;
  final String title;
  final String description;

  const TutorialStep({
    required this.icon,
    required this.title,
    required this.description,
  });
}

class TutorialFlow {
  final String id;
  final String title;
  final String subtitle;
  final IconData icon;
  final List<TutorialStep> steps;
  final List<String> faqs;

  const TutorialFlow({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.steps,
    required this.faqs,
  });
}