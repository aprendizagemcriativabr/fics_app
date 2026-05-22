import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:fics_app_new/domain/entities/pessoa.dart';

class ImportCsvService {
  Future<List<Pessoa>> lerPlanilha(File file) async {
    try {
      final conteudoTexto = await file.readAsString(encoding: utf8);
 
      String separador = ';';
      if (!conteudoTexto.contains(';') && conteudoTexto.contains(',')) {
        separador = ',';
      }

      List<List<dynamic>> linhas = CsvToListConverter(fieldDelimiter: separador).convert(conteudoTexto);
      
      List<Pessoa> novosCadastros = [];
      if (linhas.isEmpty) return novosCadastros;

      for (int i = 0; i < linhas.length; i++) {
        var row = linhas[i];
        
        if (row.isNotEmpty && row[0] != null && row[0].toString().trim().isNotEmpty) {
          
          final nome = row[0].toString().trim();
          int acompanhantes = 0;

          if (row.length > 1 && row[1] != null) {
            acompanhantes = int.tryParse(row[1].toString().trim()) ?? 0;
          }

          novosCadastros.add(Pessoa(
            nome: nome,
            acompanhantes: acompanhantes,
            confirmado: false,
          ));
        }
      }
      return novosCadastros;
    } catch (e) {
      throw Exception("Erro ao ler o arquivo CSV: $e");
    }
  }
}