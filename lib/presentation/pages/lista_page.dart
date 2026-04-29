import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/pessoa_view_model.dart';
import 'validacao_page.dart';
import '../components/fic_appbar.dart';
import '../components/fic_list_tile.dart';
import '../utility/color.dart';

class ListaPage extends StatefulWidget {
  const ListaPage({super.key});

  @override
  State<ListaPage> createState() => _ListaPageState();
}

class _ListaPageState extends State<ListaPage> {
  String filtro = ""; 

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<PessoaViewModel>(context);

    final pessoasFiltradas = vm.pessoas
        .where((p) => p.nome.toLowerCase().contains(filtro.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: const FicAppBar(title: "Validação de\npré-cadastro"),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            // --- BARRA DE PESQUISA ---
            Container(
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: AppColors.secondaryYellow, 
                borderRadius: BorderRadius.circular(15),
              ),
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    filtro = value;
                  });
                },
                decoration: const InputDecoration(
                  hintText: "Pesquisar por nome...",
                  prefixIcon: Icon(Icons.search, color: AppColors.text),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ),

            // --- LISTA DE RESULTADOS ---
            Expanded(
              child: vm.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: AppColors.text), 
                    )
                  : pessoasFiltradas.isEmpty
                      ? _buildEmptyState()
                      : ListView.separated(
                          itemCount: pessoasFiltradas.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 5),
                          itemBuilder: (_, i) {
                            final p = pessoasFiltradas[i];

                            return FicListTile(
                              pessoa: p,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => ValidacaoPage(pessoa: p),
                                  ),
                                );
                              },
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off, 
            size: 60, 
            color: AppColors.text.withOpacity(0.3), 
          ),
          const SizedBox(height: 10),
          const Text(
            "Nenhum participante encontrado",
            style: TextStyle(
              fontWeight: FontWeight.bold, 
              color: AppColors.text,
            ),
          ),
        ],
      ),
    );
  }
}