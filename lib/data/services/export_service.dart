import 'dart:io';
import 'dart:typed_data';

import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';

class ExportService {
  Future<bool> gerarPlanilha({
    required String nomeAba,
    required String nomeArquivoPadrao,
    required List<String> cabecalhos,
    required List<List<dynamic>> linhasDados,
    List<dynamic>? linhaTotal,
  }) async {
    /// CRIA EXCEL
    final Excel excel = Excel.createExcel();

    excel.rename('Sheet1', nomeAba);

    final Sheet aba = excel[nomeAba];

    /// ESTILO
    final CellStyle estiloDestaque = CellStyle(
      bold: true,
      fontFamily: getFontFamily(FontFamily.Arial),
    );

    /// CABEÇALHOS
    aba.appendRow(
      cabecalhos
          .map((c) => TextCellValue(c))
          .toList(),
    );

    /// ESTILIZA CABEÇALHO
    for (int col = 0; col < cabecalhos.length; col++) {
      final cell = aba.cell(
        CellIndex.indexByColumnRow(
          columnIndex: col,
          rowIndex: 0,
        ),
      );

      cell.cellStyle = estiloDestaque;
    }

    /// DADOS
    for (final linha in linhasDados) {
      aba.appendRow(
        linha
            .map(_converterParaCellValue)
            .toList(),
      );
    }

    /// TOTAL
    if (linhaTotal != null) {
      aba.appendRow(
        linhaTotal
            .map(_converterParaCellValue)
            .toList(),
      );

      final int ultimaLinha =
          aba.maxRows - 1;

      for (int col = 0;
          col < linhaTotal.length;
          col++) {
        final cell = aba.cell(
          CellIndex.indexByColumnRow(
            columnIndex: col,
            rowIndex: ultimaLinha,
          ),
        );

        cell.cellStyle =
            estiloDestaque;
      }
    }

    /// GERA BYTES
    final Uint8List fileBytes =
        Uint8List.fromList(
      excel.save()!,
    );

    /// SAVE FILE
    final String? caminhoSelecionado =
        await FilePicker.platform.saveFile(
      dialogTitle: 'Salvar Planilha',
      fileName: nomeArquivoPadrao,

      /// IMPORTANTE PARA ANDROID/iOS
      bytes: fileBytes,

      type: FileType.custom,
      allowedExtensions: ['xlsx'],
    );

    /// USUÁRIO CANCELou
    if (caminhoSelecionado == null) {
      return false;
    }

    /// SALVA NO DISCO
    final arquivoFinal =
        File(caminhoSelecionado);

    await arquivoFinal.writeAsBytes(
      fileBytes,
      flush: true,
    );

    return true;
  }

  /// CONVERSOR DE TIPOS
  CellValue _converterParaCellValue(
    dynamic valor,
  ) {
    if (valor == null) {
      return TextCellValue("");
    }

    if (valor is int) {
      return IntCellValue(valor);
    }

    if (valor is double) {
      return DoubleCellValue(valor);
    }

    if (valor is bool) {
      return BoolCellValue(valor);
    }

    return TextCellValue(
      valor.toString(),
    );
  }
}