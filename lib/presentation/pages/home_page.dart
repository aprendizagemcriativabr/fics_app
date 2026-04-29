import 'package:fics_app_new/presentation/pages/receber_dados_page.dart';
import 'package:flutter/material.dart';
import 'lista_page.dart';
import '../components/fic_button.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      // O backgroundColor é herdado do Theme (primaryYellow),
      // mas mantemos o SafeArea para a logo não bater no topo.
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/logo_fic.png',
                  width: screenWidth * 0.6, // Ocupa 40% da largura da tela
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: 40),

                // Botão de Validação
                FicButton(
                  label: "Validação de Pré-Cadastro",
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ListaPage()),
                  ),
                ),
                const SizedBox(height: 24),

                // Cadastro de Participante
                FicButton(
                  label: "Cadastro de Participante",
                  onPressed: () {
                    // Futura CadastroPage()
                  },
                ),
                const SizedBox(height: 24),

                // Receber Dados
                FicButton(
                  label: "Receber Dados",
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ReceberDadosPage()),
                  ),
                ),
                const SizedBox(height: 24),

                // Enviar Dados
                FicButton(
                  label: "Enviar Dados",
                  onPressed: () {
                    // Lógica para mandar pro Sheets
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
