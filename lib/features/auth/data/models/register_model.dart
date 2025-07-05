import '../../../../core/database/api/end_points.dart';

class RegisterModel {
  final String message;
  final String token;

  RegisterModel({
    required this.message,
    required this.token,
  });

  factory RegisterModel.fromJson( jsonData) {
    return RegisterModel(
        message: "register success!!",
        token: jsonData.headers.value(ApiKeys.token));
  }
}
