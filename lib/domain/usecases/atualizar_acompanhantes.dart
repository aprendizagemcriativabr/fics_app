import 'package:fics_app_new/domain/repositories/pessoa_repository.dart';

class AtualizarAcompanhantes {
  final PessoaRepository repository;

  AtualizarAcompanhantes(this.repository);

  Future<void> call(String nome, int qtd) {
    return repository.atualizarAcompanhantes(nome, qtd);
  }
}