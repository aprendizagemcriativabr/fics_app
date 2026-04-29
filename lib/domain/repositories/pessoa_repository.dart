import 'package:fics_app_new/domain/entities/pessoa.dart';

abstract class PessoaRepository {
  Future<List<Pessoa>> getPessoas();
  Future<void> atualizarAcompanhantes(String nome, int quantidade);
  Future<void> popularDoExcel(List<Pessoa> pessoas);
}
