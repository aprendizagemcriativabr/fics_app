import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/pessoa_view_model.dart';
import '../components/fic_appbar.dart';
import '../components/fic_search_bar.dart';
import '../components/fic_list_tile.dart';
import '../components/fic_empty_state.dart';
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
      vm.aplicarFiltros(
        status: resultado['status'],
        ordem: resultado['ordem'],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
            FicSearchBar(
              hintText: "Pesquisar por nome...",
              controller: _searchController,
              onChanged: (value) {
                vm.atualizarBuscaNome(value);
              },
            ),
            Expanded(
              child: vm.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.text,
                      ),
                    )
                  : listaExibida.isEmpty
                      ? const FicEmptyState() 
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
}
