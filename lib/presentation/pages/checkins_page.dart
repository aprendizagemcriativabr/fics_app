import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:fics_app_new/presentation/viewmodels/pessoa_view_model.dart';
import 'package:fics_app_new/presentation/utility/color.dart';

import '../components/fic_appbar.dart';
import '../components/fic_search_bar.dart';
import '../components/fic_list_tile.dart';

class CheckinsPage extends StatefulWidget {
  const CheckinsPage({super.key});

  @override
  State<CheckinsPage> createState() => _CheckinsPageState();
}

class _CheckinsPageState extends State<CheckinsPage> {
  String filterText = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<PessoaViewModel>();

    final listaFiltrada = vm.pessoasComCheckin.where((pessoa) {
      return pessoa.nome.toLowerCase().contains(filterText.toLowerCase());
    }).toList();
    listaFiltrada.sort((a, b) => a.nome.toLowerCase().compareTo(b.nome.toLowerCase()));

    return Scaffold(
      backgroundColor: AppColors.primaryYellow,
      appBar: const FicAppBar(
        title: "Checkins\nRealizados",
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            children: [
              const SizedBox(height: 10),
              FicSearchBar(
                hintText: "Pesquisar participante confirmado...",
                controller: _searchController,
                onChanged: (value) {
                  setState(() {
                    filterText = value;
                  });
                },
              ),
              Expanded(
                child: listaFiltrada.isEmpty
                    ? Center(
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
                              "Nenhum check-in encontrado",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.text,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.separated(
                        itemCount: listaFiltrada.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 5),
                        itemBuilder: (context, index) {
                          return FicListTile(
                            pessoa: listaFiltrada[index],
                            isCheckinFlow: true,
                          );
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