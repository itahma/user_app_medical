
import 'package:dio/dio.dart';
import 'package:newappgradu/core/database/api/end_points.dart';

import '../../error/error_model.dart';
import '../../error/exceptions.dart';
import 'api_consumer.dart';
import 'api_interceptors.dart';
//import 'end_points.dart';

class DioConsumer extends ApiConsumer {
  final Dio dio;

  DioConsumer(this.dio) {
     dio.options.baseUrl = EndPoint.baseUrl;
    dio.interceptors.add(ApiInterceptors());
    dio.interceptors.add(LogInterceptor(
      request: true,
      requestHeader: true,
      requestBody: true,
      responseHeader: true,
      responseBody: true,
      error: true,
    ));
  }
  @override
  Future delete(
      String path, {
        Object? data,
        Map<String, dynamic>? queryParameters,
        String ?token
      }) async {
    try {
      var res = await dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: Options(headers: {"jwt":token})
      );
      return res.data;
    } on DioException catch (e) {
      handleDioException(e);
    }
  }

  @override
  Future get(
      String path, {
        Object? data,
        Map<String, dynamic>? queryParameters,
        String ?token
      }) async {
    try {
      var res = await dio.get(
        path,
        data: data,
        queryParameters: queryParameters,
        options: Options(headers: {"x-jwt":token})

      );
      return res.data;
    } on DioException catch (e) {
      handleDioException(e);
    }
  }

  @override
  Future patch(
      String path, {
        Object? data,
        Map<String, dynamic>? queryParameters,
      }) async {
    try {
      var res = await dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
      );
      return res;
    } on DioException catch (e) {
      handleDioException(e);
    }
  }

  @override
  Future post(
      String path, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        bool isFormData=false,
        String ? token
      }) async {
    try {
      var res = await dio.post(
        path,
        data: isFormData? FormData.fromMap(data):data,
        queryParameters: queryParameters,
          options: Options(headers: {"x-jwt":token})
      );
      return res;
    } on DioException catch (e) {
      handleDioException(e);
    }
  }



  @override
  Future put(
      String path, {
        Object? data,
        Map<String, dynamic>? queryParameters,
      }) async {
    try {
      var res = await dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
      );
      return res;

    } on DioException catch (e) {
      handleDioException(e);
    }
  }


  handleDioException(e) {
    switch (e.type) {
      case DioExceptionType.badCertificate:
        throw BadCertificateException(ErrorModel.fromJson(e.response!.data));
      case DioExceptionType.connectionTimeout:
        throw ConnectionTimeoutException(ErrorModel.fromJson(e.response!.data));
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
      case DioExceptionType.sendTimeout:
        throw ServerException(ErrorModel.fromJson(e.response!.data));

      case DioExceptionType.badResponse:
        switch (e.response?.statusCode) {
          case 400: //bad request
            throw BadRequestException(ErrorModel.fromJson(e.response!.data));

          case 401: //unauthorized
            throw UnauthorizedException(ErrorModel.fromJson(e.response!.data));

          case 403: //forbidden
            throw ForbiddenException(ErrorModel.fromJson(e.response!.data));

          case 404: //notFound
            throw NotFoundException(ErrorModel.fromJson(e.response!.data));

          case 409: //conflict
            throw ConflictException(ErrorModel.fromJson(e.response!.data));
          case 504: //bad request
            throw BadRequestException(ErrorModel.fromJson(e.response!.data));

        // print(e.response);
        }
      case DioExceptionType.cancel:
        throw CancleExeption(ErrorModel.fromJson(e.response!.data));

      case DioExceptionType.unknown:
        throw ServerException(ErrorModel.fromJson(e.response!.data));

    // throw ServerException('badResponse');
    }
  }



}
