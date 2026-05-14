import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fics_app_new/presentation/viewmodels/pessoa_view_model.dart';
import 'package:fics_app_new/presentation/utility/color.dart';
import '../components/fic_appbar.dart';
import '../components/fic_button.dart';
import '../components/fic_counter.dart';
import '../components/fic_textfield.dart';
import '../components/fic_feedback.dart';

class CadastroPage extends StatefulWidget {
  const CadastroPage({super.key});

  @override
  State<CadastroPage> createState() => _CadastroPageState();
}

class _CadastroPageState extends State<CadastroPage> {
  final TextEditingController nomeController = TextEditingController();
  int acompanhantes = 0;

  @override
  void dispose() {
    nomeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<PessoaViewModel>(context, listen: false);

    return Scaffold(
      appBar: const FicAppBar(title: "Cadastro de\nParticipante"),
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FicTextField(
              label: "Nome do Responsável",
              controller: nomeController,
              hintText: "Digite o nome completo",
            ),
            const SizedBox(height: 30),
            const Text(
              "QUANTIDADE DE ACOMPANHANTES",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: AppColors.text,
              ),
            ),
            const SizedBox(height: 8),
            FicCounter(
              value: acompanhantes,
              onChanged: (newValue) {
                if (newValue >= 0) {
                  setState(() => acompanhantes = newValue);
                }
              },
            ),
            const Spacer(),
            FicButton(
              label: "Cadastrar",
              onPressed: () async {
                if (nomeController.text.trim().isEmpty) {
                  FicFeedback.show(context,
                      message: "Por favor, digite o nome do responsável.",
                      type: FeedbackType.error);
                  return;
                }

                try {
                  await vm.adicionarPessoa(
                      nomeController.text.trim(), acompanhantes);

                  if (context.mounted) {
                    FicFeedback.show(context,
                        message: "Participante cadastrado com sucesso!",
                        type: FeedbackType.success);
                    Navigator.pop(context);
                  }
                } catch (e) {
                  if (context.mounted) {
                    FicFeedback.show(context,
                        message: "Erro ao cadastrar: $e",
                        type: FeedbackType.error);
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}