import '../repositories/pessoa_repository.dart';

class RealizarCheckinUseCase {
  final PessoaRepository repository;

  RealizarCheckinUseCase(
    this.repository,
  );

  Future<void> executar({
    required String nome,
    required int acompanhantes,
  }) async {
    final pessoa =
        await repository.findByNome(nome);

    if (pessoa == null) {
      throw Exception(
        'Pessoa não encontrada',
      );
    }

    final agora = DateTime.now();

    final hora =
        agora.hour.toString().padLeft(2, '0');

    final minuto =
        agora.minute.toString().padLeft(2, '0');

    final horario = '$hora:$minuto';

    final pessoaAtualizada =
        pessoa.copyWith(
      confirmado: true,
      acompanhantes: acompanhantes,
      horaEntrada:
          pessoa.horaEntrada ??
          horario,
    );

    await repository.update(
      pessoaAtualizada,
    );
  }
}