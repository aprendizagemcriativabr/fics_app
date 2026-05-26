import '../entities/pessoa.dart';

abstract class PessoaRepository {
  Future<List<Pessoa>> getAll();

  Future<void> saveAll(
    List<Pessoa> pessoas,
  );

  Future<void> update(
    Pessoa pessoa,
  );

  Future<Pessoa?> findByNome(
    String nome,
  );

  Future<void> addPessoa(
    Pessoa pessoa,
  );

  Future<void> clearAll();
}