import 'dart:io';

import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../../domain/usecases/get_pessoas.dart';
import 'pessoa_view_model.dart';

class PlanilhaViewModel extends ChangeNotifier {
  final GetPessoas getPessoas;

  PlanilhaViewModel(this.getPessoas);

  factory PlanilhaViewModel.fromContext(BuildContext context) {
    final pessoaViewModel = context.read<PessoaViewModel>();

    return PlanilhaViewModel(
      pessoaViewModel.getPessoas,
    );
  }

  bool _isLoading = false;
  int _totalConfirmados = 0;

  bool get isLoading => _isLoading;
  int get totalConfirmados => _totalConfirmados;

  String? _ultimoArquivoGerado;

  String? get ultimoArquivoGerado => _ultimoArquivoGerado;

  /// CARREGA TOTAL DE CONFIRMADOS
  Future<void> inicializarTela() async {
    _isLoading = true;
    notifyListeners();

    try {
      final todasPessoas = await getPessoas();

      _totalConfirmados = todasPessoas
          .where((p) => p.confirmado == true)
          .length;

      debugPrint("TOTAL: $_totalConfirmados");
    } catch (e) {
      debugPrint(
        "Erro ao carregar total de confirmados: $e",
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// EXPORTAR XLSX
  Future<void> exportarPlanilhaParticipantes({
    required VoidCallback onSuccess,
    required Function(String) onError,
  }) async {

    if (_isLoading) return;

    _isLoading = true;
    notifyListeners();

    try {

      final todasPessoas = await getPessoas();

      final participantesConfirmados = todasPessoas
          .where((p) => p.confirmado == true)
          .toList();

      if (participantesConfirmados.isEmpty) {
        throw Exception(
          "Não há participantes confirmados.",
        );
      }

      /// CRIA EXCEL
      final excel = Excel.createExcel();

      final sheet = excel['Participantes'];

      /// CABEÇALHO
      sheet.appendRow([
        TextCellValue('Nome'),
        TextCellValue('Acompanhantes'),
        TextCellValue('Hora Entrada'),
        TextCellValue('Pré Cadastro'),
      ]);

      /// DADOS
      for (final pessoa in participantesConfirmados) {

        sheet.appendRow([
          TextCellValue(pessoa.nome),
          IntCellValue(pessoa.acompanhantes),
          TextCellValue(
            pessoa.horaEntrada ?? '-',
          ),
          TextCellValue(
            pessoa.preCadastro ? 'Sim' : 'Não',
          ),
        ]);
      }

      /// DIRETÓRIO
      final directory =
          await getApplicationDocumentsDirectory();

      final path =
          '${directory.path}/participantes_confirmados.xlsx';

      /// SALVA
      final fileBytes = excel.encode();

      if (fileBytes == null) {
        throw Exception(
          "Erro ao gerar arquivo Excel.",
        );
      }

      final file = File(path)
        ..createSync(recursive: true)
        ..writeAsBytesSync(fileBytes);

      _ultimoArquivoGerado = file.path;

      debugPrint(
        "Planilha salva em: ${file.path}",
      );

      onSuccess();

    } catch (e) {

      debugPrint(
        "Erro ao exportar planilha: $e",
      );

      onError(
        e.toString().replaceAll(
          "Exception: ",
          "",
        ),
      );

    } finally {

      _isLoading = false;
      notifyListeners();
    }
  }
}