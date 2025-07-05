import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:newappgradu/core/database/api/api_consumer.dart';
import 'package:newappgradu/core/database/api/end_points.dart';
import 'package:newappgradu/core/error/exceptions.dart';
import 'package:newappgradu/features/auth/data/models/login_model.dart';
import 'package:newappgradu/features/auth/data/models/register_model.dart';

import '../../../../core/service/service_locatro.dart';

class AuthRepository {
  Future<Either<String, LoginModel>> login({
    required String email,
    required String password,

  }) async {
    try {
      final response = await sl<ApiConsumer>().post(
        EndPoint.medSignIn,
        data: {ApiKeys.email: email, ApiKeys.password: password
        },
      );
      return Right(LoginModel.fromJson(response));
    } on ServerException catch (error) {
      return left(error.errorModel.errorMessage);
    }
  }
  Future<Either<String, RegisterModel>> register({
    required String firstName,
    required String lastName,
    required String phone,
    required String email,
    required String password,
    required String dateBirthday,
    required String code,
    required String gender,
    required String regionName,
    required String subRegion,
    required String address ,

  }) async {
    try {
      final response = await sl<ApiConsumer>().post(
        EndPoint.medSignUp,
        data: {
          ApiKeys.email: email,
          ApiKeys.dataBirth: dateBirthday,
          ApiKeys.password: password,
          ApiKeys.firstName: firstName,
          ApiKeys.lastName: lastName,
          ApiKeys.phone: phone,
          ApiKeys.code: code,
          ApiKeys.gender: gender,
          ApiKeys.address: address,
          ApiKeys.regionName: regionName,
          ApiKeys.subRegion: subRegion,

        },
      );
      return Right(RegisterModel.fromJson(response));
    } on ServerException catch (error) {
      return Left(error.errorModel.errorMessage);
    }
  }

  // "email": "thaeralfarraj@gmail.com",
  // "code": "366181",
  // "regionName": "damas",
  // "subRegion": "saqba",
  // "First_Name": "thaer",
  // "Last_Name": "alfarraj",
  // "phone": "+1234567890",
  // "dateBirthday": "1999-01-01",
  // "gender": "male",
  // "password": "123123123",
  //
  // "address": "123 Main St",
  // "insuranceNumber": "INS123456"


  Future<Either<String, String>> sendCode(String email,) async {
    try {
      final response = await sl<ApiConsumer>().post(
        EndPoint.sendCode,
        data: {ApiKeys.email: email,
        },
      );
      return Right(response.data["message"]);
    } on ServerException catch (error) {
      return Left(error.errorModel.errorMessage);
    } catch (e) {
      return Left(e.toString());
    }
  }

  Future<Either<String, String>> registerSendCode(String email,String password,{String role ='user'} ) async {
    try {
      final response = await sl<ApiConsumer>().post(

        EndPoint.registerSendCode,
        data: {ApiKeys.email: email,ApiKeys.role:role,ApiKeys.password:password
        },
      );

      return Right(response.data["message"]);
    } on ServerException catch (error) {
      return Left(error.errorModel.errorMessage);
    } catch (e) {
      return Left(e.toString());
    }
  }

//restPassword

  Future<Either<String, String>> resetPassword({
    required String email,
    required String password,
    required String code,

  }) async {
    try {
      final response = await sl<ApiConsumer>().put(
        EndPoint.changeForgottenPassword,
        data: {
          ApiKeys.email: email,
          ApiKeys.password: password,
          ApiKeys.code: code,

        },
      );

      return Right(response.toString());
    } on ServerException catch (error) {
      return left(error.errorModel.errorMessage);
    } catch (e) {
      return Left(e.toString());
    }
  }
}