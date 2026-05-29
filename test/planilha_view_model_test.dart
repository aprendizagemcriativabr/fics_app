import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fics_app_new/domain/entities/pessoa.dart';
import 'package:fics_app_new/domain/usecases/get_pessoas.dart';
import 'package:fics_app_new/data/services/share_service.dart';
import 'package:fics_app_new/presentation/viewmodels/planilha_view_model.dart';

class MockGetPessoas extends Mock implements GetPessoas {}

class MockShareService extends Mock implements ShareService {}

void main() {
  late PlanilhaViewModel viewModel;
  late MockGetPessoas mockGetPessoas;
  late MockShareService mockShareService;

  setUp(() {
    mockGetPessoas = MockGetPessoas();
    mockShareService = MockShareService();
    viewModel = PlanilhaViewModel(mockGetPessoas, mockShareService);
  });

  group('PlanilhaViewModel - Inicialização', () {
    test('Deve calcular corretamente os totais filtrando apenas os confirmados',
        () async {
      final listaMock = [
        Pessoa(
            nome: 'Alice Confirmada',
            confirmado: true,
            acompanhantes: 2), // 1 + 2 = 3 participantes
        Pessoa(
            nome: 'Bob Não Confirmado',
            confirmado: false,
            acompanhantes: 5), // Ignorado
        Pessoa(
            nome: 'Charlie Confirmado',
            confirmado: true,
            acompanhantes: 0), // 1 + 0 = 1 participante
      ];

      when(() => mockGetPessoas()).thenAnswer((_) async => listaMock);

      expect(viewModel.isLoading, false);

      final futuro = viewModel.inicializarTela();
      expect(viewModel.isLoading,
          true); // Deve setar loading durante processamento

      await futuro;

      expect(viewModel.isLoading, false);
      expect(viewModel.totalConfirmados, 2); // Alice e Charlie
      expect(viewModel.totalParticipantes, 4); // 3 da Alice + 1 do Charlie
    });

    test('Deve tratar erros de repositório de forma segura sem crashar a VM',
        () async {
      when(() => mockGetPessoas())
          .thenThrow(Exception("Erro de Banco de Dados"));

      await viewModel.inicializarTela();

      expect(viewModel.isLoading, false);
      expect(viewModel.totalConfirmados, 0);
    });
  });

  group('PlanilhaViewModel - Compartilhamento', () {
    test(
        'Deve chamar aviso para gerar planilha caso não haja arquivo salvo prévio',
        () async {
      bool avisoChamado = false;

      await viewModel.compartilharPlanilha(
        onAvisoGerarPrimeiro: () => avisoChamado = true,
        onError: (_) {},
      );

      expect(avisoChamado, true);
      verifyNever(() => mockShareService.compartilharArquivoLocal(
          caminhoArquivoOriginal: any(named: 'caminhoArquivoOriginal')));
    });
  });
}
