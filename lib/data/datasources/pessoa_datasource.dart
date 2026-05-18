import 'package:hive/hive.dart';
import '../models/pessoa_model.dart';
import '../../domain/entities/pessoa.dart';

class PessoaDataSource {

  final Box<PessoaModel> box =
      Hive.box<PessoaModel>('pessoas');

  /// Retorna pessoas salvas localmente
  Future<List<PessoaModel>> getData() async {
    return box.values.toList();
  }

  /// Atualiza check-in
  Future<void> update(
    String nome,
    int novaQtd,
  ) async {

    final pessoa = box.values.firstWhere(
      (p) => p.nome == nome,
    );

    pessoa.acompanhantes = novaQtd;
    pessoa.confirmado = true;

    if (pessoa.horaEntrada == null) {
      final agora = DateTime.now();
      final hora = agora.hour.toString().padLeft(2, '0');
      final minuto = agora.minute.toString().padLeft(2, '0');
      pessoa.horaEntrada = "$hora:$minuto";
    }

    await pessoa.save();
  }

  /// Importa nova planilha
  Future<void> popularDoExcel(
    List<Pessoa> novasPessoas,
  ) async {

    /// limpa antigos
    await box.clear();

    /// salva novos
    for (final pessoa in novasPessoas) {

      final model = PessoaModel(
        nome: pessoa.nome,
        acompanhantes: pessoa.acompanhantes,
        confirmado: false,
        horaEntrada: null,
        preCadastro: true,
      );

      await box.add(model);
    }
  }

  /// Adiciona uma nova pessoa ao datasource
  Future<void> addPessoa(Pessoa pessoa) async {

    final model = PessoaModel(
      nome: pessoa.nome,
      acompanhantes: pessoa.acompanhantes,
      confirmado: pessoa.confirmado,
      horaEntrada: pessoa.horaEntrada,
      preCadastro: false,
    );

    await box.add(model);
  }
}