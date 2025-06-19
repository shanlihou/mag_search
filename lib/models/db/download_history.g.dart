// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'download_history.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DownloadHistoryAdapter extends TypeAdapter<DownloadHistory> {
  @override
  final int typeId = 2;

  @override
  DownloadHistory read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DownloadHistory(
      url: fields[0] as String,
      title: fields[1] as String,
      timestamp: fields[2] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, DownloadHistory obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.url)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.timestamp);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DownloadHistoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
