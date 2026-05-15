import 'package:flutter/material.dart';
import '../../domain/entities/pessoa.dart';
import '../../domain/usecases/get_pessoas.dart';
import '../../domain/usecases/atualizar_acompanhantes.dart';
import '../../domain/usecases/importar_pessoas.dart'; // Importe o novo UseCase
import '../../domain/usecases/add_pessoa.dart';

/// Enum para definir os estados de filtragem por status
enum FiltroStatus {
  todos,
  pendentes,
  validados,
}

class PessoaViewModel extends ChangeNotifier {
  final GetPessoas getPessoas;
  final AtualizarAcompanhantes atualizar;
  final ImportarPessoas importar; // 1. Adicione a variável
  final AddPessoa addPessoa;

  PessoaViewModel(
    this.getPessoas,
    this.atualizar,
    this.importar,
    this.addPessoa
  );

  // --- ESTADO PRIVADO ---
  List<Pessoa> todasPessoas = [];
  bool isLoading = false;

  // Estados dos Filtros e Ordenação
  String _filtroNome = "";
  FiltroStatus _filtroStatus = FiltroStatus.todos;
  bool _ordemAz = true;

  // --- GETTERS ---

  /// Lista filtrada para a UI
  List<Pessoa> get pessoasFiltradas {
    // 1. Aplicar filtros
    List<Pessoa> lista = todasPessoas.where((p) {
      final bateNome = p.nome
          .toLowerCase()
          .contains(_filtroNome.toLowerCase());

      bool bateStatus;

      switch (_filtroStatus) {
        case FiltroStatus.pendentes:
          bateStatus = p.confirmado == false;
          break;

        case FiltroStatus.validados:
          bateStatus = p.confirmado == true;
          break;

        default:
          bateStatus = true;
      }

      return bateNome && bateStatus;
    }).toList();

    // 2. Aplicar ordenação
    lista.sort((a, b) {
      return _ordemAz
          ? a.nome.compareTo(b.nome)
          : b.nome.compareTo(a.nome);
    });

    return lista;
  }

  /// Estado atual do filtro
  FiltroStatus get filtroStatus => _filtroStatus;

  /// Estado atual da ordenação
  bool get ordemAz => _ordemAz;

  /// Texto atual da busca
  String get filtroNome => _filtroNome;

  /// Verifica se existem pessoas carregadas
  bool get possuiDados =>
      todasPessoas.isNotEmpty;

  // --- FILTROS ---

  /// Atualiza busca textual
  void atualizarBuscaNome(String nome) {
    _filtroNome = nome;
    notifyListeners();
  }

  /// Aplica filtros selecionados
  void aplicarFiltros({
    required FiltroStatus status,
    required bool ordem,
  }) {
    _filtroStatus = status;
    _ordemAz = ordem;

    notifyListeners();
  }

  /// Limpa todos os filtros
  void limparFiltros() {
    _filtroNome = "";
    _filtroStatus = FiltroStatus.todos;
    _ordemAz = true;

    notifyListeners();
  }

  // --- DADOS ---

  /// Carrega pessoas do banco/repositorio
  Future<void> carregar() async {
    isLoading = true;
    notifyListeners();

    todasPessoas = await getPessoas();

    isLoading = false;
    notifyListeners();
  }

  /// Importa nova planilha
  Future<void> importarNovasPessoas(
    List<Pessoa> novasPessoas,
  ) async {
    isLoading = true;
    notifyListeners();

    try {
      await importar(novasPessoas);

      // Recarrega lista após importar
      await carregar();
    } catch (e) {
      debugPrint("Erro ao importar: $e");
      rethrow;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Atualiza quantidade de acompanhantes
  Future<void> atualizarQtd(
    String nome,
    int qtd,
  ) async {
    await atualizar(nome, qtd);

    await carregar();
  }

  Future<void> adicionarPessoa(
    String nome,
    int acompanhantes,
  ) async {

    final nomeLimpo = nome.trim();

    /// VALIDAÇÃO
    if (nomeLimpo.isEmpty) {
      throw Exception(
        "Digite o nome do responsável.",
      );
    }

    /// EVITA DUPLICADOS
    final jaExiste = todasPessoas.any(
      (p) =>
          p.nome.toLowerCase() ==
          nomeLimpo.toLowerCase(),
    );

    if (jaExiste) {
      throw Exception(
        "Já existe um participante com esse nome.",
      );
    }

    isLoading = true;
    notifyListeners();

    try {

      final pessoa = Pessoa(
        nome: nomeLimpo,
        acompanhantes: acompanhantes,
        confirmado: true,
      );

      await addPessoa(pessoa);

      await carregar();

    } finally {

      isLoading = false;
      notifyListeners();
    }
  }
}