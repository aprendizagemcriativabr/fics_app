import 'package:hive/hive.dart';
import '../../domain/entities/pessoa.dart';

part 'pessoa_model.g.dart';

@HiveType(typeId: 0)
class PessoaModel extends HiveObject implements Pessoa {

  @override
  @HiveField(0)
  final String nome;

  @override
  @HiveField(1)
  int acompanhantes;

  @override
  @HiveField(2)
  bool confirmado;

  @override
  @HiveField(3)
  String? horaEntrada;

  @override
  @HiveField(4)
  final bool preCadastro;

  PessoaModel({
    required this.nome,
    required this.acompanhantes,
    this.confirmado = false,
    this.horaEntrada,
    this.preCadastro = false,
  });

  factory PessoaModel.fromJson(Map<String, dynamic> json) {
    return PessoaModel(
      nome: json['nome'],
      acompanhantes: json['acomp'],
      confirmado: json['confirmado'] ?? false,
      horaEntrada: json['hora_entrada'],
      preCadastro: json['pre_cadastro'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nome': nome,
      'acomp': acompanhantes,
      'confirmado': confirmado,
      'hora_entrada': horaEntrada,
      'pre_cadastro': preCadastro,
    };
  }

  factory PessoaModel.fromEntity(Pessoa pessoa) {
    return PessoaModel(
      nome: pessoa.nome,
      acompanhantes: pessoa.acompanhantes,
      confirmado: pessoa.confirmado,
      horaEntrada: pessoa.horaEntrada,
      preCadastro: pessoa.preCadastro,
    );
  }
}