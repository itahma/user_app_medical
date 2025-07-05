import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:newappgradu/core/bloc/cubit/global_cubit.dart';
import 'package:newappgradu/core/database/api/api_consumer.dart';
import 'package:newappgradu/core/database/api/dio_consumer.dart';
import 'package:newappgradu/core/database/cache/cache_helper.dart';
import 'package:newappgradu/features/articles/data/repository/articles_repository.dart';
import 'package:newappgradu/features/articles/presentation/cubit/articles_cubit.dart';
import 'package:newappgradu/features/auth/data/repository/auth_repository.dart';
import 'package:newappgradu/features/auth/presentation/cubit/forget_password_cubit/forget_password_cubit.dart';
import 'package:newappgradu/features/auth/presentation/cubit/login/login_cubit/login_cubit.dart';
import 'package:newappgradu/features/auth/presentation/cubit/register_send_code/redister_send_code_cubit.dart';
import 'package:newappgradu/features/auth/presentation/cubit/registr_cubit/register_cubit.dart';
import 'package:newappgradu/features/auth/presentation/secreen/register_send_code.dart';
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
    () => LoginCubit(sl()),
  );
  sl.registerLazySingleton(
    () => RegisterCubit(sl()),
  );
  sl.registerLazySingleton(
    () => RegisterSendCodeCubit(sl()),
  );
  sl.registerLazySingleton(
    () => ForgetPasswordCubit(sl()),
  );
  sl.registerLazySingleton(
    () => HomeCubit(sl()),
  );
  sl.registerLazySingleton(
    () => AuthRepository(),
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
