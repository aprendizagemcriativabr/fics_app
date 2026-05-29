import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fics_app_new/domain/entities/pessoa.dart';
import 'package:fics_app_new/domain/usecases/unificar_planilhas.dart';
import 'package:fics_app_new/data/services/share_service.dart';
import 'package:fics_app_new/presentation/viewmodels/unificar_planilhas_view_model.dart';

// Criação das classes de Mock
class MockUnificarPlanilhas extends Mock implements UnificarPlanilhas {}
class MockShareService extends Mock implements ShareService {}
class MockFile extends Mock implements File {}

void main() {
  late UnificarDadosViewModel viewModel;
  late MockUnificarPlanilhas mockUnificarPlanilhas;
  late MockShareService mockShareService;

  setUp(() {
    mockUnificarPlanilhas = MockUnificarPlanilhas();
    mockShareService = MockShareService();
    viewModel = UnificarDadosViewModel(
      unificarPlanilhas: mockUnificarPlanilhas,
      shareService: mockShareService,
    );
  });

  group('UnificarDadosViewModel - Fluxo de Arquivos', () {
    test('Deve iniciar com estado limpo e canSubmit como falso', () {
      expect(viewModel.selectedFiles.isEmpty, true);
      expect(viewModel.isProcessing, false);
      expect(viewModel.ultimoArquivoGerado, null);
      expect(viewModel.canSubmit, false);
    });

    test('Deve remover arquivo com sucesso e notificar ouvintes', () {
      final file = MockFile();
      when(() => file.path).thenReturn('caminho/mock_planilha.xlsx');
      
      // Adição manual simulada para o teste de remoção
      viewModel.selectedFiles.add(file);
      expect(viewModel.selectedFiles.length, 1);

      bool notificou = false;
      viewModel.addListener(() => notificou = true);

      viewModel.removerArquivo(file);

      expect(viewModel.selectedFiles.isEmpty, true);
      expect(notificou, true);
    });

    test('Deve limpar todos os estados ao invocar limparTudo', () {
      final file = MockFile();
      viewModel.selectedFiles.add(file);
      
      viewModel.limparTudo();

      expect(viewModel.selectedFiles.isEmpty, true);
      expect(viewModel.ultimoArquivoGerado, null);
    });
  });

  group('UnificarDadosViewModel - Execução e Exportação', () {
    test('Deve disparar erro se tentar executar com menos de 2 arquivos', () async {
      final file1 = MockFile();
      viewModel.selectedFiles.add(file1);

      expect(
        () => viewModel.executarUnificacaoEExportar(
          onSuccess: () {},
          onError: (msg) {},
        ),
        throwsA(isA<Exception>()),
      );
    });

    test('Deve falhar e invocar o callback onError se a unificação retornar vazia', () async {
      final file1 = MockFile();
      final file2 = MockFile();
      when(() => file1.path).thenReturn('p1.xlsx');
      when(() => file2.path).thenReturn('p2.xlsx');
      
      viewModel.selectedFiles.add(file1);
      viewModel.selectedFiles.add(file2);

      // Stub para o caso de uso retornar uma lista vazia de pessoas
      when(() => mockUnificarPlanilhas(any())).thenAnswer((_) async => <Pessoa>[]);

      String? erroRecebido;
      await viewModel.executarUnificacaoEExportar(
        onSuccess: () {},
        onError: (erro) => erroRecebido = erro,
      );

      expect(erroRecebido, contains("Nenhum dado válido encontrado"));
      expect(viewModel.isProcessing, false);
    });
  });
}