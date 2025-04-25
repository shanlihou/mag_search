// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'http_cache.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HttpCacheAdapter extends TypeAdapter<HttpCache> {
  @override
  final int typeId = 0;

  @override
  HttpCache read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HttpCache(
      content: fields[0] as String,
    );
  }

  @override
  void write(BinaryWriter writer, HttpCache obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.content);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HttpCacheAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
