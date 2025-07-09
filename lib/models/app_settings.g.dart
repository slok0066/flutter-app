// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_settings.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AppSettingsAdapter extends TypeAdapter<AppSettings> {
  @override
  final int typeId = 0;

  @override
  AppSettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AppSettings(
      startTime: fields[0] as String,
      endTime: fields[1] as String,
      isEnabled: fields[2] as bool,
      reminderMinutes: fields[3] as int,
      allowedVideoIds: (fields[4] as List).cast<String>(),
      blockYouTubeApp: fields[5] as bool,
      quizDifficulty: fields[6] as int,
      requireQuizToUnlock: fields[7] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, AppSettings obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.startTime)
      ..writeByte(1)
      ..write(obj.endTime)
      ..writeByte(2)
      ..write(obj.isEnabled)
      ..writeByte(3)
      ..write(obj.reminderMinutes)
      ..writeByte(4)
      ..write(obj.allowedVideoIds)
      ..writeByte(5)
      ..write(obj.blockYouTubeApp)
      ..writeByte(6)
      ..write(obj.quizDifficulty)
      ..writeByte(7)
      ..write(obj.requireQuizToUnlock);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppSettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

