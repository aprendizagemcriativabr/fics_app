import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/pessoa_view_model.dart';
import '../components/fic_appbar.dart';
import '../components/fic_list_tile.dart';
import '../components/fic_filters_modal.dart';
import '../utility/color.dart';
import 'validacao_page.dart';

class ListaPage extends StatefulWidget {
  const ListaPage({super.key});

  @override
  State<ListaPage> createState() => _ListaPageState();
}

class _ListaPageState extends State<ListaPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Carrega os dados assim que a tela é construída
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final vm = context.read<PessoaViewModel>();
      vm.carregar();
      _searchController.text = vm.filtroNome;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Abre o BottomSheet de filtros e envia as escolhas para a VM
  void _abrirModalFiltro(PessoaViewModel vm) async {
    final resultado = await showModalBottomSheet<Map<String, dynamic>>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FiltroModal(
        statusInicial: vm.filtroStatus,
        ordemAzInicial: vm.ordemAz,
      ),
    );

    if (resultado != null) {
      // Aplica os filtros na ViewModel
      vm.aplicarFiltros(
        status: resultado['status'],
        ordem: resultado['ordem'],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Escuta a ViewModel para reagir a mudanças nos filtros ou na lista
    final vm = Provider.of<PessoaViewModel>(context);
    final listaExibida = vm.pessoasFiltradas;

    return Scaffold(
      backgroundColor: AppColors.primaryYellow,
      appBar: FicAppBar(
        title: "Validação de\npré-cadastro",
        onFilterPressed: () => _abrirModalFiltro(vm),
      ),
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
                controller: _searchController,
                onChanged: (value) {
                  vm.atualizarBuscaNome(value);
                },
                decoration: const InputDecoration(
                  hintText: "Pesquisar por nome...",
                  prefixIcon: Icon(
                    Icons.search,
                    color: AppColors.text,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ),

            // --- LISTA DE RESULTADOS ---
            Expanded(
              child: vm.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.text,
                      ),
                    )
                  : listaExibida.isEmpty
                      ? _buildEmptyState()
                      : ListView.separated(
                          itemCount: listaExibida.length,
                          separatorBuilder: (context, index) =>
                              const SizedBox(height: 5),
                          itemBuilder: (_, i) {
                            final p = listaExibida[i];
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
            color: AppColors.text.withValues(alpha: 0.7),
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