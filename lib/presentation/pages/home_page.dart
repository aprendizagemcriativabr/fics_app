import 'package:flutter/material.dart';
import 'lista_page.dart';
import 'cadastro_page.dart';
import 'checkins_page.dart';
import 'tutorial_page.dart';
import 'encerramento_page.dart';
import 'receber_dados_page.dart';
import '../components/fic_button.dart';
import '../components/fic_feedback.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/logo_fic.png',
                  width: screenWidth * 0.6,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 12),

                // Botão de Validação
                FicButton(
                  label: "Pré-cadastrados",
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ListaPage()),
                  ),
                ),
                const SizedBox(height: 12),

                // Cadastro de Participante
                FicButton(
                  label: "Cadastro no Local",
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CadastroPage()),
                  ),
                ),
                const SizedBox(height: 12),

                // Visualizar todos os Checkins feitos
                FicButton(
                  label: "Visualizar Check-ins",
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const CheckinsPage()),
                  ),
                ),
                const SizedBox(height: 12),

                // Receber Dados
                FicButton(
                  label: "Importar Planilha",
                  onPressed: () async {
                    final result = await Navigator.push<bool>(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const ReceberDadosPage()),
                    );

                    if (result == true && context.mounted) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (!context.mounted) return;
                        FicFeedback.show(
                          context,
                          message: "Dados recebidos com sucesso!",
                          type: FeedbackType.success,
                        );
                      });
                    }
                  },
                ),
                const SizedBox(height: 12),

                // Enviar Dados
                FicButton(
                  label: "Encerrar FICS",
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => EncerramentoPage()),
                  ),
                ),
                const SizedBox(height: 12),

                // Tutorial e Ajuda
                FicButton(
                  label: "Tutorial e Ajuda",
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => TutorialPage()),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
