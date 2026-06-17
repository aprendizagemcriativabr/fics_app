import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../components/fic_appbar.dart';
import '../components/fic_button.dart';
import '../components/fic_feedback.dart'; 
import '../components/fic_dialog.dart'; 
import '../utility/color.dart';
import '../viewmodels/planilha_view_model.dart';
import '../viewmodels/pessoa_view_model.dart'; 
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
    final pessoaViewModel = context.watch<PessoaViewModel>();

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
                      viewModel.isLoading && viewModel.totalParticipantes == 0
                          ? const CircularProgressIndicator(
                              color: AppColors.text,
                            )
                          : Text(
                              '${viewModel.totalParticipantes}',
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
                      label: "BAIXAR E EXPORTAR",
                      isLoading: viewModel.isLoading,
                      onPressed: () async {
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

                    /// UNIFICAR PLANILHAS
                    FicButton(
                      label: "UNIFICAR PLANILHAS",
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const UnificarDadosPage(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),

                    FicButton(
                      label: "FINALIZAR E APAGAR DADOS",
                      backgroundColor: Colors.red
                          .shade800, 
                      isLoading: pessoaViewModel.isLoading,
                      onPressed: () async {
                        final confirmar = await FicDialog.show(
                          context: context,
                          title: "ATENÇÃO!",
                          message:
                              "Esta ação apagará de forma permanente todos os dados cadastrados e check-ins deste dispositivo. Certifique-se de ter exportado tudo.\n\nDeseja continuar?",
                          confirmText: "SIM, APAGAR",
                          cancelText: "NÃO",
                        );

                        if (confirmar == true) {
                          try {
                            await pessoaViewModel.apagarTodosOsDados();
                            await viewModel.inicializarTela();

                            if (!context.mounted) return;
                            FicFeedback.show(
                              context,
                              message: "Dados do FICS apagados com sucesso!",
                              type: FeedbackType.success,
                            );
                          } catch (e) {
                            if (!context.mounted) return;
                            FicFeedback.show(
                              context,
                              message: "Erro ao apagar dados: $e",
                              type: FeedbackType.error,
                            );
                          }
                        }
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
