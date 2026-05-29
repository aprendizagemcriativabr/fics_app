class Pessoa {
  final String nome;
  final int acompanhantes;
  final bool confirmado;
  final String? horaEntrada;
  final bool preCadastro;

  Pessoa({
    required this.nome,
    required this.acompanhantes,
    required this.confirmado,
    this.horaEntrada,
    this.preCadastro = false,
  });

  Pessoa copyWith({
    String? nome,
    int? acompanhantes,
    bool? confirmado,
    String? horaEntrada,
    bool? preCadastro,
  }) {
    return Pessoa(
      nome: nome ?? this.nome,
      acompanhantes: acompanhantes ?? this.acompanhantes,
      confirmado: confirmado ?? this.confirmado,
      horaEntrada: horaEntrada ?? this.horaEntrada,
      preCadastro: preCadastro ?? this.preCadastro,
    );
  }
}
