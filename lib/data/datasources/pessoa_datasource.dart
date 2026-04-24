class PessoaDataSource {
  List<Map<String, dynamic>> data = [
    {"nome": "Maria Silva", "acomp": 10},
    {"nome": "Joana Santos", "acomp": 40},
    {"nome": "João Vitor", "acomp": 2},
    {"nome": "Alana Rodrigues da Silva", "acomp": 4},
    {"nome": "Guilherme Paredes Bonifacio da Silva Torres", "acomp": 12},
    {"nome": "Daniel Deuner", "acomp": 67},
    {"nome": "Rafael Mota", "acomp": 22},
    {"nome": "Gabrielle Fernandes", "acomp": 11},
    {"nome": "Cesar Cielo", "acomp": 90},
    {"nome": "Ana Júlia Bastos", "acomp": 7},
  ];

  Future<List<Map<String, dynamic>>> getData() async {
    return data;
  }

  // No seu data/datasources/pessoa_datasource.dart
  Future<void> update(String nome, int novaQtd) async {
    final index = data.indexWhere((p) => p['nome'] == nome);
    if (index != -1) {
      data[index]['acomp'] = novaQtd;
      data[index]['confirmado'] = true; // Marca como feito
      
      // DICA: Aqui é onde futuramente você chamará a API do Google Sheets
      print("LOG: $nome confirmado com $novaQtd pessoas. Pronto para o Sheets.");
    }
  }
}