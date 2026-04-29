import '../../domain/entities/pessoa.dart';

class PessoaModel extends Pessoa {
  PessoaModel({
    required super.nome,
    required super.acompanhantes,
    super.confirmado,
  });

  factory PessoaModel.fromJson(Map<String, dynamic> json) {
    return PessoaModel(
      nome: json['nome'],
      acompanhantes: json['acomp'],
      // Lê o campo do DataSource ou assume falso se não existir
      confirmado: json['confirmado'] ?? false,
    );
  }
}
