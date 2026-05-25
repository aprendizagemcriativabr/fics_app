import 'package:hive/hive.dart';

import '../models/pessoa_model.dart';

class PessoaDataSource {
  final Box<PessoaModel> box = Hive.box<PessoaModel>('pessoas');
  Future<List<PessoaModel>> getAll() async {
    return box.values.toList();
  }

  Future<void> clear() async {
    await box.clear();
  }

  Future<void> save(
    PessoaModel model,
  ) async {
    await box.add(model);
  }

  Future<void> saveAll(
    List<PessoaModel> models,
  ) async {
    await box.addAll(models);
  }

  Future<PessoaModel?>
      findByNome(String nome) async {
    try {
      return box.values.firstWhere(
        (p) => p.nome == nome,
      );
    } catch (_) {
      return null;
    }
  }

  Future<void> update(
    PessoaModel model,
  ) async {
    await model.save();
  }

  Future<void> removerPreCadastros() async {
    final keysParaRemover = <dynamic>[];

    for (final key in box.keys) {
      final pessoa = box.get(key);

      if (pessoa != null && pessoa.preCadastro == true) {
        keysParaRemover.add(key);
      }
    }

    await box.deleteAll(keysParaRemover);
  }
}