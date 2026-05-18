import '../entities/pessoa.dart';
import '../repositories/pessoa_repository.dart';

class ImportarPessoas {
  final PessoaRepository repository;

  ImportarPessoas(this.repository);

  Future<void> call(List<Pessoa> pessoas) async {
    return await repository.popularDoExcel(pessoas);
  }
}
