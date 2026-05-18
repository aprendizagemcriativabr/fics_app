// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pessoa_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PessoaModelAdapter extends TypeAdapter<PessoaModel> {
  @override
  final int typeId = 0;

  @override
  PessoaModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PessoaModel(
      nome: fields[0] as String,
      acompanhantes: fields[1] as int,
      confirmado: fields[2] as bool,
      horaEntrada: fields[3] as String?,
      preCadastro: fields[4] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, PessoaModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.nome)
      ..writeByte(1)
      ..write(obj.acompanhantes)
      ..writeByte(2)
      ..write(obj.confirmado)
      ..writeByte(3)
      ..write(obj.horaEntrada)
      ..writeByte(4)
      ..write(obj.preCadastro);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PessoaModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
