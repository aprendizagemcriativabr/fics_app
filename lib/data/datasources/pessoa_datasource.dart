import '../../domain/entities/pessoa.dart';

class PessoaDataSource {
  // Agora a lista começa VAZIA.
  // Ela só será preenchida quando você clicar em "Receber Dados".
  List<Map<String, dynamic>> data = [];

  /// Retorna os dados atuais (seja vazio ou populado pelo Excel)
  Future<List<Map<String, dynamic>>> getData() async {
    // Simulando um pequeno delay de rede/leitura
    await Future.delayed(const Duration(milliseconds: 300));
    return data;
  }

  /// Atualiza o status de uma pessoa após a validação no check-in
  Future<void> update(String nome, int novaQtd) async {
    final index = data.indexWhere((p) => p['nome'] == nome);
    if (index != -1) {
      data[index]['acomp'] = novaQtd;
      data[index]['confirmado'] = true;
    }
  }

  /// Alimenta o app com os dados reais vindos da sua Importação
  Future<void> popularDoExcel(List<Pessoa> novasPessoas) async {
    // Garantimos que a lista anterior (ou mocks residuais) seja apagada
    data.clear();

    // Transformamos as entidades de domínio em dados de infraestrutura (Map)
    for (var pessoa in novasPessoas) {
      data.add({
        "nome": pessoa.nome,
        "acomp": pessoa.acompanhantes,
        "confirmado": false,
      });
    }
  }
}
