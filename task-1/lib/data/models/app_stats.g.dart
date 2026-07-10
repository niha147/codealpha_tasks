// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_stats.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AppStatsAdapter extends TypeAdapter<AppStats> {
  @override
  final int typeId = 3;

  @override
  AppStats read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AppStats(
      totalStudyTimeSeconds: fields[0] as int,
      totalSessions: fields[1] as int,
      totalCardsReviewed: fields[2] as int,
    );
  }

  @override
  void write(BinaryWriter writer, AppStats obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.totalStudyTimeSeconds)
      ..writeByte(1)
      ..write(obj.totalSessions)
      ..writeByte(2)
      ..write(obj.totalCardsReviewed);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppStatsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
