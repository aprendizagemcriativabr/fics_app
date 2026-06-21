import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:fics_app_new/domain/entities/pessoa.dart';

class ImportCsvService {
  Future<List<Pessoa>> lerPlanilha(File file) async {
    try {
      var conteudoTexto = await file.readAsString(encoding: utf8);

      conteudoTexto =
          conteudoTexto.replaceAll('\r\n', '\n').replaceAll('\r', '\n');

      String separador = ';';
      if (!conteudoTexto.contains(';') && conteudoTexto.contains(',')) {
        separador = ',';
      }

      List<List<dynamic>> linhas = CsvToListConverter(
        fieldDelimiter: separador,
        eol: '\n',
      ).convert(conteudoTexto);

      List<Pessoa> novosCadastros = [];
      if (linhas.isEmpty) return novosCadastros;

      final cabecalho = linhas[0]
          .map(
              (c) => c.toString().toLowerCase().replaceAll('\ufeff', '').trim())
          .toList();

      final int idxNome =
          cabecalho.indexWhere((c) => c == 'nome' || c.contains('nome'));

      final int idxAcompanhantes = cabecalho.indexWhere((c) =>
          c.contains('acompanhante') ||
          c.contains('qte') ||
          c.contains('qtd') ||
          c.contains('quantidade'));

      final int idxHora = cabecalho.indexWhere((c) =>
          (c.contains('entrada') || c.contains('check')) &&
          !c.contains('carimbo'));

      final int idxPre = cabecalho
          .indexWhere((c) => c == 'pré cadastro' || c == 'pre cadastro');

      if (idxNome == -1) return novosCadastros;

      for (int i = 1; i < linhas.length; i++) {
        var row = linhas[i];

        if (row.isNotEmpty && row.length > idxNome && row[idxNome] != null) {
          final nome = row[idxNome].toString().trim();

          if (nome.isEmpty || nome.toUpperCase() == 'TOTAL GERAL') continue;

          int acompanhantes = 0;
          if (idxAcompanhantes != -1 &&
              idxAcompanhantes < row.length &&
              row[idxAcompanhantes] != null) {
            acompanhantes =
                int.tryParse(row[idxAcompanhantes].toString().trim()) ?? 0;
          }

          String? horaEntrada;
          if (idxHora != -1 && idxHora < row.length && row[idxHora] != null) {
            horaEntrada = _parseHoraEntrada(row[idxHora].toString());
          }

          bool preCadastro = false;
          if (idxPre != -1) {
            if (idxPre < row.length && row[idxPre] != null) {
              final valorPre = row[idxPre].toString().toLowerCase().trim();
              if (valorPre == 'sim' || valorPre == 'true') {
                preCadastro = true;
              }
            }
          } else {
            preCadastro = true;
          }

          novosCadastros.add(Pessoa(
            nome: nome,
            acompanhantes: acompanhantes,
            confirmado: horaEntrada != null,
            horaEntrada: horaEntrada,
            preCadastro: preCadastro,
          ));
        }
      }
      return novosCadastros;
    } catch (e) {
      throw Exception("Erro ao ler o arquivo CSV: $e");
    }
  }
}

String? _parseHoraEntrada(String raw) {
  final value = raw.trim();
  if (value.isEmpty || value == '--:--') return null;

  final match = RegExp(r'^(\d{1,2}):(\d{2})(?::(\d{2}))?$').firstMatch(value);
  if (match == null) return null;

  final hh = int.tryParse(match.group(1)!) ?? -1;
  final mm = int.tryParse(match.group(2)!) ?? -1;
  if (hh < 0 || hh > 23 || mm < 0 || mm > 59) return null;

  return '${hh.toString().padLeft(2, '0')}:${mm.toString().padLeft(2, '0')}';
}
