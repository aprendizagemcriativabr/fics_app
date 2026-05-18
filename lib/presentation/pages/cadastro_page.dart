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
  void initState() {
    super.initState();
    nomeController.addListener(_atualizarEstadoBotao);
  }

  void _atualizarEstadoBotao() {
    setState(() {});
  }

  @override
  void dispose() {
    nomeController.removeListener(_atualizarEstadoBotao);
    nomeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<PessoaViewModel>();
    final bool possuiNome = nomeController.text.trim().isNotEmpty;

    return Scaffold(
      appBar: const FicAppBar(
        title: "Cadastro de\nParticipante",
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(30.0),
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
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
                            setState(() {
                              acompanhantes = newValue;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 24),
                child: FicButton(
                  label: "Cadastrar",
                  isLoading: vm.isLoading,
                  onPressed: (vm.isLoading || !possuiNome)
                      ? null
                      : () async {
                          try {
                            await vm.adicionarPessoa(
                              nomeController.text,
                              acompanhantes,
                            );

                            if (!context.mounted) return;

                            FicFeedback.show(
                              context,
                              message: "Participante cadastrado com sucesso!",
                              type: FeedbackType.success,
                            );

                            nomeController.clear();
                            setState(() {
                              acompanhantes = 0;
                            });
                          } catch (e) {
                            if (!context.mounted) return;

                            FicFeedback.show(
                              context,
                              message:
                                  e.toString().replaceAll("Exception: ", ""),
                              type: FeedbackType.error,
                            );
                          }
                        },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
