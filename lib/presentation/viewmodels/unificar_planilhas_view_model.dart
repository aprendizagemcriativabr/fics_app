import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

import '../../domain/entities/pessoa.dart';
import '../../domain/usecases/unificar_planilhas.dart';
import '../../data/services/export_service.dart';

class UnificarDadosViewModel extends ChangeNotifier {
  final UnificarPlanilhas _unificarPlanilhas;
  final ExportService _exportService;

  final List<File> _selectedFiles = [];

  bool _isProcessing = false;

  UnificarDadosViewModel({
    required UnificarPlanilhas unificarPlanilhas,
    ExportService? exportService,
  })  : _unificarPlanilhas =
            unificarPlanilhas,
        _exportService =
            exportService ??
                ExportService();

  List<File> get selectedFiles =>
      _selectedFiles;

  bool get isProcessing =>
      _isProcessing;

  bool get canSubmit =>
      _selectedFiles.isNotEmpty &&
      !_isProcessing;

  /// SELECIONA PLANILHAS
  Future<void> pickMultipleFiles() async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: [
        'xlsx',
        'csv',
      ],
      allowMultiple: true,
    );

    if (result != null) {
      for (final path in result.paths) {
        if (path != null) {
          final novoArquivo =
              File(path);

          final jaExiste =
              _selectedFiles.any(
            (f) =>
                f.path ==
                novoArquivo.path,
          );

          if (!jaExiste) {
            _selectedFiles
                .add(novoArquivo);
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
    notifyListeners();
  }

  /// EXECUTA UNIFICAÇÃO
  Future<void>
      executarUnificacaoEExportar({
    required VoidCallback onSuccess,
    required Function(String)
        onError,
  }) async {
    if (_selectedFiles.isEmpty) {
      return;
    }

    _isProcessing = true;
    notifyListeners();

    try {
      /// UNIFICA TODAS AS PLANILHAS
      final List<Pessoa>
          pessoasUnificadas =
          await _unificarPlanilhas(
        _selectedFiles,
      );

      if (pessoasUnificadas
          .isEmpty) {
        throw Exception(
          "Nenhum dado encontrado nas planilhas selecionadas.",
        );
      }

      /// ORDENA
      pessoasUnificadas.sort(
        (a, b) =>
            a.nome.compareTo(
          b.nome,
        ),
      );

      /// LINHAS DO EXCEL
      final linhasPlanilha =
          pessoasUnificadas
              .map((pessoa) {
        return [
          pessoa.nome,
          pessoa.acompanhantes,
          pessoa.horaEntrada ??
              "--:--",
          pessoa.preCadastro
              ? "Sim"
              : "Não",
        ];
      }).toList();

      /// TOTAL GERAL
      int totalPessoas = 0;

      for (final pessoa
          in pessoasUnificadas) {
        totalPessoas +=
            pessoa.acompanhantes +
                1;
      }

      final linhaTotal = [
        "TOTAL GERAL",
        totalPessoas,
        "",
        "",
      ];

      /// EXPORTA
      final salvo =
          await _exportService
              .gerarPlanilha(
        nomeAba:
            "Checkins Unificados",

        nomeArquivoPadrao:
            "planilha_unificada_checkins.xlsx",

        cabecalhos: [
          "Nome",
          "Qte. Acompanhantes",
          "Horario CheckIn",
          "Pré Cadastro",
        ],

        linhasDados:
            linhasPlanilha,

        linhaTotal:
            linhaTotal,
      );

      if (salvo) {
        _selectedFiles.clear();
        onSuccess();
      }
    } catch (e) {
      onError(
        "Erro ao unificar e exportar: ${e.toString()}",
      );
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }
}