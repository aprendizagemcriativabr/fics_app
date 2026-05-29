import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/tutorial_step_model.dart';
import '../models/tutorial_flow_model.dart';

class TutorialRepository {
  static const Map<String, IconData> _iconsMap = {
    'how_to_reg_rounded': Icons.how_to_reg_rounded,
    'touch_app_rounded': Icons.touch_app_rounded,
    'search_rounded': Icons.search_rounded,
    'filter_alt_rounded': Icons.filter_alt_rounded,
    'check_circle_rounded': Icons.check_circle_rounded,
    'person_add_rounded': Icons.person_add_rounded,
    'person_rounded': Icons.person_rounded,
    'group_rounded': Icons.group_rounded,
    'save_rounded': Icons.save_rounded,
    'upload_file_rounded': Icons.upload_file_rounded,
    'table_chart_rounded': Icons.table_chart_rounded,
    'upload_rounded': Icons.upload_rounded,
    'download_done_rounded': Icons.download_done_rounded,
    'lock_rounded': Icons.lock_rounded,
    'checklist_rounded': Icons.checklist_rounded,
    'check_circle_outline_rounded': Icons.check_circle_outline_rounded,
  };

  static IconData _getIcon(String? name) {
    return _iconsMap[name] ?? Icons.help_outline_rounded;
  }

  static Future<List<TutorialFlow>> loadTutorials() async {
    try {
      final jsonString =
          await rootBundle.loadString('lib/data/datasources/tutorials.json');
      final List<dynamic> decodedData = json.decode(jsonString);

      return decodedData.map((flowMap) {
        final map = flowMap as Map<String, dynamic>;

        final stepsList = (map['steps'] as List? ?? []).map((stepMap) {
          final s = stepMap as Map<String, dynamic>;
          return TutorialStep.fromMap(s, _getIcon(s['icon']));
        }).toList();

        return TutorialFlow.fromMap(map, _getIcon(map['icon']), stepsList);
      }).toList();
    } catch (e) {
      debugPrint('Erro ao carregar ficheiro de tutoriais: $e');
      return [];
    }
  }
}
