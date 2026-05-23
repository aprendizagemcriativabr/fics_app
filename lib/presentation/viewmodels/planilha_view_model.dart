import 'dart:io';

import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
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
  String? _ultimoArquivoGerado;

  bool get isLoading => _isLoading;
  int get totalConfirmados => _totalConfirmados;
  String? get ultimoArquivoGerado => _ultimoArquivoGerado;

  /// CARREGA TOTAL
  Future<void> inicializarTela() async {
    _isLoading = true;
    notifyListeners();

    try {
      final todasPessoas = await getPessoas();

      _totalConfirmados =
          todasPessoas.where((p) => p.confirmado).length;

      debugPrint("TOTAL CONFIRMADOS: $_totalConfirmados");
    } catch (e) {
      debugPrint("Erro ao carregar total: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// EXPORTA XLSX
  Future<void> exportarPlanilhaParticipantes({
    required VoidCallback onSuccess,
    required Function(String) onError,
  }) async {
    if (_isLoading) return;

    _isLoading = true;
    notifyListeners();

    try {
      /// PERMISSÕES
      if (Platform.isAndroid) {
        final status =
            await Permission.manageExternalStorage.request();

        if (!status.isGranted) {
          throw Exception(
            "Permissão de armazenamento negada.",
          );
        }
      }

      final todasPessoas = await getPessoas();

      debugPrint("TOTAL PESSOAS: ${todasPessoas.length}");

      final participantesConfirmados =
          todasPessoas.where((p) => p.confirmado).toList();

      debugPrint(
        "TOTAL EXPORTAÇÃO: ${participantesConfirmados.length}",
      );

      if (participantesConfirmados.isEmpty) {
        throw Exception(
          "Não há participantes confirmados.",
        );
      }

      /// CRIA EXCEL
      final excel = Excel.createExcel();

      /// REMOVE ABA PADRÃO
      excel.delete('Sheet1');

      final sheet = excel['Participantes'];

      /// CABEÇALHO
      sheet
          .cell(
            CellIndex.indexByColumnRow(
              columnIndex: 0,
              rowIndex: 0,
            ),
          )
          .value = TextCellValue('Nome');

      sheet
          .cell(
            CellIndex.indexByColumnRow(
              columnIndex: 1,
              rowIndex: 0,
            ),
          )
          .value = TextCellValue('Acompanhantes');

      sheet
          .cell(
            CellIndex.indexByColumnRow(
              columnIndex: 2,
              rowIndex: 0,
            ),
          )
          .value = TextCellValue('Hora Entrada');

      sheet
          .cell(
            CellIndex.indexByColumnRow(
              columnIndex: 3,
              rowIndex: 0,
            ),
          )
          .value = TextCellValue('Pré Cadastro');

      /// DADOS
      for (int i = 0; i < participantesConfirmados.length; i++) {
        final pessoa = participantesConfirmados[i];

        final row = i + 1;

        sheet
            .cell(
              CellIndex.indexByColumnRow(
                columnIndex: 0,
                rowIndex: row,
              ),
            )
            .value = TextCellValue(pessoa.nome);

        sheet
            .cell(
              CellIndex.indexByColumnRow(
                columnIndex: 1,
                rowIndex: row,
              ),
            )
            .value = IntCellValue(
          pessoa.acompanhantes,
        );

        sheet
            .cell(
              CellIndex.indexByColumnRow(
                columnIndex: 2,
                rowIndex: row,
              ),
            )
            .value = TextCellValue(
          pessoa.horaEntrada ?? '-',
        );

        sheet
            .cell(
              CellIndex.indexByColumnRow(
                columnIndex: 3,
                rowIndex: row,
              ),
            )
            .value = TextCellValue(
          pessoa.preCadastro ? 'Sim' : 'Não',
        );
      }

      /// DIRETÓRIO
      Directory? directory;

      if (Platform.isAndroid) {
        directory = Directory(
          '/storage/emulated/0/Download',
        );

        if (!await directory.exists()) {
          await directory.create(
            recursive: true,
          );
        }
      } else {
        directory =
            await getApplicationDocumentsDirectory();
      }

      /// NOME DO ARQUIVO
      final dataAtual =
          DateTime.now().toString().split(' ')[0];

      final timestamp =
          DateTime.now().millisecondsSinceEpoch;

      final path =
          '${directory.path}/participantes_confirmados_${dataAtual}_$timestamp.xlsx';

      debugPrint("CAMINHO SALVAMENTO: $path");

      /// GERA ARQUIVO
      final fileBytes = excel.save();

      if (fileBytes == null) {
        throw Exception(
          "Erro ao gerar a estrutura do Excel.",
        );
      }

      /// SALVA NO DISCO
      final file = File(path);

      await file.create(recursive: true);

      await file.writeAsBytes(
        fileBytes,
        flush: true,
      );

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
          debugPrint(
            "Erro ao atualizar mídia: $e",
          );
        }
      }

      _ultimoArquivoGerado = file.path;

      debugPrint(
        "PLANILHA SALVA COM SUCESSO: ${file.path}",
      );

      onSuccess();
    } catch (e) {
      debugPrint("ERRO EXPORTAÇÃO: $e");

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