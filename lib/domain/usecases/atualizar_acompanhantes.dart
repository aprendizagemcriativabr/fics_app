import '../repositories/pessoa_repository.dart';

class AtualizarAcompanhantes {
  final PessoaRepository repository;

  AtualizarAcompanhantes(
    this.repository,
  );

  Future<void> call(
    String nome,
    int acompanhantes,
  ) async {
    final pessoa = await repository.findByNome(nome);

    if (pessoa == null) return;

    final agora = DateTime.now();
    final hora = agora.hour.toString().padLeft(2, '0');
    final minuto = agora.minute.toString().padLeft(2, '0');
    final horaFormatada = "$hora:$minuto";

    final atualizada = pessoa.copyWith(
      acompanhantes: acompanhantes,
      confirmado: true,
      horaEntrada: horaFormatada,
    );

    await repository.update(
      atualizada,
    );
  }
}
