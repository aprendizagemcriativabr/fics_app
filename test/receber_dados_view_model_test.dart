import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fics_app_new/domain/entities/pessoa.dart';
import 'package:fics_app_new/data/services/import_service.dart';
import 'package:fics_app_new/presentation/viewmodels/pessoa_view_model.dart';
import 'package:fics_app_new/presentation/viewmodels/receber_dados_view_model.dart';

// Mocks
class MockImportService extends Mock implements ImportService {}

class MockPessoaViewModel extends Mock implements PessoaViewModel {}

class MockFile extends Mock implements File {}

class FakePessoa extends Fake implements Pessoa {}

void main() {
  late ReceberDadosViewModel viewModel;
  late MockImportService mockImportService;
  late MockPessoaViewModel mockPessoaVM;
  late MockFile mockFile;

  setUpAll(() {
    registerFallbackValue(MockFile());
    registerFallbackValue(FakePessoa());
  });

  setUp(() {
    mockImportService = MockImportService();
    mockPessoaVM = MockPessoaViewModel();
    mockFile = MockFile();
    viewModel = ReceberDadosViewModel(importService: mockImportService);
    when(() => mockFile.path).thenReturn('caminho/do/arquivo/planilha.xlsx');
  });

  group('ReceberDadosViewModel -', () {
    test('deve inicializar com valores padrão', () {
      expect(viewModel.selectedFile, null);
      expect(viewModel.isProcessing, false);
      expect(viewModel.fileName, null);
    });

    test('executarImportacao: deve disparar sucesso quando planilha tem dados',
        () async {
      final tPessoas = [
        Pessoa(nome: 'Teste', acompanhantes: 1, confirmado: true)
      ];
      bool sucessoChamado = false;

      // Stubbing
      when(() => mockImportService.lerPlanilha(any()))
          .thenAnswer((_) async => tPessoas);
      when(() => mockPessoaVM.importarNovasPessoas(any()))
          .thenAnswer((_) async => {});

      viewModel.setFileForTest(mockFile);

      await viewModel.executarImportacao(
        listaVM: mockPessoaVM,
        onSuccess: () => sucessoChamado = true,
        onError: (msg) {},
      );

      expect(sucessoChamado, true);
      expect(viewModel.isProcessing, false);
    });

    test('executarImportacao: deve disparar erro quando a planilha está vazia',
        () async {
      String? mensagemErro;

      when(() => mockImportService.lerPlanilha(any()))
          .thenAnswer((_) async => []);

      viewModel.setFileForTest(mockFile);

      await viewModel.executarImportacao(
        listaVM: mockPessoaVM,
        onSuccess: () {},
        onError: (msg) => mensagemErro = msg,
      );

      expect(mensagemErro, contains("Exception: Planilha vazia"));
      expect(viewModel.isProcessing, false);
    });
  });
}
