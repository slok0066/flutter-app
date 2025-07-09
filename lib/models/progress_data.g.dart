// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'progress_data.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProgressDataAdapter extends TypeAdapter<ProgressData> {
  @override
  final int typeId = 1;

  @override
  ProgressData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ProgressData(
      videosWatched: fields[0] as int,
      quizzesPassed: fields[1] as int,
      currentStreak: fields[2] as int,
      longestStreak: fields[3] as int,
      totalHoursWatched: fields[4] as double,
      lastSessionDate: fields[5] as DateTime,
      completedVideoIds: (fields[6] as List).cast<String>(),
      quizScores: (fields[7] as Map).cast<String, int>(),
      sessionDates: (fields[8] as List).cast<DateTime>(),
    );
  }

  @override
  void write(BinaryWriter writer, ProgressData obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.videosWatched)
      ..writeByte(1)
      ..write(obj.quizzesPassed)
      ..writeByte(2)
      ..write(obj.currentStreak)
      ..writeByte(3)
      ..write(obj.longestStreak)
      ..writeByte(4)
      ..write(obj.totalHoursWatched)
      ..writeByte(5)
      ..write(obj.lastSessionDate)
      ..writeByte(6)
      ..write(obj.completedVideoIds)
      ..writeByte(7)
      ..write(obj.quizScores)
      ..writeByte(8)
      ..write(obj.sessionDates);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProgressDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

