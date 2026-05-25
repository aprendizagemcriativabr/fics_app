import 'dart:io';
import '../entities/pessoa.dart';
import '../../data/services/import_service.dart';

class UnificarPlanilhas {
  final ImportService importService;

  UnificarPlanilhas(this.importService);

  Future<List<Pessoa>> call(List<File> arquivos) async {
    List<Pessoa> todasPessoas = [];

    /// 1. IMPORTA TODOS OS ARQUIVOS
    for (final arquivo in arquivos) {
      try {
        final pessoas = await importService.lerPlanilha(arquivo);
        todasPessoas.addAll(pessoas);
      } catch (e) {
        print("Erro ao ler arquivo ${arquivo.path}: $e");
      }
    }

    /// 2. MAPA DE UNIFICAÇÃO
    final Map<String, Pessoa> pessoasUnificadas = {};

    for (final pessoa in todasPessoas) {
      final chave = pessoa.nome.toLowerCase().trim();

      // Ignora lixo, cabeçalhos ou linhas de totais
      if (chave.isEmpty || chave == 'nome' || chave.contains('total geral')) {
        continue;
      }

      /// PRIMEIRA OCORRÊNCIA DA PESSOA
      if (!pessoasUnificadas.containsKey(chave)) {
        pessoasUnificadas[chave] = pessoa;
        continue;
      }

      /// SE A PESSOA JÁ EXISTE, CRIA REGRAS RÍGIDAS DE SUBSTITUIÇÃO
      final existente = pessoasUnificadas[chave]!;

      // Verifica se o registro existente possui um horário preenchido de verdade
      final bool existenteTemHora = existente.horaEntrada != null && 
                                    existente.horaEntrada!.trim().isNotEmpty && 
                                    existente.horaEntrada!.trim() != '--:--';

      // Verifica se o registro atual possui um horário preenchido de verdade
      final bool pessoaTemHora = pessoa.horaEntrada != null && 
                                 pessoa.horaEntrada!.trim().isNotEmpty && 
                                 pessoa.horaEntrada!.trim() != '--:--';

      String? horaFinal;
      bool preCadastroFinal;

      if (pessoaTemHora && !existenteTemHora) {
        // CENÁRIO A: O dado novo veio da planilha de check-in real da portaria, 
        // e o dado antigo veio da planilha unificada quebrada. 
        // PRIORIDADE ABSOLUTA PARA O DADO NOVO.
        horaFinal = pessoa.horaEntrada;
        preCadastroFinal = pessoa.preCadastro; 
      } 
      else if (existenteTemHora && !pessoaTemHora) {
        // CENÁRIO B: O dado que já estava no mapa veio da planilha real, 
        // e o dado novo veio da planilha unificada quebrada.
        // MANTÉM O DADO QUE JÁ ESTAVA NO MAPA.
        horaFinal = existente.horaEntrada;
        preCadastroFinal = existente.preCadastro;
      } 
      else if (pessoaTemHora && existenteTemHora) {
        // CENÁRIO C: Ambos têm horário válido. Mantém o primeiro e confia no pré-cadastro
        horaFinal = existente.horaEntrada;
        preCadastroFinal = existente.preCadastro;
      } 
      else {
        // CENÁRIO D: Nenhum dos dois tem horário (ambos são pré-cadastros puros)
        horaFinal = null;
        preCadastroFinal = existente.preCadastro && pessoa.preCadastro;
      }

      pessoasUnificadas[chave] = Pessoa(
        nome: existenteTemHora ? existente.nome : pessoa.nome, // Preserva a grafia de quem tem o dado real
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