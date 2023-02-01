// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'db.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BoardDataAdapter extends TypeAdapter<BoardData> {
  @override
  final int typeId = 0;

  @override
  BoardData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BoardData(
      fields[0] as APIType,
      fields[1] as String,
      login: fields[2] as String?,
      pw: fields[3] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, BoardData obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.type)
      ..writeByte(1)
      ..write(obj.baseUrl)
      ..writeByte(2)
      ..write(obj.login)
      ..writeByte(3)
      ..write(obj.pw);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BoardDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class APITypeAdapter extends TypeAdapter<APIType> {
  @override
  final int typeId = 1;

  @override
  APIType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return APIType.moebooru;
      case 1:
        return APIType.szurubooru;
      default:
        return APIType.moebooru;
    }
  }

  @override
  void write(BinaryWriter writer, APIType obj) {
    switch (obj) {
      case APIType.moebooru:
        writer.writeByte(0);
        break;
      case APIType.szurubooru:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is APITypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
