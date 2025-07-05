// medicine_model.dart
import 'package:hive/hive.dart';

part 'medicine_model.g.dart'; // سيتم إنشاؤه بواسطة build_runner

@HiveType(typeId: 0) // typeId يجب أن يكون فريدًا لكل HiveObject
class Medicine extends HiveObject {
  @HiveField(0)
  String name;

  @HiveField(1)
  List<Dose> doses;

  @HiveField(2)
  String stopDateType; // "lifelong" أو "specificDate"

  @HiveField(3)
  DateTime? stopDate; // يكون null إذا كان مدى الحياة

  @HiveField(4)
  List<int> notificationIds; // لتخزين معرفات الإشعارات لإمكانية إلغائها

  Medicine({
    required this.name,
    required this.doses,
    required this.stopDateType,
    this.stopDate,
    required this.notificationIds,
  });
}

@HiveType(typeId: 1)
class Dose extends HiveObject {
  @HiveField(0)
  String time; // سيخزن الوقت كسلسلة نصية مثل "10:30 AM" أو يمكنك استخدام DateTime

  @HiveField(1)
  String quantity; // مثل "1", "0.5", "10 ml"

  @HiveField(2)
  String? day; // اليوم المحدد (مثلاً "السبت"), أو null إذا كان يومياً

  Dose({
    required this.time,
    required this.quantity,
    this.day,
  });
}
