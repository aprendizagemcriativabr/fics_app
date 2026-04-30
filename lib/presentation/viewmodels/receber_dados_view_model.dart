import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../domain/entities/pessoa.dart';
import '../../data/services/import_excel.dart';
import '../viewmodels/pessoa_view_model.dart';

class ReceberDadosViewModel extends ChangeNotifier {
  final ImportService _importService;

  ReceberDadosViewModel({ImportService? importService})
      : _importService = importService ?? ImportService();

  File? _selectedFile;
  bool _isProcessing = false;

  File? get selectedFile => _selectedFile;
  bool get isProcessing => _isProcessing;
  String? get fileName =>
      _selectedFile?.path.split(Platform.pathSeparator).last;

  Future<void> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
    );

    if (result != null && result.files.single.path != null) {
      _selectedFile = File(result.files.single.path!);
      notifyListeners();
    }
  }

  Future<void> executarImportacao({
    required PessoaViewModel listaVM,
    required VoidCallback onSuccess,
    required Function(String) onError,
  }) async {
    if (_selectedFile == null) return;

    _isProcessing = true;
    notifyListeners();

    try {
      List<Pessoa> novasPessoas =
          await _importService.lerPlanilha(_selectedFile!);
      if (novasPessoas.isEmpty) throw Exception("Planilha vazia");

      await listaVM.importarNovasPessoas(novasPessoas);

      _isProcessing = false;
      notifyListeners();
      onSuccess(); // Dispara o callback de sucesso
    } catch (e) {
      _isProcessing = false;
      notifyListeners();
      onError(e.toString()); // Dispara o callback de erro
    }
  }
}
