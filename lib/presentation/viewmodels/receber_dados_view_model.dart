import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../domain/entities/pessoa.dart';
import '../../data/services/import_service.dart';
import '../viewmodels/pessoa_view_model.dart';

class ReceberDadosViewModel extends ChangeNotifier {
  final ImportService _importService;
  bool get canSubmit => fileName != null && !isProcessing;

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
      allowedExtensions: ['xlsx', 'csv'],
    );

    if (result != null && result.files.single.path != null) {
      _selectedFile = File(result.files.single.path!);
      notifyListeners();
    }
  }

  void setFileForTest(File file) {
    _selectedFile = file;
    notifyListeners();
  }

  Future<void> executarImportacao({
    required PessoaViewModel listaVM,
    required FutureOr<void> Function() onSuccess,
    required FutureOr<void> Function(String) onError,
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
      await Future.sync(onSuccess); // Dispara o callback de sucesso
    } catch (e) {
      _isProcessing = false;
      notifyListeners();
      await Future.sync(
          () => onError(e.toString())); // Dispara o callback de erro
    }
  }
}
