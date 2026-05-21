import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../../domain/entities/pessoa.dart';
import '../../data/services/import_service.dart';
import '../../data/services/export_service.dart';

class UnificarDadosViewModel extends ChangeNotifier {
  final ImportService _importService;
  final ExportService _exportService;
  final List<File> _selectedFiles = [];
  bool _isProcessing = false;

  UnificarDadosViewModel({ImportService? importService, ExportService? exportService})
      : _importService = importService ?? ImportService(),
        _exportService = exportService ?? ExportService();

  List<File> get selectedFiles => _selectedFiles;
  bool get isProcessing => _isProcessing;
  bool get canSubmit => _selectedFiles.isNotEmpty && !_isProcessing;

  // Permite selecionar vários de uma vez só OU clicar várias vezes e ir somando
  Future<void> pickMultipleFiles() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'csv'],
      allowMultiple: true, 
    );

    if (result != null) {
      for (var path in result.paths) {
        if (path != null) {
          File novoArquivo = File(path);
          
          // Evita adicionar o mesmo arquivo duplicado na lista se ele clicar de novo
          bool jaExiste = _selectedFiles.any((f) => f.path == novoArquivo.path);
          if (!jaExiste) {
            _selectedFiles.add(novoArquivo);
          }
        }
      }
      notifyListeners();
    }
  }

  // Remove um arquivo específico da lista caso o usuário desista dele antes de unificar
  void removerArquivo(File arquivo) {
    _selectedFiles.remove(arquivo);
    notifyListeners();
  }

  // Limpa tudo para recomeçar do zero
  void limparTudo() {
    _selectedFiles.clear();
    notifyListeners();
  }

Future<void> executarUnificacaoEExportar({
    required VoidCallback onSuccess,
    required Function(String) onError,
  }) async {
    if (_selectedFiles.isEmpty) return;

    _isProcessing = true;
    notifyListeners();

try {
      List<Pessoa> todasAsPessoasUnificadas = [];

      // 1. Lê e acumula os dados de todas as planilhas selecionadas
      for (File arquivo in _selectedFiles) {
        List<Pessoa> pessoasDoArquivo = await _importService.lerPlanilha(arquivo);
        todasAsPessoasUnificadas.addAll(pessoasDoArquivo);
      }

      if (todasAsPessoasUnificadas.isEmpty) {
        throw Exception("Nenhum dado encontrado nas planilhas selecionadas.");
      }

      // Evita duplicados por nome completo
      final nomesVistos = <String>{};
      todasAsPessoasUnificadas.retainWhere((p) => nomesVistos.add(p.nome.toLowerCase().trim()));

      // 2. Transforma a lista de objetos 'Pessoa' nas linhas da planilha
      // Usando os atributos exatos: pessoa.nome, pessoa.acompanhantes e pessoa.horaEntrada
      List<List<dynamic>> linhasPlanilha = todasAsPessoasUnificadas.map((pessoa) {
        return [
          pessoa.nome,
          pessoa.acompanhantes,
          pessoa.horaEntrada ?? "--:--",
        ];
      }).toList();

      // 3. MATEMÁTICA DO TOTAL: Soma (acompanhantes + 1) de cada pessoa
      int somaTotalPessoas = 0;
      for (var p in todasAsPessoasUnificadas) {
        somaTotalPessoas += (p.acompanhantes + 1); // Quantidade de acompanhantes + o titular
      }

      // Monta a linha de rodapé alinhada com as 3 colunas
      List<dynamic> linhaDeTotal = [
        "TOTAL GERAL",     // Coluna 1: Nome
        somaTotalPessoas,  // Coluna 2: Qte. Acompanhantes (contando os titulares)
        "",                // Coluna 3: Horário (vazia)
      ];

      // 4. Dispara o exportador independente
      bool salvoComSucesso = await _exportService.gerarPlanilha(
        nomeAba: "Checkins Unificados",
        nomeArquivoPadrao: "planilha_unificada_checkins.xlsx",
        cabecalhos: ["Nome", "Qte. Acompanhantes", "Horario CheckIn"],
        linhasDados: linhasPlanilha,
        linhaTotal: linhaDeTotal,
      );

      _isProcessing = false;
      notifyListeners();

      if (salvoComSucesso) {
        _selectedFiles.clear(); // Só limpa a tela se o usuário salvou o arquivo
        notifyListeners();
        onSuccess();
      }
    }
    catch (e) {
      _isProcessing = false;
      notifyListeners();
      onError("Erro ao unificar e exportar: ${e.toString()}");
    }
  }
}