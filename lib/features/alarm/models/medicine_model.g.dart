// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'medicine_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MedicineAdapter extends TypeAdapter<Medicine> {
  @override
  final int typeId = 0;

  @override
  Medicine read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Medicine(
      name: fields[0] as String,
      doses: (fields[1] as List).cast<Dose>(),
      stopDateType: fields[2] as String,
      stopDate: fields[3] as DateTime?,
      notificationIds: (fields[4] as List).cast<int>(),
    );
  }

  @override
  void write(BinaryWriter writer, Medicine obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.doses)
      ..writeByte(2)
      ..write(obj.stopDateType)
      ..writeByte(3)
      ..write(obj.stopDate)
      ..writeByte(4)
      ..write(obj.notificationIds);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MedicineAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class DoseAdapter extends TypeAdapter<Dose> {
  @override
  final int typeId = 1;

  @override
  Dose read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Dose(
      time: fields[0] as String,
      quantity: fields[1] as String,
      day: fields[2] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Dose obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.time)
      ..writeByte(1)
      ..write(obj.quantity)
      ..writeByte(2)
      ..write(obj.day);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DoseAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
