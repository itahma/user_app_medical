import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:newappgradu/core/bloc/cubit/global_cubit.dart';
import 'package:newappgradu/core/database/api/api_consumer.dart';
import 'package:newappgradu/core/database/api/dio_consumer.dart';
import 'package:newappgradu/core/database/cache/cache_helper.dart';
import 'package:newappgradu/features/articles/data/repository/articles_repository.dart';
import 'package:newappgradu/features/articles/presentation/cubit/articles_cubit.dart';
import 'package:newappgradu/features/home/data/repository/home_repository.dart';
import 'package:newappgradu/features/home/presentation/cubit/home_cubit.dart';
import 'package:newappgradu/features/profile/data/repository/profile_repository.dart';
import 'package:newappgradu/features/profile/presentation/cubit/setting_cubit/setting_cubit.dart';

final sl = GetIt.instance;

void initServiceLocator() {
  sl.registerLazySingleton(
    () => GlobalCubit(),
  );

  sl.registerLazySingleton(
    () => ArticlesCubit(sl()),
  );

  sl.registerLazySingleton(
    () => ArticlesRepository(),
  );
  sl.registerLazySingleton(
    () => HomeCubit(sl()),
  );

  sl.registerLazySingleton(
    () => CacheHelper(),
  );
  sl.registerLazySingleton(
    () => HomeRepository(),
  );
  sl.registerLazySingleton<ApiConsumer>(
    () => DioConsumer(sl()),
  );
  sl.registerLazySingleton(() => SettingCubit(sl()));
  sl.registerLazySingleton(
    () => ProfileRepository(),
  );
  sl.registerLazySingleton(
    () => Dio(),
  );
}
