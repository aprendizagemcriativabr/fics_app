import 'package:flutter/material.dart';
import '../../data/models/tutorial_faq_model.dart';
import '../../data/models/tutorial_flow_model.dart';
import '../../data/repositories/tutorial_repository.dart';

class TutorialViewModel extends ChangeNotifier {
  final String? initialFlowId;

  List<TutorialFlow> tutorials = [];
  TutorialFlow? selectedFlow;
  String filterText = '';

  final TextEditingController searchController = TextEditingController();
  final ScrollController homeScrollController = ScrollController();

  TutorialViewModel({this.initialFlowId});

  Future<void> loadTutorials() async {
    tutorials = await TutorialRepository.loadTutorials();
    if (initialFlowId != null && tutorials.isNotEmpty) {
      selectedFlow = tutorials.firstWhere(
        (t) => t.id == initialFlowId,
        orElse: () => tutorials.first,
      );
    }
    notifyListeners();
  }

  void updateFilter(String value) {
    filterText = value;
    notifyListeners();
  }

  void selectFlow(TutorialFlow? flow) {
    selectedFlow = flow;
    notifyListeners();
  }

  void handleBack(NavigatorState navigator) {
    if (selectedFlow != null) {
      selectedFlow = null;
      notifyListeners();
    } else {
      navigator.pop();
    }
  }

  List<MapEntry<TutorialFaq, TutorialFlow>> getFilteredFaqs() {
    final todasFaqs = tutorials
        .expand((flow) => flow.faqs.map((faq) => MapEntry(faq, flow)))
        .toList();

    return todasFaqs.where((entry) {
      return entry.key.question
          .toLowerCase()
          .contains(filterText.toLowerCase());
    }).toList();
  }

  @override
  void dispose() {
    searchController.dispose();
    homeScrollController.dispose();
    super.dispose();
  }
}
