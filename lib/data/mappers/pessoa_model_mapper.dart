import '../../domain/entities/pessoa.dart';
import '../models/pessoa_model.dart';

class PessoaModelMapper {
  PessoaModel toModel(
    Pessoa entity,
  ) {
    return PessoaModel(
      nome: entity.nome,
      acompanhantes:
          entity.acompanhantes,
      confirmado:
          entity.confirmado,
      horaEntrada:
          entity.horaEntrada,
      preCadastro:
          entity.preCadastro,
    );
  }

  Pessoa toEntity(
    PessoaModel model,
  ) {
    return Pessoa(
      nome: model.nome,
      acompanhantes:
          model.acompanhantes,
      confirmado:
          model.confirmado,
      horaEntrada:
          model.horaEntrada,
      preCadastro:
          model.preCadastro,
    );
  }
}