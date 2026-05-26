import 'dart:io';
import 'package:excel/excel.dart';
import 'package:fics_app_new/domain/entities/pessoa.dart';

class ImportExcelService {
  Future<List<Pessoa>> lerPlanilha(File file) async {
    final bytes = file.readAsBytesSync();
    final excel = Excel.decodeBytes(bytes);
    final List<Pessoa> novosCadastros = [];

    for (final table in excel.tables.keys) {
      final sheet = excel.tables[table];
      if (sheet == null) continue;

      if (sheet.maxRows <= 1) continue; 

      // 1. TENTA MAPEAR DINAMICAMENTE (Super Flexível)
      final linhaCabecalho = sheet.rows[0];
      final cabecalho = linhaCabecalho.map((c) => c?.value?.toString().toLowerCase().trim() ?? '').toList();

      // Procura por pedaços de palavras em vez do texto exato
      int idxNome = cabecalho.indexWhere((c) => c.contains('nome') || c.contains('convidado') || c.contains('participante'));
      int idxAcompanhantes = cabecalho.indexWhere((c) => c.contains('acompanhante') || c.contains('qte') || c.contains('qtd') || c.contains('quantidade'));
      int idxHora = cabecalho.indexWhere((c) => c.contains('hora') || c.contains('check'));
      int idxPre = cabecalho.indexWhere((c) => c.contains('pre') || c.contains('pré'));

      // PLANO B (Fallback): Se não achou NENHUM cabeçalho claro, usamos a regra básica antiga.
      // Assumimos que Coluna 0 = Nome, Coluna 1 = Acompanhantes.
      if (idxNome == -1) {
        idxNome = 0;
        idxAcompanhantes = 1;
        idxHora = 2; // Pode nem existir na planilha inicial, o código abaixo protege contra erros
        idxPre = 3;  // Pode nem existir
      }

      // 2. LÊ OS DADOS DE FATO
      for (int i = 1; i < sheet.maxRows; i++) {
        final row = sheet.rows[i];

        // Proteção: Se a linha for vazia ou menor que a coluna de nome, pula.
        if (row.isEmpty || idxNome >= row.length || row[idxNome]?.value == null) {
          continue;
        }

        final nome = row[idxNome]!.value.toString().trim();
        if (nome.isEmpty || nome.toUpperCase() == 'TOTAL GERAL') continue;

        // Captura Acompanhantes (se a coluna existir nesta linha)
        int acompanhantes = 0;
        if (idxAcompanhantes != -1 && idxAcompanhantes < row.length && row[idxAcompanhantes]?.value != null) {
          acompanhantes = int.tryParse(row[idxAcompanhantes]!.value.toString().trim()) ?? 0;
        }

        // Captura Hora de Entrada (se a coluna existir nesta linha)
        String? horaEntrada;
        if (idxHora != -1 && idxHora < row.length && row[idxHora]?.value != null) {
          final valorHora = row[idxHora]!.value.toString().trim();
          if (valorHora.isNotEmpty && valorHora != '--:--') {
            horaEntrada = valorHora;
          }
        }

        // Captura Pré-Cadastro 
        // Se a coluna não existir (ex: planilha inicial), o padrão é TRUE, pois é uma lista pré-cadastrada.
        bool preCadastro = true;
        if (idxPre != -1 && idxPre < row.length && row[idxPre]?.value != null) {
          final valorPre = row[idxPre]!.value.toString().toLowerCase().trim();
          if (valorPre == 'não' || valorPre == 'nao' || valorPre == 'false') {
            preCadastro = false;
          }
        }

        novosCadastros.add(
          Pessoa(
            nome: nome,
            acompanhantes: acompanhantes,
            confirmado: horaEntrada != null, // Se tem horário válido, já está confirmado na portaria
            horaEntrada: horaEntrada,
            preCadastro: preCadastro,
          ),
        );
      }
    }

    return novosCadastros;
  }
}