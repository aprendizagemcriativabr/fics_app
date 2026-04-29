import 'dart:io';
import 'package:excel/excel.dart';
import 'package:fics_app_new/domain/entities/pessoa.dart';

class ImportService {
  Future<List<Pessoa>> lerPlanilha(File file) async {
    var bytes = file.readAsBytesSync();
    var excel = Excel.decodeBytes(bytes);
    List<Pessoa> novosCadastros = [];

    // Assume que os dados estão na primeira aba (Sheet1)
    for (var table in excel.tables.keys) {
      var sheet = excel.tables[table];
      if (sheet == null) continue;

      // Pula a primeira linha (cabeçalho: Nome | Acompanhantes)
      for (int i = 1; i < sheet.maxRows; i++) {
        var row = sheet.rows[i];
        if (row[0] != null) {
          novosCadastros.add(Pessoa(
            nome: row[0]?.value.toString() ?? "",
            acompanhantes: int.tryParse(row[1]?.value.toString() ?? "0") ?? 0,
            confirmado: false,
          ));
        }
      }
    }
    return novosCadastros;
  }
}