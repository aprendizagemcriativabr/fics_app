import '../../domain/entities/pessoa.dart';
import '../../domain/repositories/pessoa_repository.dart';
import '../datasources/pessoa_datasource.dart';
import '../models/pessoa_model.dart';

class PessoaRepositoryImpl implements PessoaRepository {
  final PessoaDataSource dataSource;

  PessoaRepositoryImpl(this.dataSource);

  @override
  Future<List<Pessoa>> getPessoas() async {
    final data = await dataSource.getData();
    return data.map((e) => PessoaModel.fromJson(e)).toList();
  }

  @override
  Future<void> atualizarAcompanhantes(String nome, int qtd) {
    return dataSource.update(nome, qtd);
  }

  @override
  Future<void> popularDoExcel(List<Pessoa> pessoas) async {
    await dataSource.popularDoExcel(pessoas);
  }
}
