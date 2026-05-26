import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../components/fic_appbar.dart';
import '../components/fic_button.dart';
import '../components/fic_feedback.dart'; // Importado para manter o padrão visual de erros
import '../utility/color.dart';
import '../viewmodels/planilha_view_model.dart';
import 'planilha_final_page.dart';

class EncerramentoPage extends StatefulWidget {
  const EncerramentoPage({super.key});

  @override
  State<EncerramentoPage> createState() => _EncerramentoPageState();
}

class _EncerramentoPageState extends State<EncerramentoPage> {
  @override
  void initState() {
    super.initState();

    Future.microtask(() {
      if (mounted) {
        context.read<PlanilhaViewModel>().inicializarTela();
      }
    });
  }

  /// Aciona o compartilhamento direto via ViewModel encapsulada
  void _dispararCompartilhamento(PlanilhaViewModel viewModel) {
    viewModel.compartilharPlanilha(
      onAvisoGerarPrimeiro: () {
        FicFeedback.show(
          context,
          message: 'Baixe a planilha primeiro antes de compartilhar.',
          type: FeedbackType.error,
        );
      },
      onError: (erro) {
        FicFeedback.show(
          context,
          message: 'Erro ao compartilhar: $erro',
          type: FeedbackType.error,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<PlanilhaViewModel>();

    return Scaffold(
      backgroundColor: AppColors.primaryYellow,
      appBar: FicAppBar(
        title: 'Encerramento',
        actions: [
          IconButton(
            icon: const Icon(
              Icons.share_outlined,
              color: AppColors.text,
            ),
            onPressed: () => _dispararCompartilhamento(viewModel),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0),
          child: Column(
            children: [
              /// CONTEÚDO CENTRALIZADO
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'TOTAL DE\nPARTICIPANTES QUE\nCOMPARECERAM',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.text,
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 1.1,
                        ),
                      ),
                      const SizedBox(height: 24),

                      /// TOTAL DE CONFIRMADOS
                      viewModel.isLoading && viewModel.totalConfirmados == 0
                          ? const CircularProgressIndicator(
                              color: AppColors.text,
                            )
                          : Text(
                              '${viewModel.totalConfirmados}',
                              style: const TextStyle(
                                color: AppColors.text,
                                fontSize: 64,
                                fontWeight: FontWeight.w300,
                              ),
                            ),
                    ],
                  ),
                ),
              ),

              /// BOTÕES FIXADOS NO FINAL DA TELA
              Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    /// BAIXAR PLANILHA
                    FicButton(
                      label: viewModel.isLoading ? "PROCESSANDO..." : "BAIXAR PLANILHA",
                      onPressed: viewModel.isLoading
                          ? null
                          : () async {
                              await viewModel.exportarPlanilhaParticipantes(
                                onSuccess: () {
                                  FicFeedback.show(
                                    context,
                                    message: 'Planilha baixada com sucesso!',
                                    type: FeedbackType.success,
                                  );
                                },
                                onError: (erro) {
                                  FicFeedback.show(
                                    context,
                                    message: erro,
                                    type: FeedbackType.error,
                                  );
                                },
                              );
                            },
                    ),
                    const SizedBox(height: 16),

                    /// MESCLAR PLANILHAS
                    FicButton(
                      label: "MESCLAR PLANILHAS",
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const UnificarDadosPage(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}