import '../../domain/entities/pessoa.dart';
import '../../domain/repositories/pessoa_repository.dart';
import '../datasources/pessoa_datasource.dart';

class PessoaRepositoryImpl implements PessoaRepository {
  final PessoaDataSource dataSource;

  PessoaRepositoryImpl(this.dataSource);

  @override
  Future<List<Pessoa>> getPessoas() async {
    return await dataSource.getData();
  }

  @override
  Future<void> atualizarAcompanhantes(String nome, int qtd) {
    return dataSource.update(nome, qtd);
  }

  @override
  Future<void> popularDoExcel(List<Pessoa> pessoas) async {
    await dataSource.popularDoExcel(pessoas);
  }

  @override
  Future<void> addPessoa(Pessoa pessoa) async {
    await dataSource.addPessoa(pessoa);
  }
}
