import 'dart:io';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';

class ExportService {
  /// Gera um arquivo Excel genérico a partir de cabeçalhos e linhas de dados.
  Future<bool> gerarPlanilha({
    required String nomeAba,
    required String nomeArquivoPadrao,
    required List<String> cabecalhos,
    required List<List<dynamic>> linhasDados,
    List<dynamic>? linhaTotal, 
  }) async {
    var excel = Excel.createExcel();
    excel.rename('Sheet1', nomeAba);
    Sheet aba = excel[nomeAba];

    // Estilo base (Apenas Negrito para evitar bugs de Hexadecimal)
    CellStyle estiloDestaque = CellStyle(
      bold: true,
      fontFamily: getFontFamily(FontFamily.Arial),
    );

    // 1. Escreve os Cabeçalhos 
    aba.appendRow(cabecalhos.map((c) => TextCellValue(c)).toList());
    
    // CORREÇÃO: Aplica estilo no cabeçalho acessando diretamente por coordenadas
    // Em vez de varrer aba.rows[0], pegamos a quantidade de colunas do cabeçalho
    for (int col = 0; col < cabecalhos.length; col++) {
      // row: 0 é a primeira linha. colIndex: col mapeia as colunas 0, 1, 2...
      var cell = aba.cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: 0));
      cell.cellStyle = estiloDestaque;
    }

    // 2. Escreve as Linhas de Dados convertendo para os tipos corretos da v4.0.0
    for (var linha in linhasDados) {
      aba.appendRow(linha.map((valor) => _converterParaCellValue(valor)).toList());
    }

    // 3. Escreve a Linha de Total
    if (linhaTotal != null) {
      aba.appendRow(linhaTotal.map((valor) => _converterParaCellValue(valor)).toList());
      
      // CORREÇÃO: Aplica o estilo negrito na última linha de forma ultra segura
      int indiceUltimaLinha = aba.maxRows - 1;
      for (int col = 0; col < linhaTotal.length; col++) {
        var cell = aba.cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: indiceUltimaLinha));
        cell.cellStyle = estiloDestaque;
      }
    }

    // 4. Transforma em bytes
    List<int>? fileBytes = excel.save();
    if (fileBytes == null) throw Exception("Erro ao gerar os bytes do arquivo Excel.");

    // 5. Abre a janela de "Salvar Como"
    String? caminhoSelecionado = await FilePicker.platform.saveFile(
      dialogTitle: 'Salvar Planilha',
      fileName: nomeArquivoPadrao,
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
    );

    if (caminhoSelecionado == null) return false;

    // 6. Grava o arquivo físico
    final arquivoFinal = File(caminhoSelecionado);
    await arquivoFinal.writeAsBytes(fileBytes);
    return true;
  }

  /// Converte dinamicamente os tipos do Flutter para os tipos exigidos pelo Excel 4.0.0
  CellValue _converterParaCellValue(dynamic valor) {
    if (valor == null) return TextCellValue("");
    if (valor is int) return IntCellValue(valor);
    if (valor is double) return DoubleCellValue(valor);
    if (valor is bool) return BoolCellValue(valor);
    
    return TextCellValue(valor.toString());
  }
}