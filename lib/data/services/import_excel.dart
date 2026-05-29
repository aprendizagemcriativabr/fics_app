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

      final linhaCabecalho = sheet.rows[0];
      final cabecalho = linhaCabecalho
          .map((c) => c?.value?.toString().toLowerCase().trim() ?? '')
          .toList();

      int idxNome = cabecalho.indexWhere((c) =>
          c.contains('nome') ||
          c.contains('convidado') ||
          c.contains('participante'));

      int idxAcompanhantes = cabecalho.indexWhere((c) =>
          c.contains('acompanhante') ||
          c.contains('qte') ||
          c.contains('qtd') ||
          c.contains('quantidade'));

      int idxHora = cabecalho.indexWhere((c) =>
          (c.contains('hora') ||
              c.contains('entrada') ||
              c.contains('check')) &&
          !c.contains('carimbo'));

      int idxPre =
          cabecalho.indexWhere((c) => c.contains('pre') || c.contains('pré'));

      if (idxNome == -1) idxNome = 0;
      if (idxAcompanhantes == -1) idxAcompanhantes = 1;
      if (idxHora == -1) idxHora = 2;
      if (idxPre == -1) idxPre = 3;

      for (int i = 1; i < sheet.maxRows; i++) {
        final row = sheet.rows[i];

        if (row.isEmpty ||
            idxNome >= row.length ||
            row[idxNome]?.value == null) {
          continue;
        }

        final nome = row[idxNome]!.value.toString().trim();
        if (nome.isEmpty || nome.toUpperCase() == 'TOTAL GERAL') continue;

        int acompanhantes = 0;
        if (idxAcompanhantes != -1 &&
            idxAcompanhantes < row.length &&
            row[idxAcompanhantes]?.value != null) {
          acompanhantes =
              int.tryParse(row[idxAcompanhantes]!.value.toString().trim()) ?? 0;
        }

        String? horaEntrada;
        if (idxHora != -1 &&
            idxHora < row.length &&
            row[idxHora]?.value != null) {
          horaEntrada = _parseHoraEntrada(row[idxHora]!.value.toString());
        }

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
            confirmado: horaEntrada != null,
            horaEntrada: horaEntrada,
            preCadastro: preCadastro,
          ),
        );
      }
    }

    return novosCadastros;
  }
}

String? _parseHoraEntrada(String raw) {
  final value = raw.trim();
  if (value.isEmpty || value == '--:--') return null;

  final match = RegExp(r'(\d{1,2}):(\d{2})').firstMatch(value);
  if (match == null) return null;

  final hh = int.tryParse(match.group(1)!) ?? -1;
  final mm = int.tryParse(match.group(2)!) ?? -1;
  if (hh < 0 || hh > 23 || mm < 0 || mm > 59) return null;

  return '${hh.toString().padLeft(2, '0')}:${mm.toString().padLeft(2, '0')}';
}
