import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../components/fic_appbar.dart';
import '../components/fic_button.dart';
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
      context.read<PlanilhaViewModel>().inicializarTela();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<PlanilhaViewModel>();

    return Scaffold(
      backgroundColor: AppColors.primaryYellow,

      appBar: const FicAppBar(
        title: 'Encerramento',
      ),

      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40.0),

            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,

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
                viewModel.isLoading &&
                        viewModel.totalConfirmados == 0
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

                const SizedBox(height: 48),

                /// BAIXAR PLANILHA
                FicButton(
                  label: viewModel.isLoading
                      ? "PROCESSANDO..."
                      : "BAIXAR PLANILHA",

                  onPressed: viewModel.isLoading
                      ? null
                      : () async {

                          await viewModel.exportarPlanilhaParticipantes(
                            onSuccess: () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Planilha baixada com sucesso!',
                                  ),
                                ),
                              );
                            },

                            onError: (erro) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(erro),
                                ),
                              );
                            },
                          );
                        },
                ),

                const SizedBox(height: 16),

                /// COMPARTILHAR
                FicButton(
                  label: "COMPARTILHAR",

                  onPressed: () async {

                    final caminho =
                        viewModel.ultimoArquivoGerado;

                    if (caminho == null) {

                      ScaffoldMessenger.of(context)
                          .showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Baixe a planilha primeiro.',
                          ),
                        ),
                      );

                      return;
                    }

                    await Share.shareXFiles([
                      XFile(caminho),
                    ]);
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
        ),
      ),
    );
  }
}