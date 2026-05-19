import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:fics_app_new/domain/entities/pessoa.dart';

class ImportCsvService {
  Future<List<Pessoa>> lerPlanilha(File file) async {
    try {
      // 1. Lê o conteúdo do arquivo como texto puro
      final conteudoTexto = await file.readAsString(encoding: utf8);
 
      // 2. DETECÇÃO AUTOMÁTICA DE SEPARADOR:
      // Identifica dinamicamente se o arquivo usa vírgula (,) ou ponto e vírgula (;)
      String separador = ';';
      if (!conteudoTexto.contains(';') && conteudoTexto.contains(',')) {
        separador = ',';
      }

      List<List<dynamic>> linhas = CsvToListConverter(fieldDelimiter: separador).convert(conteudoTexto);
      
      List<Pessoa> novosCadastros = [];
      if (linhas.isEmpty) return novosCadastros;

      // CORREÇÃO: i = 0 porque a sua planilha NÃO POSSUI linha de cabeçalho.
      for (int i = 0; i < linhas.length; i++) {
        var row = linhas[i];
        
        // Valida se a linha não está em branco
        if (row.isNotEmpty && row[0] != null && row[0].toString().trim().isNotEmpty) {
          
          final nome = row[0].toString().trim();
          int acompanhantes = 0;

          // Garante que a coluna de acompanhantes existe na linha antes de tentar lê-la
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