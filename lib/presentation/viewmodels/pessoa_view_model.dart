import 'package:flutter/material.dart';
import '../../domain/entities/pessoa.dart';
import '../../domain/usecases/get_pessoas.dart';
import '../../domain/usecases/atualizar_acompanhantes.dart';

class PessoaViewModel extends ChangeNotifier {
  final GetPessoas getPessoas;
  final AtualizarAcompanhantes atualizar;

  PessoaViewModel(this.getPessoas, this.atualizar);

  List<Pessoa> pessoas = [];
  bool isLoading = false;

  Future<void> carregar() async {
    isLoading = true;
    notifyListeners();

    pessoas = await getPessoas();

    isLoading = false;
    notifyListeners();
  }

  Future<void> atualizarQtd(String nome, int qtd) async {
    await atualizar(nome, qtd);
    await carregar();
  }
}