import 'dart:io';
import 'package:excel/excel.dart'; 
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../domain/entities/pessoa.dart';
import '../../domain/usecases/unificar_planilhas.dart';
import '../../data/services/share_service.dart';

class UnificarDadosViewModel extends ChangeNotifier {
  final UnificarPlanilhas _unificarPlanilhas;
  final ShareService _shareService;

  final List<File> _selectedFiles = [];
  bool _isProcessing = false;
  String? _ultimoArquivoGerado;

  UnificarDadosViewModel({
    required UnificarPlanilhas unificarPlanilhas,
    required ShareService shareService,
  })  : _unificarPlanilhas = unificarPlanilhas,
        _shareService = shareService;

  // --- GETTERS ---
  List<File> get selectedFiles => _selectedFiles;
  bool get isProcessing => _isProcessing;
  String? get ultimoArquivoGerado => _ultimoArquivoGerado;
  bool get canSubmit => _selectedFiles.isNotEmpty && !_isProcessing;

  /// SELECIONA PLANILHAS
  Future<void> pickMultipleFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'csv'],
      allowMultiple: true,
    );

    if (result != null) {
      for (final path in result.paths) {
        if (path != null) {
          final novoArquivo = File(path);
          final jaExiste = _selectedFiles.any((f) => f.path == novoArquivo.path);

          if (!jaExiste) {
            _selectedFiles.add(novoArquivo);
          }
        }
      }
      notifyListeners();
    }
  }

  /// REMOVE ARQUIVO
  void removerArquivo(File arquivo) {
    _selectedFiles.remove(arquivo);
    notifyListeners();
  }

  /// LIMPA LISTA
  void limparTudo() {
    _selectedFiles.clear();
    _ultimoArquivoGerado = null;
    notifyListeners();
  }

  /// EXECUTA UNIFICAÇÃO E COMPARTILHA AUTOMATICAMENTE
  Future<void> executarUnificacaoEExportar({
    required VoidCallback onSuccess,
    required Function(String) onError,
  }) async {
    if (_selectedFiles.isEmpty) return;

    _isProcessing = true;
    _ultimoArquivoGerado = null; 
    notifyListeners();

    try {
      /// PERMISSÕES
      if (Platform.isAndroid) {
        final status = await Permission.manageExternalStorage.request();
        if (!status.isGranted) {
          throw Exception("Permissão de armazenamento negada.");
        }
      }

      /// UNIFICA TODAS AS PLANILHAS VIA USECASE
      final List<Pessoa> pessoasUnificadas = await _unificarPlanilhas(_selectedFiles);

      if (pessoasUnificadas.isEmpty) {
        throw Exception("Nenhum dado encontrado nas planilhas selecionadas.");
      }

      /// ORDENA
      pessoasUnificadas.sort((a, b) => a.nome.compareTo(b.nome));

      /// CRIA EXCEL NATIVO
      final excel = Excel.createExcel();
      final sheet = excel['Sheet1'];

      /// CABEÇALHO
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: 0)).value = TextCellValue('Nome');
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: 0)).value = TextCellValue('Qte. Acompanhantes');
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: 0)).value = TextCellValue('Horario CheckIn');
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: 0)).value = TextCellValue('Pré Cadastro');

      /// INSERE DADOS DAS PESSOAS UNIFICADAS
      int totalPessoas = 0;
      for (int i = 0; i < pessoasUnificadas.length; i++) {
        final p = pessoasUnificadas[i];
        final row = i + 1;

        totalPessoas += p.acompanhantes + 1;

        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row)).value = TextCellValue(p.nome);
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row)).value = IntCellValue(p.acompanhantes);
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row)).value = TextCellValue(p.horaEntrada ?? '--:--');
        sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: row)).value = TextCellValue(p.preCadastro ? 'Sim' : 'Não');
      }

      /// LINHA TOTAL GERAL NO FINAL
      final linhaTotalRow = pessoasUnificadas.length + 1;
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: linhaTotalRow)).value = TextCellValue('TOTAL GERAL');
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: linhaTotalRow)).value = IntCellValue(totalPessoas);
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: linhaTotalRow)).value = TextCellValue('');
      sheet.cell(CellIndex.indexByColumnRow(columnIndex: 3, rowIndex: linhaTotalRow)).value = TextCellValue('');

      /// DIRETÓRIO PARA SALVAMENTO
      Directory? directory;
      if (Platform.isAndroid) {
        directory = Directory('/storage/emulated/0/Download');
        if (!await directory.exists()) {
          await directory.create(recursive: true);
        }
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      /// NOME DO ARQUIVO
      final dataAtual = DateTime.now().toString().split(' ')[0];
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final path = '${directory.path}/planilha_unificada_checkins_${dataAtual}_$timestamp.xlsx';

      debugPrint("CAMINHO SALVAMENTO UNIFICADO: $path");

      /// GERA E SALVA OS BYTES NO DISCO
      final fileBytes = excel.save();
      if (fileBytes == null) {
        throw Exception("Erro ao gerar a estrutura do Excel.");
      }

      final file = File(path);
      await file.create(recursive: true);
      await file.writeAsBytes(fileBytes, flush: true);

      /// FORÇA O ANDROID A INDEXAR O ARQUIVO
      if (Platform.isAndroid) {
        try {
          await Process.run(
            'am',
            [
              'broadcast',
              '-a',
              'android.intent.action.MEDIA_SCANNER_SCAN_FILE',
              '-d',
              'file://${file.path}',
            ],
          );
        } catch (e) {
          debugPrint("Erro ao atualizar mídia: $e");
        }
      }

      _ultimoArquivoGerado = file.path;
      debugPrint("PLANILHA UNIFICADA SALVA COM SUCESSO: ${file.path}");

      /// ABRE A DIÁLOGO DE COMPARTILHAMENTO DO SISTEMA OPERACIONAL
      await _shareService.compartilharArquivoLocal(
        caminhoArquivoOriginal: _ultimoArquivoGerado!,
      );
      
      // Limpa os arquivos da lista apenas se o fluxo acima concluir com sucesso
      _selectedFiles.clear();
      onSuccess();
    } catch (e) {
      debugPrint("ERRO EXPORTAÇÃO UNIFICADA: $e");
      onError(e.toString().replaceAll("Exception: ", ""));
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  /// COMPARTILHA VIA SERVIÇO UNIFICADO (MANUAL VIA ICONBUTTON)
  Future<void> compartilharPlanilha({
    required VoidCallback onAvisoGerarPrimeiro,
    required Function(String) onError,
  }) async {
    if (_ultimoArquivoGerado == null) {
      onAvisoGerarPrimeiro();
      return;
    }

    try {
      await _shareService.compartilharArquivoLocal(
        caminhoArquivoOriginal: _ultimoArquivoGerado!,
      );
    } catch (e) {
      onError(e.toString().replaceAll("Exception: ", ""));
    }
  }
}