import 'dart:io';
import 'package:fics_app_new/domain/entities/pessoa.dart';
import 'import_excel.dart';
import 'import_csv.dart';

class ImportService {
  final ImportExcelService _excelService = ImportExcelService();
  final ImportCsvService _csvService = ImportCsvService();

  Future<List<Pessoa>> lerPlanilha(File file) async {
    final caminho = file.path.toLowerCase();

    if (caminho.endsWith('.csv')) {
      return await _csvService.lerPlanilha(file);
    } else {
      return await _excelService.lerPlanilha(file);
    }
  }
}