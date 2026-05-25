import '../../domain/entities/pessoa.dart';
import '../../domain/repositories/pessoa_repository.dart';

import '../datasources/pessoa_datasource.dart';
import '../mappers/pessoa_model_mapper.dart';

class PessoaRepositoryImpl
    implements PessoaRepository {

  final PessoaDataSource datasource;
  final PessoaModelMapper mapper;

  PessoaRepositoryImpl({
    required this.datasource,
    required this.mapper,
  });

  @override
  Future<List<Pessoa>> getAll() async {
    final models = await datasource.getAll();

    return models
        .map(mapper.toEntity)
        .toList();
  }

  @override
  Future<void> saveAll(
    List<Pessoa> pessoas,
  ) async {
    final models =
        pessoas.map(mapper.toModel).toList();

    await datasource.removerPreCadastros();
    await datasource.saveAll(models);
  }

  @override
  Future<void> update(
    Pessoa pessoa,
  ) async {
    final model =
        await datasource.findByNome(
      pessoa.nome,
    );

    if (model == null) return;

    model.acompanhantes =
        pessoa.acompanhantes;

    model.confirmado =
        pessoa.confirmado;

    model.horaEntrada =
        pessoa.horaEntrada;

    model.preCadastro =
        pessoa.preCadastro;

    await datasource.update(model);
  }

  @override
  Future<Pessoa?> findByNome(
    String nome,
  ) async {
    final model =
        await datasource.findByNome(nome);

    if (model == null) return null;

    return mapper.toEntity(model);
  }

  @override
  Future<void> addPessoa(
    Pessoa pessoa,
  ) async {
    final model =
        mapper.toModel(pessoa);

    await datasource.save(model);
  }
}