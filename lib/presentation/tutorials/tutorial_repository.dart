import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'tutorial_models.dart';

class TutorialRepository {
  static Future<List<TutorialFlow>> loadTutorials() async {
    final jsonString = await rootBundle.loadString(
      'assets/tutorials.json',
    );

    final List<dynamic> data = json.decode(jsonString);

    return data
        .map((e) => _fromMap(e as Map<String, dynamic>))
        .toList();
  }

  static TutorialFlow _fromMap(Map<String, dynamic> map) {
    return TutorialFlow(
      id: map['id'],
      title: map['title'],
      subtitle: map['subtitle'],
      icon: _iconFromString(map['icon']),
      faqs: List<String>.from(map['faqs']),
      steps: (map['steps'] as List)
          .map(
            (s) => TutorialStep(
              icon: _iconFromString(s['icon']),
              title: s['title'],
              description: s['description'],
            ),
          )
          .toList(),
    );
  }

  static IconData _iconFromString(String name) {
    switch (name) {
      case 'how_to_reg_rounded':
        return Icons.how_to_reg_rounded;
      case 'touch_app_rounded':
        return Icons.touch_app_rounded;
      case 'search_rounded':
        return Icons.search_rounded;
      case 'filter_alt_rounded':
        return Icons.filter_alt_rounded;
      case 'check_circle_rounded':
        return Icons.check_circle_rounded;
      case 'person_add_rounded':
        return Icons.person_add_rounded;
      case 'person_rounded':
        return Icons.person_rounded;
      case 'group_rounded':
        return Icons.group_rounded;
      case 'save_rounded':
        return Icons.save_rounded;
      case 'upload_file_rounded':
        return Icons.upload_file_rounded;
      case 'table_chart_rounded':
        return Icons.table_chart_rounded;
      case 'upload_rounded':
        return Icons.upload_rounded;
      case 'download_done_rounded':
        return Icons.download_done_rounded;
      case 'lock_rounded':
        return Icons.lock_rounded;
      case 'checklist_rounded':
        return Icons.checklist_rounded;
      case 'check_circle_outline_rounded':
        return Icons.check_circle_outline_rounded;
      default:
        return Icons.help_outline_rounded;
    }
  }
}