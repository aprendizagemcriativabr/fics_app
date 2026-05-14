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
    return ChangeNotifierProvider(
      create: (_) => ReceberDadosViewModel(),

      child: Consumer<ReceberDadosViewModel>(
        builder: (context, vm, child) {
          return Scaffold(
            appBar: const FicAppBar(
              title: "Receber dados",
            ),

            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 40.0,
                ),

                child: Column(
                  children: [
                    /// CONTEÚDO CENTRAL
                    Expanded(
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,

                          children: [
                            const Text(
                              "ENVIE SUA PLANILHA",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),

                            const SizedBox(height: 32),

                            FicFilePicker(
                              onTap: vm.isProcessing
                                  ? () {}
                                  : vm.pickFile,

                              fileName: vm.fileName,
                            ),
                          ],
                        ),
                      ),
                    ),

                    /// BOTÃO NO FINAL
                    Padding(
                      padding: const EdgeInsets.only(
                        bottom: 24,
                      ),

                      child: FicButton(
                        label: "RECEBER",
                        isLoading: vm.isProcessing,

                        onPressed: vm.canSubmit
                            ? () async {
                                final pessoaVM =
                                    context.read<PessoaViewModel>();

                                if (pessoaVM.todasPessoas.isNotEmpty) {
                                  final confirmar =
                                      await FicDialog.show(
                                    context: context,
                                    title: "Atenção",
                                    message:
                                        "Você já enviou uma planilha.\n\n"
                                        "Tem certeza que deseja continuar?\n"
                                        "Os dados atuais serão substituídos.",
                                    confirmText: "SIM",
                                    cancelText: "NÃO",
                                  );

                                  if (confirmar != true) {
                                    return;
                                  }
                                }

                                vm.executarImportacao(
                                  listaVM: pessoaVM,

                                  onSuccess: () {
                                    FicFeedback.show(
                                      context,
                                      message:
                                          "Dados recebidos com sucesso!",
                                      type: FeedbackType.success,
                                    );
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