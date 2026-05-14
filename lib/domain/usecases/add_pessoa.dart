import 'package:fics_app_new/domain/repositories/pessoa_repository.dart';
import 'package:fics_app_new/domain/entities/pessoa.dart';

class AddPessoa {
  final PessoaRepository repository;

  AddPessoa(this.repository);

  Future<void> call(Pessoa pessoa) {
    return repository.addPessoa(pessoa);
  }
}