import 'package:fics_app_new/presentation/utility/color.dart';
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
      backgroundColor: const Color(0xFFFFCC00),
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 20),
                      Image.asset(
                        'assets/images/logo_fic.png',
                        width: screenWidth * 0.6,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 12),
                      FicButton(
                        label: "Pré-cadastrados",
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ListaPage()),
                        ),
                      ),
                      const SizedBox(height: 12),
                      FicButton(
                        label: "Cadastro no Local",
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const CadastroPage()),
                        ),
                      ),
                      const SizedBox(height: 12),
                      FicButton(
                        label: "Visualizar Check-ins",
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const CheckinsPage()),
                        ),
                      ),
                      const SizedBox(height: 12),
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
                      FicButton(
                        label: "Encerrar FICS",
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => EncerramentoPage()),
                        ),
                      ),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 16,
              left: 24,
              right: 24,
              child: SizedBox(
                height: 50,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Icon(Icons.copyright,
                            size: 14, color: AppColors.button),
                        const SizedBox(width: 4),
                        Text(
                          "UNICAMP",
                          style: TextStyle(
                            color: AppColors.button,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.1,
                          ),
                        ),
                      ],
                    ),
                    Positioned(
                      right: 0,
                      child: IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        icon: const Icon(
                          Icons.help_outline,
                          size: 42,
                          color: AppColors.button,
                        ),
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const TutorialPage()),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
