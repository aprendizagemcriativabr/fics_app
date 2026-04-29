class Pessoa {
  final String nome;
  final int acompanhantes;
  final bool confirmado;

  Pessoa({
    required this.nome,
    required this.acompanhantes,
    this.confirmado =
        false, // Por padrão, a pessoa não está com o checkin feito
  });
}
