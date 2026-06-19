import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../components/fic_appbar.dart';
import '../components/fic_button.dart';
import '../components/fic_dialog.dart';
import '../components/fic_file_picker.dart';
import '../components/fic_feedback.dart';
import '../viewmodels/receber_dados_view_model.dart';
import '../viewmodels/pessoa_view_model.dart';

class ReceberDadosPage extends StatelessWidget {
  const ReceberDadosPage({super.key});

  @override
  Widget build(BuildContext context) {
    final pessoaVM = context.read<PessoaViewModel>();

    return ChangeNotifierProvider(
      create: (_) => ReceberDadosViewModel(),
      child: Consumer<ReceberDadosViewModel>(
        builder: (context, vm, child) {
          return Scaffold(
            appBar: const FicAppBar(title: "Receber dados"),
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: Column(
                  children: [
                    Expanded(
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              "ENVIE SUA PLANILHA",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 24),
                            FicFilePicker(
                              fileName: vm.fileName,
                              onTap: () => vm.pickFile(),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 24.0),
                      child: FicButton(
                        label: "Importar dados",
                        isLoading: vm.isProcessing,
                        onPressed: vm.selectedFile != null
                            ? () async {
                                if (pessoaVM.possuiPreCadastro) {
                                  final confirmar = await FicDialog.show(
                                    context: context,
                                    title: "Substituir Dados?",
                                    message:
                                        "Já existem participantes importados de uma lista anterior. Se prosseguir, os dados de pré-cadastro atuais serão substituídos.",
                                    confirmText: "SIM",
                                    cancelText: "NÃO",
                                  );

                                  if (confirmar != true) return;
                                }

                                vm.executarImportacao(
                                  listaVM: pessoaVM,
                                  onSuccess: () {
                                    if (!context.mounted) return;
                                    Navigator.pop(context, true);
                                  },
                                  onError: (msg) {
                                    FicFeedback.show(
                                      context,
                                      message: "Erro: $msg",
                                      type: FeedbackType.error,
                                    );
                                  },
                                );
                              }
                            : null,
                      ),
                    ),
                    const SizedBox(height: 50),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
