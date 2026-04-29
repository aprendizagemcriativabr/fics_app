import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../components/fic_appbar.dart';
import '../components/fic_button.dart';
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
            appBar: const FicAppBar(title: "Receber dados"),
            body: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0),
              child: Column(
                children: [
                  const SizedBox(height: 80),
                  const Text("ENVIE SUA PLANILHA", 
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 32),
                  
                  FicFilePicker(
                    onTap: vm.isProcessing ? () {} : vm.pickFile,
                    fileName: vm.fileName,
                  ),

                  const Spacer(),

                  FicButton(
                    label: "RECEBER",
                    isLoading: vm.isProcessing, // O loader aparece dentro do botão
                    onPressed: () => vm.executarImportacao(
                      listaVM: context.read<PessoaViewModel>(),
                      onSuccess: () {
                        // Usando seu novo componente de feedback
                        FicFeedback.show(context, 
                          message: "Dados recebidos com sucesso!", 
                          type: FeedbackType.success
                        );
                      },
                      onError: (msg) {
                        FicFeedback.show(context, 
                          message: "Erro: $msg", 
                          type: FeedbackType.error
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}