import '../repositories/pessoa_repository.dart'; 

class DeletarTodasPessoasUseCase {
  final PessoaRepository _repository;

  DeletarTodasPessoasUseCase(this._repository);

  Future<void> execute() async {
    await _repository.clearAll();
  }
}