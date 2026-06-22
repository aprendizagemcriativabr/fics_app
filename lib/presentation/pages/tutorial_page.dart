import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../viewmodels/tutorial_view_model.dart';
import '../components/fic_appbar.dart';
import '../components/fic_search_bar.dart';
import '../components/fic_empty_state.dart';
import '../components/tutorials/fic_expandable_faq.dart';
import '../components/tutorials/fic_flow_card.dart';
import '../components/tutorials/fic_section_label.dart';
import '../components/tutorials/fic_tutorial_detail.dart';
import '../utility/color.dart';

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
  late final TutorialViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = TutorialViewModel(initialFlowId: widget.initialFlowId);
    _viewModel.addListener(_onViewModelChanged);
    _viewModel.loadTutorials();
  }

  @override
  void dispose() {
    _viewModel.removeListener(_onViewModelChanged);
    _viewModel.dispose();
    super.dispose();
  }

  void _onViewModelChanged() {
    setState(() {});
  }

  Future<void> _launchEmailApp() async {
    final Uri emailLaunchUri = Uri.parse(
      'mailto:info@aprendizagemcriativa.org?subject=Dúvida%20-%20Aplicativo%20FIC',
    );

    try {
      await launchUrl(
        emailLaunchUri,
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      debugPrint('Não foi possível abrir o app de e-mail.');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_viewModel.tutorials.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.primaryYellow,
        appBar: FicAppBar(
          title: 'TUTORIAL',
          onBack: () => Navigator.pop(context),
        ),
        body: const SafeArea(
          bottom: true,
          top: false,
          child: FicEmptyState(
            text: 'Nenhum tutorial encontrado.',
          ),
        ),
      );
    }

    return PopScope(
      canPop: _viewModel.selectedFlow == null,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _viewModel.selectFlow(null);
      },
      child: Scaffold(
        backgroundColor: AppColors.primaryYellow,
        appBar: FicAppBar(
          title: _viewModel.selectedFlow == null
              ? 'TUTORIAL'
              : _viewModel.selectedFlow!.title,
          onBack: () => _viewModel.handleBack(Navigator.of(context)),
        ),
        body: SafeArea(
          bottom: true,
          top: false,
          child: AnimatedSwitcher(
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
            child: _viewModel.selectedFlow == null
                ? _buildHome()
                : FicTutorialDetail(
                    key: ValueKey(_viewModel.selectedFlow!.id),
                    flow: _viewModel.selectedFlow!,
                    onComplete: () => _viewModel.selectFlow(null),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildHome() {
    final listaFiltradaFaqs = _viewModel.getFilteredFaqs();

    return Scrollbar(
      controller: _viewModel.homeScrollController,
      thumbVisibility: true,
      child: ListView(
        controller: _viewModel.homeScrollController,
        key: const ValueKey('home'),
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        children: [
          FicSearchBar(
            hintText: 'O que você precisa saber?',
            controller: _viewModel.searchController,
            onChanged: _viewModel.updateFilter,
          ),
          const SizedBox(height: 12),
          if (_viewModel.filterText.isNotEmpty) ...[
            const FicSectionLabel('RESULTADOS'),
            const SizedBox(height: 12),
            if (listaFiltradaFaqs.isEmpty)
              const FicEmptyState(text: 'Nenhuma dúvida encontrada')
            else
              ...listaFiltradaFaqs.map(
                (e) => FicExpandableFaq(
                  faq: e.key,
                  parentFlow: e.value,
                  onSelectFlow: _viewModel.selectFlow,
                ),
              ),
          ] else ...[
            const FicSectionLabel('TUTORIAIS POR FLUXO'),
            const SizedBox(height: 12),
            ..._viewModel.tutorials.map(
              (flow) => FicFlowCard(
                flow: flow,
                onTap: () => _viewModel.selectFlow(flow),
              ),
            ),
            const SizedBox(height: 28),
            const FicSectionLabel('DÚVIDAS COMUNS'),
            const SizedBox(height: 12),
            ...listaFiltradaFaqs.map(
              (e) => FicExpandableFaq(
                faq: e.key,
                parentFlow: e.value,
                onSelectFlow: _viewModel.selectFlow,
              ),
            ),
            const SizedBox(height: 48),
            Column(
              children: [
                const Icon(
                  Icons.contact_support_outlined,
                  color: Color(0xFF1E1E24),
                  size: 28,
                ),
                const SizedBox(height: 10),
                const Text(
                  'Precisa de mais ajuda?',
                  style: TextStyle(
                    color: Color(0xFF1E1E24),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    'Fale conosco e nossa equipe de suporte responderá diretamente no seu e-mail.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Color(0x991E1E24),
                      fontSize: 13,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: _launchEmailApp,
                  child: const Text(
                    'Fale conosco',
                    style: TextStyle(
                      color: AppColors.text,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      decoration: TextDecoration.underline,
                      decorationColor: AppColors.text,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}