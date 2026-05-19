import 'package:flutter/material.dart';

class TutorialStep {
  final IconData icon;
  final String title;
  final String description;

  TutorialStep({
    required this.icon,
    required this.title,
    required this.description,
  });

  factory TutorialStep.fromMap(Map<String, dynamic> map, IconData icon) {
    return TutorialStep(
      icon: icon,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
    );
  }
}