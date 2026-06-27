import 'package:flutter/material.dart';
import 'package:fics_app_new/presentation/utility/color.dart';
import '../components/fic_appbar.dart';

class CreditosPage extends StatelessWidget {
  const CreditosPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryYellow,
      appBar: const FicAppBar(
        title: "Créditos",
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              _buildSectionTitle("DESENVOLVIMENTO"),
              _buildCreditLine("Izabella Júlia dos Santos"),
              _buildCreditLine("Antônio Carlos Rosendo da Silva"),
              _buildCreditLine("Giovanni da Silva Virginio Brandão"),
              _buildCreditLine("Julyo Elias Hidalgo da Silva"),
              _buildCreditLine("Gabriel Matheus Pereira dos Santos"), 
              _buildCreditLine("João Vitor da Fraga Anacleto"),
              const SizedBox(height: 24),

              _buildSectionTitle("DESIGN & UX"),
              _buildCreditLine("Izabella Júlia dos Santos"),
              const SizedBox(height: 24),

              _buildSectionTitle("REALIZAÇÃO"),
              _buildCreditLine("UNICAMP"),
              _buildCreditLine("Festival de Invenção e Criatividade"),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const SafeArea(
        child: Padding(
          padding: EdgeInsets.only(bottom: 16),
          child: Text(
            "Versão 1.0.0",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: AppColors.button,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 22,
          color: AppColors.button,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildCreditLine(String name) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        name,
        style: const TextStyle(
          fontSize: 16,
          color: AppColors.text,
        ),
      ),
    );
  }
}