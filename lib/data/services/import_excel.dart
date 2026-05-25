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

      for (int i = 1; i < sheet.maxRows; i++) {
        final row = sheet.rows[i];

        /// IGNORA LINHAS VAZIAS
        if (row.isEmpty || row[0]?.value == null) {
          continue;
        }

        final nome =
            row[0]?.value.toString().trim() ?? "";

        final acompanhantes =
            int.tryParse(
                  row.length > 1
                      ? row[1]?.value.toString() ?? "0"
                      : "0",
                ) ??
                0;

        novosCadastros.add(
          Pessoa(
            nome: nome,
            acompanhantes: acompanhantes,
            confirmado: false,
            horaEntrada: null,
            preCadastro: true,
          ),
        );
      }
    }

    return novosCadastros;
  }
}