import 'dart:io';

import 'package:excel/excel.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fics_app_new/data/services/import_csv.dart';
import 'package:fics_app_new/data/services/import_excel.dart';

void main() {
  group('Import services -', () {
    test('Excel: coluna Carimbo de data/hora do Forms não vira check-in',
        () async {
      final excel = Excel.createExcel();
      final sheet = excel['Sheet1'];

      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0))
          .value = TextCellValue('Carimbo de data/hora');
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 0))
          .value = TextCellValue('Nome');
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: 0))
          .value = TextCellValue('Quantidade de acompanhantes');

      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 1))
          .value = TextCellValue('27/05/2026 16:24:03');
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 1))
          .value = TextCellValue('Maria');
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: 1))
          .value = IntCellValue(2);

      final bytes = excel.save();
      expect(bytes, isNotNull);

      final dir = await Directory.systemTemp.createTemp('fics_app_test_');
      final file = File('${dir.path}/forms.xlsx');
      await file.writeAsBytes(bytes!, flush: true);

      final service = ImportExcelService();
      final pessoas = await service.lerPlanilha(file);

      expect(pessoas, hasLength(1));
      expect(pessoas.single.nome, 'Maria');
      expect(pessoas.single.acompanhantes, 2);
      expect(pessoas.single.preCadastro, true);
      expect(pessoas.single.horaEntrada, isNull);
      expect(pessoas.single.confirmado, false);
    });

    test('Excel: Hora Entrada HH:mm:ss vira check-in (normaliza para HH:mm)',
        () async {
      final excel = Excel.createExcel();
      final sheet = excel['Sheet1'];

      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0))
          .value = TextCellValue('Nome');
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 0))
          .value = TextCellValue('Acompanhantes');
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: 0))
          .value = TextCellValue('Hora Entrada');

      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 1))
          .value = TextCellValue('João');
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 1))
          .value = IntCellValue(0);
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: 1))
          .value = TextCellValue('16:24:03');

      final bytes = excel.save();
      expect(bytes, isNotNull);

      final dir = await Directory.systemTemp.createTemp('fics_app_test_');
      final file = File('${dir.path}/checkin.xlsx');
      await file.writeAsBytes(bytes!, flush: true);

      final service = ImportExcelService();
      final pessoas = await service.lerPlanilha(file);

      expect(pessoas, hasLength(1));
      expect(pessoas.single.horaEntrada, '16:24');
      expect(pessoas.single.confirmado, true);
    });

    test('CSV: data/hora (dd/MM/yyyy HH:mm:ss) não vira check-in', () async {
      final dir = await Directory.systemTemp.createTemp('fics_app_test_');
      final file = File('${dir.path}/forms.csv');

      await file.writeAsString(
        'nome;acompanhantes;hora entrada\n'
        'Ana;1;27/05/2026 16:24:03\n',
        flush: true,
      );

      final service = ImportCsvService();
      final pessoas = await service.lerPlanilha(file);

      expect(pessoas, hasLength(1));
      expect(pessoas.single.nome, 'Ana');
      expect(pessoas.single.horaEntrada, isNull);
      expect(pessoas.single.confirmado, false);
    });
  });
}
