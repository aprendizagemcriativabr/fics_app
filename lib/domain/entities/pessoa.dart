class Pessoa {
  final String nome;
  final int acompanhantes;
  final bool confirmado;
  final String? horaEntrada;
  final bool preCadastro;

  Pessoa({
    required this.nome,
    required this.acompanhantes,
    this.confirmado = false,
    this.horaEntrada,
    this.preCadastro = false,
  });
}
