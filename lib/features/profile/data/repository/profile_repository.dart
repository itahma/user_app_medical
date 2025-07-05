import 'package:dartz/dartz.dart';
import 'package:newappgradu/core/database/api/api_consumer.dart';
import 'package:newappgradu/core/database/api/end_points.dart';
import 'package:newappgradu/core/database/cache/cache_helper.dart';
import 'package:newappgradu/core/error/exceptions.dart';
import 'package:newappgradu/core/service/service_locatro.dart';
import 'package:newappgradu/features/profile/data/models/profile_model.dart';

class ProfileRepository{
  Future<Either<String,ProfileModel>> getProfile() async {
    String token=  await sl<CacheHelper>().getData(key: "x-jwt");
    try {
      var  response=await sl<ApiConsumer>().get(EndPoint.getProfile,token: token);
      var res=ProfileModel.formJson(response);

      return Right(res);
    } on ServerException catch (error) {
      return left(error.errorModel.errorMessage);
    }
  }
}