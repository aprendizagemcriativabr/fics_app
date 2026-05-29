import '../entities/pessoa.dart';
import '../repositories/pessoa_repository.dart';

class GetPessoas {
  final PessoaRepository repository;

  GetPessoas(this.repository);

  Future<List<Pessoa>> call() async {
    return await repository.getAll();
  }
}
