import 'package:flutter/material.dart';

import '../components/fic_appbar.dart';
import '../tutorials/tutorial_models.dart';
import '../tutorials/tutorial_repository.dart';
import '../utility/color.dart';

// Atalhos locais para os tokens do projeto
const _kYellow = AppColors.primaryYellow;
const _kYellowLight = AppColors.secondaryYellow;
const _kButton = AppColors.button;

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

  final TextEditingController _searchController =
      TextEditingController();

  final ScrollController _homeScrollController =
      ScrollController();

  String _searchQuery = '';

  @override
  void initState() {
    super.initState();

    _loadTutorials();

    _searchController.addListener(() {
      setState(() {
        _searchQuery =
            _normalize(
              _searchController.text,
            );
      });
    });
  }

  Future<void> _loadTutorials() async {
    final tutorials =
        await TutorialRepository.loadTutorials();

    setState(() {
      kTutorials = tutorials;

      if (widget.initialFlowId != null &&
          kTutorials.isNotEmpty) {
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

  // =========================================================
  // NORMALIZAÇÃO PARA BUSCA FLEXÍVEL
  // =========================================================

  String _normalize(String text) {
    return text
        .toLowerCase()
        .trim()
        .replaceAll('-', ' ')
        .replaceAll('_', ' ')
        .replaceAll(RegExp(r'[^\w\s]'), '')
        .replaceAll(RegExp(r'\s+'), ' ');
  }

  bool _matchesSearch(
    String source,
    String query,
  ) {
    final normalizedSource =
        _normalize(source);

    final normalizedQuery =
        _normalize(query);

    // Busca direta
    if (normalizedSource.contains(
      normalizedQuery,
    )) {
      return true;
    }

    // Busca por palavras individuais
    final queryWords =
        normalizedQuery.split(' ');

    for (final word in queryWords) {
      if (word.isEmpty) continue;

      if (normalizedSource.contains(word)) {
        return true;
      }
    }

    return false;
  }

  List<MapEntry<String, TutorialFlow>>
      get _filteredFaqs {
    final all =
        <MapEntry<String, TutorialFlow>>[];

    for (final flow in kTutorials) {
      for (final faq in flow.faqs) {
        all.add(MapEntry(faq, flow));
      }
    }

    if (_searchQuery.isEmpty) {
      return all;
    }

    return all.where((e) {
      return _matchesSearch(
        e.key,
        _searchQuery,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    if (kTutorials.isEmpty) {
      return Scaffold(
        backgroundColor: _kYellow,
        appBar: FicAppBar(
          title: 'TUTORIAL',
          onBack: () =>
              Navigator.pop(context),
        ),
        body: const Center(
          child: Text(
            'Nenhum tutorial encontrado.',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
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
          title:
              _selectedFlow == null
                  ? 'TUTORIAL'
                  : _selectedFlow!.title,
          onBack: _handleBack,
        ),
        body: AnimatedSwitcher(
          duration: const Duration(
            milliseconds: 280,
          ),
          transitionBuilder:
              (child, animation) =>
                  FadeTransition(
                    opacity: animation,
                    child: SlideTransition(
                      position:
                          Tween<Offset>(
                            begin:
                                const Offset(
                                  0.04,
                                  0,
                                ),
                            end:
                                Offset.zero,
                          ).animate(
                            animation,
                          ),
                      child: child,
                    ),
                  ),
          child:
              _selectedFlow == null
                  ? _buildHome()
                  : _TutorialDetail(
                    key: ValueKey(
                      _selectedFlow!.id,
                    ),
                    flow: _selectedFlow!,
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
        controller:
            _homeScrollController,
        key: const ValueKey('home'),
        padding:
            const EdgeInsets.fromLTRB(
              20,
              16,
              20,
              32,
            ),
        children: [
          _SearchBar(
            controller:
                _searchController,
          ),

          const SizedBox(height: 24),

          if (_searchQuery.isNotEmpty) ...[
            _SectionLabel('RESULTADOS'),

            const SizedBox(height: 12),

            if (_filteredFaqs.isEmpty)
              _EmptySearch(
                query: _searchQuery,
              )
            else
              ..._filteredFaqs.map(
                (e) => _FaqChip(
                  question: e.key,
                  onTap: () {
                    setState(() {
                      _selectedFlow =
                          e.value;
                    });
                  },
                ),
              ),
          ] else ...[
            _SectionLabel(
              'TUTORIAIS POR FLUXO',
            ),

            const SizedBox(height: 12),

            ...kTutorials.map(
              (flow) => _FlowCard(
                flow: flow,
                onTap: () {
                  setState(() {
                    _selectedFlow =
                        flow;
                  });
                },
              ),
            ),

            const SizedBox(height: 28),

            _SectionLabel(
              'DÚVIDAS COMUNS',
            ),

            const SizedBox(height: 12),

            ..._filteredFaqs.map(
              (e) => _FaqChip(
                question: e.key,
                onTap: () {
                  setState(() {
                    _selectedFlow =
                        e.value;
                  });
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

class _SearchBar extends StatelessWidget {
  final TextEditingController controller;

  const _SearchBar({
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _kYellowLight,
        borderRadius:
            BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(
              0.08,
            ),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 15,
          color: Colors.black,
        ),
        decoration: const InputDecoration(
          hintText:
              'O que você precisa saber?',
          hintStyle: TextStyle(
            color: Colors.black45,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: Icon(
            Icons.search_rounded,
            color: Colors.black54,
          ),
          border: InputBorder.none,
          contentPadding:
              EdgeInsets.symmetric(
                vertical: 16,
              ),
        ),
      ),
    );
  }
}

class _FaqChip extends StatelessWidget {
  final String question;
  final VoidCallback onTap;

  const _FaqChip({
    required this.question,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin:
            const EdgeInsets.only(
              bottom: 8,
            ),
        padding:
            const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 13,
            ),
        decoration: BoxDecoration(
          color: _kButton,
          borderRadius:
              BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              Icons.help_outline_rounded,
              color: _kYellow,
              size: 18,
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Text(
                question,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight:
                      FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),

            const Icon(
              Icons
                  .arrow_forward_ios_rounded,
              color: Colors.white54,
              size: 14,
            ),
          ],
        ),
      ),
    );
  }
}

class _FlowCard extends StatelessWidget {
  final TutorialFlow flow;
  final VoidCallback onTap;

  const _FlowCard({
    required this.flow,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin:
            const EdgeInsets.only(
              bottom: 8,
            ),
        padding:
            const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
        decoration: BoxDecoration(
          color: _kButton,
          borderRadius:
              BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: _kYellow,
                borderRadius:
                    BorderRadius.circular(
                      10,
                    ),
              ),
              child: Icon(
                flow.icon,
                color: _kButton,
                size: 20,
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                children: [
                  Text(
                    flow.title,
                    maxLines: 1,
                    overflow:
                        TextOverflow
                            .ellipsis,
                    style:
                        const TextStyle(
                          color:
                              Colors.white,
                          fontWeight:
                              FontWeight
                                  .w800,
                          fontSize: 13,
                          letterSpacing:
                              0.5,
                        ),
                  ),

                  const SizedBox(height: 2),

                  Text(
                    flow.subtitle,
                    style:
                        const TextStyle(
                          color:
                              Colors
                                  .white54,
                          fontSize: 11,
                          fontWeight:
                              FontWeight
                                  .w500,
                        ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            Text(
              '${flow.steps.length} passos',
              style: const TextStyle(
                color: _kYellow,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptySearch extends StatelessWidget {
  final String query;

  const _EmptySearch({
    required this.query,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(
          0.08,
        ),
        borderRadius:
            BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.search_off_rounded,
            size: 40,
            color: Colors.black45,
          ),

          const SizedBox(height: 8),

          Text(
            'Nenhum resultado para "$query"',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}

class _TutorialDetail extends StatefulWidget {
  final TutorialFlow flow;

  const _TutorialDetail({
    super.key,
    required this.flow,
  });

  @override
  State<_TutorialDetail>
  createState() =>
      _TutorialDetailState();
}

class _TutorialDetailState
    extends State<_TutorialDetail> {
  int _currentStep = 0;

  bool get _isLast =>
      _currentStep ==
      widget.flow.steps.length - 1;

  bool get _isFirst =>
      _currentStep == 0;

  @override
  Widget build(BuildContext context) {
    final step =
        widget.flow.steps[_currentStep];

    final total =
        widget.flow.steps.length;

    return Column(
      children: [
        Padding(
          padding:
              const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 12,
              ),
          child: Row(
            children: List.generate(
              total,
              (i) {
                return Expanded(
                  child:
                      AnimatedContainer(
                        duration:
                            const Duration(
                              milliseconds:
                                  300,
                            ),
                        height: 4,
                        margin:
                            const EdgeInsets.symmetric(
                              horizontal:
                                  3,
                            ),
                        decoration:
                            BoxDecoration(
                              color:
                                  i <=
                                          _currentStep
                                      ? Colors
                                          .black
                                      : Colors
                                          .black26,
                              borderRadius:
                                  BorderRadius.circular(
                                    2,
                                  ),
                            ),
                      ),
                );
              },
            ),
          ),
        ),

        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(
              milliseconds: 250,
            ),
            child: _StepCard(
              key: ValueKey(
                _currentStep,
              ),
              step: step,
              stepNumber:
                  _currentStep + 1,
              total: total,
            ),
          ),
        ),

        Padding(
          padding:
              const EdgeInsets.fromLTRB(
                20,
                0,
                20,
                32,
              ),
          child: Row(
            children: [
              if (!_isFirst)
                Expanded(
                  child: _NavButton(
                    label: 'ANTERIOR',
                    primary: false,
                    onTap: () {
                      setState(() {
                        _currentStep--;
                      });
                    },
                  ),
                ),

              if (!_isFirst)
                const SizedBox(width: 12),

              Expanded(
                flex: 2,
                child: _NavButton(
                  label:
                      _isLast
                          ? 'CONCLUIR ✓'
                          : 'PRÓXIMO',
                  primary: true,
                  onTap:
                      _isLast
                          ? () {
                            Navigator.pop(
                              context,
                            );
                          }
                          : () {
                            setState(() {
                              _currentStep++;
                            });
                          },
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
    return Scrollbar(
      thumbVisibility: true,
      child: SingleChildScrollView(
        padding:
            const EdgeInsets.fromLTRB(
              20,
              8,
              20,
              16,
            ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 24),

            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: _kButton,
                borderRadius:
                    BorderRadius.circular(
                      32,
                    ),
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
                fontWeight:
                    FontWeight.w900,
                color: Colors.black,
                letterSpacing: -0.3,
                height: 1.2,
              ),
            ),

            const SizedBox(height: 16),

            Container(
              width: double.infinity,
              padding:
                  const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.black
                    .withOpacity(0.07),
                borderRadius:
                    BorderRadius.circular(
                      16,
                    ),
              ),
              child: Text(
                step.description,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight:
                      FontWeight.w500,
                  color: Colors.black87,
                  height: 1.6,
                ),
              ),
            ),

            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  final String label;
  final bool primary;
  final VoidCallback onTap;

  const _NavButton({
    required this.label,
    required this.primary,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 56,
        decoration: BoxDecoration(
          color:
              primary
                  ? _kButton
                  : _kButton.withOpacity(
                    0.12,
                  ),
          borderRadius:
              BorderRadius.circular(14),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color:
                primary
                    ? _kYellow
                    : AppColors.text,
            fontWeight: FontWeight.w800,
            fontSize: 14,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }
}