import 'package:dartz/dartz.dart';
import 'package:newappgradu/core/database/api/api_consumer.dart';
import 'package:newappgradu/core/database/api/end_points.dart';
import 'package:newappgradu/core/error/exceptions.dart';
import 'package:newappgradu/core/service/service_locatro.dart';
import 'package:newappgradu/features/home/data/models/Specialist_model.dart';
class HomeRepository {
  Future<Either<String,List<SpecialistModel> >> getAllSpecialist() async {
    try {
      final response = await sl<ApiConsumer>().get(EndPoint.getAllSpecialist,);
      List<SpecialistModel> res=response.map((e)=>SpecialistModel.fromJson(e)).toList();
      return Right(res);
    } on ServerException catch (error) {
      return left(error.errorModel.errorMessage);
    }
  }

}