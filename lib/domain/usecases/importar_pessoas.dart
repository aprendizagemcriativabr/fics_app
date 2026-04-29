import '../entities/pessoa.dart';
import '../repositories/pessoa_repository.dart';

class ImportarPessoas {
  final PessoaRepository repository;

  ImportarPessoas(this.repository);

  Future<void> call(List<Pessoa> pessoas) async {
    // Aqui você poderia adicionar regras de negócio, 
    // como validar se a lista não é nula antes de enviar ao repo.
    return await repository.popularDoExcel(pessoas);
  }
}