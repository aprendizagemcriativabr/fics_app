import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:fics_app_new/domain/entities/pessoa.dart';
import 'package:fics_app_new/domain/usecases/get_pessoas.dart';
import 'package:fics_app_new/domain/usecases/atualizar_acompanhantes.dart';
import 'package:fics_app_new/domain/usecases/importar_pessoas.dart';
import 'package:fics_app_new/domain/usecases/add_pessoa.dart';
import 'package:fics_app_new/presentation/viewmodels/pessoa_view_model.dart';

// Mocks 
class MockGetPessoas extends Mock implements GetPessoas {}
class MockAtualizarAcompanhantes extends Mock implements AtualizarAcompanhantes {}
class MockImportarPessoas extends Mock implements ImportarPessoas {}
class MockAddPessoa extends Mock implements AddPessoa {}
class FakePessoa extends Fake implements Pessoa {}

void main() {
  late PessoaViewModel viewModel;
  late MockGetPessoas mockGet;
  late MockAtualizarAcompanhantes mockAtualizar;
  late MockImportarPessoas mockImportar;
  late MockAddPessoa mockAdd;

  final tPessoaPreCadastro = Pessoa(
    nome: 'Izabella',
    acompanhantes: 50,
    preCadastro: true, // vindo de planilha
    confirmado: false,
  );
  
  final tPessoaLocal = Pessoa(
    nome: 'Carlos',
    acompanhantes: 2,
    preCadastro: false, // cadastro manual
    confirmado: true,
  );

  final tLista = [tPessoaPreCadastro, tPessoaLocal];

  setUpAll(() {
    registerFallbackValue(FakePessoa());
  });

  setUp(() {
    mockGet = MockGetPessoas();
    mockAtualizar = MockAtualizarAcompanhantes();
    mockImportar = MockImportarPessoas();
    mockAdd = MockAddPessoa();
    viewModel = PessoaViewModel(mockGet, mockAtualizar, mockImportar, mockAdd);
  });

  group('PessoaViewModel -', () {
    test('deve iniciar com estado vazio e sem carregamento', () {
      expect(viewModel.todasPessoas, isEmpty);
      expect(viewModel.isLoading, false);
      expect(viewModel.possuiPreCadastro, false); 
    });

    test('carregar: deve buscar pessoas e atualizar o estado da lista', () async {
      when(() => mockGet.call()).thenAnswer((_) async => tLista);

      final future = viewModel.carregar();

      expect(viewModel.isLoading, true);

      await future;

      expect(viewModel.todasPessoas, tLista);
      expect(viewModel.isLoading, false);
      verify(() => mockGet.call()).called(1);
    });

    test('possuiPreCadastro: deve identificar corretamente se há dados de planilha', () async {
      when(() => mockGet.call()).thenAnswer((_) async => [tPessoaLocal]);
      await viewModel.carregar();
      expect(viewModel.possuiPreCadastro, false); // Local não conta como pré-cadastro

      when(() => mockGet.call()).thenAnswer((_) async => tLista);
      await viewModel.carregar();
      expect(viewModel.possuiPreCadastro, true); // Identificou o pré-cadastro
    });

    test('importarNovasPessoas: deve chamar o usecase e recarregar a lista', () async {
      // Arrange
      when(() => mockImportar.call(any())).thenAnswer((_) async => {});
      when(() => mockGet.call()).thenAnswer((_) async => tLista);

      // Act
      await viewModel.importarNovasPessoas(tLista);

      // Assert
      verify(() => mockImportar.call(tLista)).called(1);
      verify(() => mockGet.call()).called(1); // Garante que recarregou a lista
      expect(viewModel.todasPessoas, tLista);
    });

    test('atualizarQtd: deve chamar atualizar e recarregar dados', () async {
      // Arrange
      when(() => mockAtualizar.call(any(), any())).thenAnswer((_) async => {});
      when(() => mockGet.call()).thenAnswer((_) async => tLista);

      // Act
      await viewModel.atualizarQtd('Izabella', 10);

      // Assert
      verify(() => mockAtualizar.call('Izabella', 10)).called(1);
      verify(() => mockGet.call()).called(1);
    });
  });
}