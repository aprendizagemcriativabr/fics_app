import 'package:fics_app_new/domain/repositories/pessoa_repository.dart';
import 'package:fics_app_new/domain/entities/pessoa.dart';

class GetPessoas {
  final PessoaRepository repository;

  GetPessoas(this.repository);

  Future<List<Pessoa>> call() {
    return repository.getPessoas();
  }
}
