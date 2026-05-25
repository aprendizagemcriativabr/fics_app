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

      // 1. MAPEIA DINAMICAMENTE OS ÍNDICES ATRAVÉS DO CABEÇALHO (Linha 0)
      final cabecalho = linhas[0].map((c) => c.toString().toLowerCase().trim()).toList();
      
      final int idxNome = cabecalho.indexWhere((c) => c == 'nome');
      
      final int idxAcompanhantes = cabecalho.indexWhere(
        (c) => c == 'acompanhantes' || c == 'qte. acompanhantes'
      );
      
      final int idxHora = cabecalho.indexWhere(
        (c) => c == 'hora entrada' || c == 'horario checkin' || c == 'horário checkin'
      );
      
      final int idxPre = cabecalho.indexWhere(
        (c) => c == 'pré cadastro' || c == 'pre cadastro'
      );

      // Se não achar a coluna principal (Nome), não dá para continuar
      if (idxNome == -1) return novosCadastros;

      // 2. CONSOME OS DADOS (Começa em i = 1 para pular o cabeçalho)
      for (int i = 1; i < linhas.length; i++) {
        var row = linhas[i];
        
        if (row.isNotEmpty && row.length > idxNome && row[idxNome] != null) {
          final nome = row[idxNome].toString().trim();
          
          // Ignora linhas vazias ou a linha de TOTAL GERAL da planilha unificada
          if (nome.isEmpty || nome.toUpperCase() == 'TOTAL GERAL') continue;

          // Captura Acompanhantes
          int acompanhantes = 0;
          if (idxAcompanhantes != -1 && idxAcompanhantes < row.length && row[idxAcompanhantes] != null) {
            acompanhantes = int.tryParse(row[idxAcompanhantes].toString().trim()) ?? 0;
          }

          // Captura Hora de Entrada
          String? horaEntrada;
          if (idxHora != -1 && idxHora < row.length && row[idxHora] != null) {
            final valorHora = row[idxHora].toString().trim();
            if (valorHora.isNotEmpty && valorHora != '--:--') {
              horaEntrada = valorHora;
            }
          }

          // Captura Pré-Cadastro de forma correta (Tratando o "Sim"/"Não")
          bool preCadastro = false;
          if (idxPre != -1 && idxPre < row.length && row[idxPre] != null) {
            final valorPre = row[idxPre].toString().toLowerCase().trim();
            if (valorPre == 'sim' || valorPre == 'true') {
              preCadastro = true;
            }
          }

          novosCadastros.add(Pessoa(
            nome: nome,
            acompanhantes: acompanhantes,
            confirmado: horaEntrada != null, // Se tem horário válido, está confirmado
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