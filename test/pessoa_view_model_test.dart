import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fics_app_new/domain/entities/pessoa.dart';
import 'package:fics_app_new/domain/usecases/get_pessoas.dart';
import 'package:fics_app_new/domain/usecases/atualizar_acompanhantes.dart';
import 'package:fics_app_new/domain/usecases/importar_pessoas.dart';
import 'package:fics_app_new/presentation/viewmodels/pessoa_view_model.dart';

// Criando os Mocks (Dublês)
class MockGetPessoas extends Mock implements GetPessoas {}

class MockAtualizarAcompanhantes extends Mock
    implements AtualizarAcompanhantes {}

class MockImportarPessoas extends Mock implements ImportarPessoas {}

void main() {
  late PessoaViewModel viewModel;
  late MockGetPessoas mockGet;
  late MockAtualizarAcompanhantes mockAtualizar;
  late MockImportarPessoas mockImportar;

  setUp(() {
    mockGet = MockGetPessoas();
    mockAtualizar = MockAtualizarAcompanhantes();
    mockImportar = MockImportarPessoas();
    viewModel = PessoaViewModel(mockGet, mockAtualizar, mockImportar);
  });

  group('PessoaViewModel -', () {
    final tPessoa = Pessoa(nome: 'Izabella', acompanhantes: 50);
    final tLista = [tPessoa];

    test('deve iniciar com estado vazio e sem carregamento', () {
      expect(viewModel.pessoas, isEmpty);
      expect(viewModel.isLoading, false);
    });

    test('carregar: deve buscar pessoas e atualizar o estado da lista',
        () async {
      // Arrange
      when(() => mockGet()).thenAnswer((_) async => tLista);

      // Act
      final future = viewModel.carregar();

      // Assert: Verifica se isLoading ficou true logo após a chamada
      expect(viewModel.isLoading, true);

      await future;

      expect(viewModel.pessoas, tLista);
      expect(viewModel.isLoading, false);
      verify(() => mockGet()).called(1);
    });

    test('importarNovasPessoas: deve chamar o usecase e recarregar a lista',
        () async {
      // Arrange
      when(() => mockImportar(any())).thenAnswer((_) async => {});
      when(() => mockGet()).thenAnswer((_) async => tLista);

      // Act
      await viewModel.importarNovasPessoas(tLista);

      // Assert
      verify(() => mockImportar(tLista)).called(1);
      verify(() => mockGet()).called(1); // Garante que recarregou a lista
      expect(viewModel.pessoas, tLista);
    });

    test('atualizarQtd: deve chamar atualizar e recarregar dados', () async {
      // Arrange
      when(() => mockAtualizar(any(), any())).thenAnswer((_) async => {});
      when(() => mockGet()).thenAnswer((_) async => tLista);

      // Act
      await viewModel.atualizarQtd('Izabella', 10);

      // Assert
      verify(() => mockAtualizar('Izabella', 10)).called(1);
      verify(() => mockGet()).called(1);
    });
  });
}
