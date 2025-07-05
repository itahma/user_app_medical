import '../../../../core/database/api/end_points.dart';

class LoginModel {
  final String message;
  final String token;

  LoginModel({
    required this.message,
    required this.token,
  });

  factory LoginModel.fromJson(jsonData) {

    return LoginModel(
        message: jsonData.data[ApiKeys.email],
        token: jsonData.headers.value(ApiKeys.token));
  }
}
