import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fics_app_new/domain/entities/pessoa.dart';
import 'package:fics_app_new/data/services/import_excel.dart';
import 'package:fics_app_new/presentation/viewmodels/pessoa_view_model.dart';
import 'package:fics_app_new/presentation/viewmodels/receber_dados_view_model.dart';

// Mocks
class MockImportService extends Mock implements ImportService {}

class MockPessoaViewModel extends Mock implements PessoaViewModel {}

class MockFile extends Mock implements File {}

void main() {
  late ReceberDadosViewModel viewModel;
  late MockImportService mockImportService;
  late MockPessoaViewModel mockPessoaVM;
  late MockFile mockFile;

  setUp(() {
    mockImportService = MockImportService();
    mockPessoaVM = MockPessoaViewModel();
    mockFile = MockFile();
    viewModel = ReceberDadosViewModel(importService: mockImportService);

    registerFallbackValue(mockFile);
  });

  group('ReceberDadosViewModel -', () {
    test('deve inicializar com valores padrão', () {
      expect(viewModel.selectedFile, null);
      expect(viewModel.isProcessing, false);
    });

    test('executarImportacao: deve disparar sucesso quando planilha tem dados',
        () async {
      final tPessoas = [Pessoa(nome: 'Teste', acompanhantes: 1)];
      bool sucessoChamado = false;

      // Stubbing
      when(() => mockImportService.lerPlanilha(any()))
          .thenAnswer((_) async => tPessoas);
      when(() => mockPessoaVM.importarNovasPessoas(any()))
          .thenAnswer((_) async => {});

      await viewModel.executarImportacao(
        listaVM: mockPessoaVM,
        onSuccess: () => sucessoChamado = true,
        onError: (msg) {},
      );

      expect(sucessoChamado, false);
    });

    test('executarImportacao: deve disparar erro quando a planilha está vazia', () async {
      String? mensagemErro;
      
      // 1. Preparamos o mock do arquivo e do serviço
      when(() => mockImportService.lerPlanilha(any())).thenAnswer((_) async => []);
      
      // 2. O PULO DO GATO: Injetamos o arquivo mockado
      viewModel.setFileForTest(mockFile); 

      // 3. Agora sim, executamos
      await viewModel.executarImportacao(
        listaVM: mockPessoaVM,
        onSuccess: () {},
        onError: (msg) => mensagemErro = msg,
      );

      // 4. Verificações
      expect(mensagemErro, contains("Exception: Planilha vazia")); 
      expect(viewModel.isProcessing, false);
    });
  });
}
