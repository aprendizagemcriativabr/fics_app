import 'package:hive/hive.dart';

part 'pessoa_model.g.dart';

@HiveType(typeId: 0)
class PessoaModel extends HiveObject {
  @HiveField(0)
  String nome;

  @HiveField(1)
  int acompanhantes;

  @HiveField(2)
  bool confirmado;

  @HiveField(3)
  String? horaEntrada;

  @HiveField(4)
  bool preCadastro;

  PessoaModel({
    required this.nome,
    required this.acompanhantes,
    required this.confirmado,
    this.horaEntrada,
    required this.preCadastro,
  });
}
