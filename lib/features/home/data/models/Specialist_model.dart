import '../../../../core/database/api/end_points.dart';

class SpecialistModel {
  final id;
  final name;

  SpecialistModel({
    required this.id,
    required this.name,
  });

  factory SpecialistModel.fromJson(jsonData) {
    return SpecialistModel(
        id: jsonData.data[ApiKeys.name], name: jsonData.data[ApiKeys.id]);
  }
}
