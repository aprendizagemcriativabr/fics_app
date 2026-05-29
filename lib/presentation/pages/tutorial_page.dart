import 'package:flutter/material.dart';

import '../components/fic_appbar.dart';
import '../components/fic_button.dart';
import '../components/tutorials/fic_expandable_faq.dart'; // Novo componente importado aqui
import '../components/tutorials/fic_flow_card.dart';
import '../components/fic_search_bar.dart';
import '../components/tutorials/fic_step_indicator.dart';
import '../../data/models/tutorial_faq_model.dart';
import '../../data/models/tutorial_step_model.dart';
import '../../data/models/tutorial_flow_model.dart';
import '../../data/repositories/tutorial_repository.dart';
import '../utility/color.dart';

const _kYellow = AppColors.primaryYellow;

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
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _homeScrollController = ScrollController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadTutorials();
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _normalize(_searchController.text);
      });
    });
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

  String _normalize(String text) {
    return text
        .toLowerCase()
        .trim()
        .replaceAll('-', ' ')
        .replaceAll('_', ' ')
        .replaceAll(RegExp(r'[^\w\s]'), '')
        .replaceAll(RegExp(r'\s+'), ' ');
  }

  bool _matchesSearch(String source, String query) {
    final normalizedSource = _normalize(source);
    final normalizedQuery = _normalize(query);

    if (normalizedSource.contains(normalizedQuery)) return true;

    final queryWords = normalizedQuery.split(' ');
    for (final word in queryWords) {
      if (word.isEmpty) continue;
      if (normalizedSource.contains(word)) return true;
    }
    return false;
  }

  List<MapEntry<TutorialFaq, TutorialFlow>> get _filteredFaqs {
    final all = <MapEntry<TutorialFaq, TutorialFlow>>[];

    for (final flow in kTutorials) {
      for (final faq in flow.faqs) {
        all.add(MapEntry(faq, flow));
      }
    }

    if (_searchQuery.isEmpty) return all;

    return all
        .where((e) => _matchesSearch(e.key.question, _searchQuery))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    if (kTutorials.isEmpty) {
      return Scaffold(
        backgroundColor: _kYellow,
        appBar: FicAppBar(
          title: 'TUTORIAL',
          onBack: () => Navigator.pop(context),
        ),
        body: const Center(
          child: Text(
            'Nenhum tutorial encontrado.',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ),
      );
    }

    return WillPopScope(
      onWillPop: () async {
        if (_selectedFlow != null) {
          setState(() {
            _selectedFlow = null;
          });
          return false;
        }
        return true;
      },
      child: Scaffold(
        backgroundColor: _kYellow,
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
              : _TutorialDetail(
                  key: ValueKey(_selectedFlow!.id),
                  flow: _selectedFlow!,
                  onComplete: () {
                    setState(() {
                      _selectedFlow = null;
                    });
                  },
                ),
        ),
      ),
    );
  }

  Widget _buildHome() {
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
            onChanged: (value) {},
          ),
          const SizedBox(height: 24),
          if (_searchQuery.isNotEmpty) ...[
            const _SectionLabel('RESULTADOS'),
            const SizedBox(height: 12),
            if (_filteredFaqs.isEmpty)
              _EmptySearch(query: _searchQuery)
            else
              ..._filteredFaqs.map(
                (e) => FicExpandableFaq(
                  faq: e.key,
                  parentFlow: e.value,
                  onSelectFlow: (flow) {
                    setState(() => _selectedFlow = flow);
                  },
                ),
              ),
          ] else ...[
            const _SectionLabel('TUTORIAIS POR FLUXO'),
            const SizedBox(height: 12),
            ...kTutorials.map(
              (flow) => FicFlowCard(
                flow: flow,
                onTap: () => setState(() => _selectedFlow = flow),
              ),
            ),
            const SizedBox(height: 28),
            const _SectionLabel('DÚVIDAS COMUNS'),
            const SizedBox(height: 12),
            ..._filteredFaqs.map(
              (e) => FicExpandableFaq(
                faq: e.key,
                parentFlow: e.value,
                onSelectFlow: (flow) {
                  setState(() => _selectedFlow = flow);
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        letterSpacing: 2,
        color: Colors.black54,
      ),
    );
  }
}

class _EmptySearch extends StatelessWidget {
  final String query;
  const _EmptySearch({required this.query});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Icon(Icons.search_off_rounded, size: 40, color: Colors.black45),
          const SizedBox(height: 8),
          Text(
            'Nenhum resultado para "$query"',
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontWeight: FontWeight.w600, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}

class _TutorialDetail extends StatefulWidget {
  final TutorialFlow flow;
  final VoidCallback onComplete;

  const _TutorialDetail({
    super.key,
    required this.flow,
    required this.onComplete,
  });

  @override
  State<_TutorialDetail> createState() => _TutorialDetailState();
}

class _TutorialDetailState extends State<_TutorialDetail> {
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
            child: _StepCard(
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
                  child: _SecondaryNavButton(
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

class _StepCard extends StatelessWidget {
  final TutorialStep step;
  final int stepNumber;
  final int total;

  const _StepCard({
    super.key,
    required this.step,
    required this.stepNumber,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    const kButton = AppColors.button;

    return Scrollbar(
      thumbVisibility: true,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 24),
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: kButton,
                borderRadius: BorderRadius.circular(32),
              ),
              child: Icon(
                step.icon,
                size: 60,
                color: _kYellow,
              ),
            ),
            const SizedBox(height: 28),
            Text(
              'PASSO $stepNumber DE $total',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 2,
                color: Colors.black54,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              step.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: Colors.black,
                letterSpacing: -0.3,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.07),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                step.description,
                textAlign: TextAlign.left,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                  height: 1.6,
                ),
              ),
            ),
            if (step.image != null && step.image!.trim().isNotEmpty) ...[
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  step.image!,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.07),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Text(
                        'Imagem do tutorial não encontrada.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black54,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

class _SecondaryNavButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _SecondaryNavButton({
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const kButton = AppColors.button;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color: kButton.withOpacity(0.12),
          borderRadius: BorderRadius.circular(14),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: const TextStyle(
            color: AppColors.text,
            fontWeight: FontWeight.w800,
            fontSize: 14,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }
}
