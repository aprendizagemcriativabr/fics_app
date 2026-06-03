import 'package:flutter/material.dart';

class TutorialStep {
  final IconData icon;
  final String title;
  final String description;
  final String? image;

  TutorialStep({
    required this.icon,
    required this.title,
    required this.description,
    this.image,
  });

  factory TutorialStep.fromMap(Map<String, dynamic> map, IconData icon) {
    return TutorialStep(
      icon: icon,
      title: map['title'] ?? '',
      image: map['image'],
      description: map['description'] ?? '',
    );
  }
}
