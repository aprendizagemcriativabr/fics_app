import 'dart:io';
import 'package:flutter/widgets.dart';

import '../entities/pessoa.dart';
import '../../data/services/import_service.dart';

class UnificarPlanilhas {
  final ImportService importService;

  UnificarPlanilhas(this.importService);

  Future<List<Pessoa>> call(List<File> arquivos) async {
    List<Pessoa> todasPessoas = [];

    for (final arquivo in arquivos) {
      try {
        final pessoas = await importService.lerPlanilha(arquivo);
        todasPessoas.addAll(pessoas);
      } catch (e) {
        debugPrint("Erro ao ler arquivo ${arquivo.path}: $e");
      }
    }

    final Map<String, Pessoa> pessoasUnificadas = {};

    for (final pessoa in todasPessoas) {
      final chave = pessoa.nome.toLowerCase().trim();

      if (chave.isEmpty || chave == 'nome' || chave.contains('total geral')) {
        continue;
      }

      if (!pessoasUnificadas.containsKey(chave)) {
        pessoasUnificadas[chave] = pessoa;
        continue;
      }

      final existente = pessoasUnificadas[chave]!;

      final bool existenteTemHora = existente.horaEntrada != null &&
          existente.horaEntrada!.trim().isNotEmpty &&
          existente.horaEntrada!.trim() != '--:--';

      final bool pessoaTemHora = pessoa.horaEntrada != null &&
          pessoa.horaEntrada!.trim().isNotEmpty &&
          pessoa.horaEntrada!.trim() != '--:--';

      String? horaFinal;
      bool preCadastroFinal;

      if (pessoaTemHora && !existenteTemHora) {
        horaFinal = pessoa.horaEntrada;
        preCadastroFinal = pessoa.preCadastro;
      } else if (existenteTemHora && !pessoaTemHora) {
        horaFinal = existente.horaEntrada;
        preCadastroFinal = existente.preCadastro;
      } else if (pessoaTemHora && existenteTemHora) {
        horaFinal = existente.horaEntrada;
        preCadastroFinal = existente.preCadastro;
      } else {
        horaFinal = null;
        preCadastroFinal = existente.preCadastro && pessoa.preCadastro;
      }

      pessoasUnificadas[chave] = Pessoa(
        nome: existenteTemHora ? existente.nome : pessoa.nome,
        acompanhantes: pessoa.acompanhantes > existente.acompanhantes
            ? pessoa.acompanhantes
            : existente.acompanhantes,
        confirmado: horaFinal != null,
        horaEntrada: horaFinal,
        preCadastro: preCadastroFinal,
      );
    }

    return pessoasUnificadas.values.toList();
  }
}
