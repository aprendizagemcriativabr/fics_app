import 'dart:io';
import '../../data/services/import_service.dart';
import '../repositories/pessoa_repository.dart';

class ImportarPlanilhaUseCase {
  final ImportService importService;

  final PessoaRepository repository;

  ImportarPlanilhaUseCase({
    required this.importService,
    required this.repository,
  });

  Future<void> executar(
    File file,
  ) async {
    final pessoas = await importService.lerPlanilha(file);

    if (pessoas.isEmpty) {
      throw Exception(
        'Planilha vazia',
      );
    }

    await repository.saveAll(
      pessoas,
    );
  }
}
