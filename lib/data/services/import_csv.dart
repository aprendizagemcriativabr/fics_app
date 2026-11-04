import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:fics_app_new/domain/entities/pessoa.dart';

class ImportCsvService {
  Future<List<Pessoa>> lerPlanilha(File file) async {
    try {
      final bytes = await file.readAsBytes();

      // Try UTF-8 first; fall back to Latin-1 (CSVs saved by older Excel).
      String content;
      try {
        content = utf8.decode(bytes);
      } on FormatException {
        content = latin1.decode(bytes);
      }

      content = content
          .replaceAll('\ufeff', '')
          .replaceAll('\r\n', '\n')
          .replaceAll('\r', '\n');

      // Detect the delimiter from the header line only, ignoring quoted text.
      // (Looking at the whole file breaks Google Forms exports, because answers
      // like "Turno da Manhã;Turno da Tarde" contain ';' inside quoted fields.)
      final delimiter = _detectDelimiter(content);

      final rows = CsvToListConverter(
        fieldDelimiter: delimiter,
        eol: '\n',
        shouldParseNumbers: false,
      ).convert(content);

      final result = <Pessoa>[];
      if (rows.isEmpty) return result;

      final header = rows[0]
          .map((c) => c.toString().toLowerCase().replaceAll('\ufeff', '').trim())
          .toList();

      final int nameIdx = header.indexWhere((c) =>
          c.contains('nome') ||
          c.contains('convidado') ||
          c.contains('participante'));

      final int companionsIdx = header.indexWhere((c) =>
          c.contains('acompanhante') ||
          c.contains('qte') ||
          c.contains('qtd') ||
          c.contains('quantidade'));

      final int timeIdx = header.indexWhere((c) =>
          (c.contains('entrada') || c.contains('check')) &&
          !c.contains('carimbo'));

      final int preRegIdx = header
          .indexWhere((c) => c == 'pré cadastro' || c == 'pre cadastro');

      // School / institution column (Google Forms export). Skips the
      // "localidade da instituição" column, which also contains the word.
      final int schoolIdx = header.indexWhere((c) =>
          (c.contains('instituição') || c.contains('instituicao')) &&
          !c.contains('localidade'));

      if (nameIdx == -1) return result;

      for (int i = 1; i < rows.length; i++) {
        final row = rows[i];

        if (row.length <= nameIdx) continue;

        var name = _clean(row[nameIdx].toString());
        if (name.isEmpty || name.toUpperCase() == 'TOTAL GERAL') continue;

        // Append the school as "Name (School)" unless the name already has one.
        if (schoolIdx != -1 && schoolIdx < row.length) {
          final school = _clean(row[schoolIdx].toString());
          if (school.isNotEmpty && !name.contains('(')) {
            name = '$name ($school)';
          }
        }

        int companions = 0;
        if (companionsIdx != -1 && companionsIdx < row.length) {
          companions = _parseCompanions(row[companionsIdx].toString());
        }

        String? entryTime;
        if (timeIdx != -1 && timeIdx < row.length) {
          entryTime = _parseEntryTime(row[timeIdx].toString());
        }

        bool preRegistered = false;
        if (preRegIdx != -1) {
          if (preRegIdx < row.length) {
            final value = row[preRegIdx].toString().toLowerCase().trim();
            preRegistered = value == 'sim' || value == 'true';
          }
        } else {
          preRegistered = true;
        }

        result.add(Pessoa(
          nome: name,
          acompanhantes: companions,
          confirmado: entryTime != null,
          horaEntrada: entryTime,
          preCadastro: preRegistered,
        ));
      }

      return result;
    } catch (e) {
      throw Exception("Erro ao ler o arquivo CSV: $e");
    }
  }
}

/// Trims and collapses repeated whitespace ("Florisbal  Aires " -> "Florisbal Aires").
String _clean(String raw) => raw.replaceAll(RegExp(r'\s+'), ' ').trim();

/// Picks the delimiter that appears most in the header line (outside quotes).
String _detectDelimiter(String content) {
  const candidates = [',', ';', '\t'];
  final counts = {for (final c in candidates) c: 0};
  var inQuotes = false;

  for (var i = 0; i < content.length; i++) {
    final ch = content[i];
    if (ch == '"') {
      inQuotes = !inQuotes;
      continue;
    }
    if (inQuotes) continue;
    if (ch == '\n') break;
    if (counts.containsKey(ch)) counts[ch] = counts[ch]! + 1;
  }

  var best = ',';
  var bestCount = 0;
  counts.forEach((delimiter, count) {
    if (count > bestCount) {
      best = delimiter;
      bestCount = count;
    }
  });
  return best;
}

/// Free-text answers ("Sim. 14 pessoas", "25", "Não", "-") -> first number, or 0.
int _parseCompanions(String raw) {
  final match = RegExp(r'\d+').firstMatch(raw);
  if (match == null) return 0;
  return int.tryParse(match.group(0)!) ?? 0;
}

String? _parseEntryTime(String raw) {
  final value = raw.trim();
  if (value.isEmpty || value == '--:--') return null;

  final match = RegExp(r'^(\d{1,2}):(\d{2})(?::(\d{2}))?$').firstMatch(value);
  if (match == null) return null;

  final hh = int.tryParse(match.group(1)!) ?? -1;
  final mm = int.tryParse(match.group(2)!) ?? -1;
  if (hh < 0 || hh > 23 || mm < 0 || mm > 59) return null;

  return '${hh.toString().padLeft(2, '0')}:${mm.toString().padLeft(2, '0')}';
}