import 'package:flutter/material.dart';

import '../components/fic_appbar.dart';
import '../components/fic_search_bar.dart';
import '../components/fic_empty_state.dart';
import '../components/tutorials/fic_expandable_faq.dart';
import '../components/tutorials/fic_flow_card.dart';
import '../components/tutorials/fic_section_label.dart';
import '../components/tutorials/fic_tutorial_detail.dart';
import '../../data/models/tutorial_flow_model.dart';
import '../../data/repositories/tutorial_repository.dart';
import '../utility/color.dart';

List<TutorialFlow> kTutorials = [];

class TutorialPage extends StatefulWidget {
  final String? initialFlowId;

  const TutorialPage({
    super.key,
    this.initialFlowId,
  });

  @override
  State<TutorialPage> createState() => _TutorialPageState();
}

class _TutorialPageState extends State<TutorialPage> {
  TutorialFlow? _selectedFlow;
  String filterText = '';
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _homeScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadTutorials();
  }

  Future<void> _loadTutorials() async {
    final tutorials = await TutorialRepository.loadTutorials();

    setState(() {
      kTutorials = tutorials;

      if (widget.initialFlowId != null && kTutorials.isNotEmpty) {
        _selectedFlow = kTutorials.firstWhere(
          (t) => t.id == widget.initialFlowId,
          orElse: () => kTutorials.first,
        );
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _homeScrollController.dispose();
    super.dispose();
  }

  void _handleBack() {
    if (_selectedFlow != null) {
      setState(() {
        _selectedFlow = null;
      });
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (kTutorials.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.primaryYellow,
        appBar: FicAppBar(
          title: 'TUTORIAL',
          onBack: () => Navigator.pop(context),
        ),
        body: const FicEmptyState(
          text: 'Nenhum tutorial encontrado.',
        ),
      );
    }

    return PopScope(
      canPop: _selectedFlow == null,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        setState(() {
          _selectedFlow = null;
        });
      },
      child: Scaffold(
        backgroundColor: AppColors.primaryYellow,
        appBar: FicAppBar(
          title: _selectedFlow == null ? 'TUTORIAL' : _selectedFlow!.title,
          onBack: _handleBack,
        ),
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 280),
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.04, 0),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          ),
          child: _selectedFlow == null
              ? _buildHome()
              : FicTutorialDetail(
                  key: ValueKey(_selectedFlow!.id),
                  flow: _selectedFlow!,
                  onComplete: () => setState(() => _selectedFlow = null),
                ),
        ),
      ),
    );
  }

  Widget _buildHome() {
    final todasFaqs = kTutorials
        .expand((flow) => flow.faqs.map((faq) => MapEntry(faq, flow)))
        .toList();

    final listaFiltradaFaqs = todasFaqs.where((entry) {
      return entry.key.question
          .toLowerCase()
          .contains(filterText.toLowerCase());
    }).toList();

    return Scrollbar(
      controller: _homeScrollController,
      thumbVisibility: true,
      child: ListView(
        controller: _homeScrollController,
        key: const ValueKey('home'),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        children: [
          FicSearchBar(
            hintText: 'O que você precisa saber?',
            controller: _searchController,
            onChanged: (value) => setState(() => filterText = value),
          ),
          const SizedBox(height: 12),
          if (filterText.isNotEmpty) ...[
            const FicSectionLabel('RESULTADOS'),
            const SizedBox(height: 12),
            if (listaFiltradaFaqs.isEmpty)
              const FicEmptyState(text: 'Nenhuma dúvida encontrada')
            else
              ...listaFiltradaFaqs.map(
                (e) => FicExpandableFaq(
                  faq: e.key,
                  parentFlow: e.value,
                  onSelectFlow: (flow) => setState(() => _selectedFlow = flow),
                ),
              ),
          ] else ...[
            const FicSectionLabel('TUTORIAIS POR FLUXO'),
            const SizedBox(height: 12),
            ...kTutorials.map(
              (flow) => FicFlowCard(
                flow: flow,
                onTap: () => setState(() => _selectedFlow = flow),
              ),
            ),
            const SizedBox(height: 28),
            const FicSectionLabel('DÚVIDAS COMUNS'),
            const SizedBox(height: 12),
            ...listaFiltradaFaqs.map(
              (e) => FicExpandableFaq(
                faq: e.key,
                parentFlow: e.value,
                onSelectFlow: (flow) => setState(() => _selectedFlow = flow),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
