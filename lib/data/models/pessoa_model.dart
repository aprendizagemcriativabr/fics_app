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

  PessoaModel({
    required this.nome,
    required this.acompanhantes,
    this.confirmado = false,
  });

  factory PessoaModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return PessoaModel(
      nome: json['nome'],
      acompanhantes: json['acomp'],
      confirmado: json['confirmado'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nome': nome,
      'acomp': acompanhantes,
      'confirmado': confirmado,
    };
  }

  factory PessoaModel.fromEntity(
    Pessoa pessoa,
  ) {
    return PessoaModel(
      nome: pessoa.nome,
      acompanhantes: pessoa.acompanhantes,
      confirmado: pessoa.confirmado,
    );
  }
}