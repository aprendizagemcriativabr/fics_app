import 'package:flutter/material.dart';
import '../../domain/entities/pessoa.dart';
import '../../domain/usecases/get_pessoas.dart';
import '../../domain/usecases/atualizar_acompanhantes.dart';
import '../../domain/usecases/importar_pessoas.dart'; // Importe o novo UseCase

class PessoaViewModel extends ChangeNotifier {
  final GetPessoas getPessoas;
  final AtualizarAcompanhantes atualizar;
  final ImportarPessoas importar; // 1. Adicione a variável

  // 2. Adicione ao construtor
  PessoaViewModel(this.getPessoas, this.atualizar, this.importar);

  List<Pessoa> pessoas = [];
  bool isLoading = false;

  Future<void> carregar() async {
    isLoading = true;
    notifyListeners();
    pessoas = await getPessoas();
    isLoading = false;
    notifyListeners();
  }

  // 3. O método que recebe os dados da outra VM
  Future<void> importarNovasPessoas(List<Pessoa> novasPessoas) async {
    isLoading = true;
    notifyListeners();

    try {
      await importar(novasPessoas); // Chama o UseCase
      await carregar(); // Recarrega a lista para atualizar a UI
    } catch (e) {
      debugPrint("Erro ao importar: $e");
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> atualizarQtd(String nome, int qtd) async {
    await atualizar(nome, qtd);
    await carregar();
  }
}