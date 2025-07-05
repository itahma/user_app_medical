
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'app/app.dart';
import 'core/bloc/cubit/global_cubit.dart';
import 'core/database/cache/cache_helper.dart';
import 'core/service/service_locatro.dart';
import 'features/alarm/models/medicine_model.dart';
import 'features/articles/presentation/cubit/articles_cubit.dart';
import 'features/auth/presentation/cubit/forget_password_cubit/forget_password_cubit.dart';
import 'features/auth/presentation/cubit/login/login_cubit/login_cubit.dart';
import 'features/auth/presentation/cubit/register_send_code/redister_send_code_cubit.dart';
import 'features/auth/presentation/cubit/registr_cubit/register_cubit.dart';
import 'features/home/presentation/cubit/home_cubit.dart';
import 'features/profile/presentation/cubit/setting_cubit/setting_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:path_provider/path_provider.dart';

import 'package:flutter_localizations/flutter_localizations.dart'; // لدعم اللغة
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;


import 'features/alarm/models/medicine_model.dart';
import 'firebase_options.dart';
import 'notification_service.dart';
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appDocumentDir = await getApplicationDocumentsDirectory();
  await Hive.initFlutter(appDocumentDir.path);
  Hive.registerAdapter(MedicineAdapter());
  Hive.registerAdapter(DoseAdapter());
  await Hive.openBox<Medicine>('medicinesBox');
  tz.initializeTimeZones();
  const AndroidInitializationSettings initializationSettingsAndroid =
  AndroidInitializationSettings('@mipmap/ic_launcher'); // تأكد من وجود هذه الأيقونة

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );
  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse notificationResponse) async {
      final String? payload = notificationResponse.payload;
      if (payload != null) {
        debugPrint('notification payload (main): $payload');
      }
    },
  );
  try {
    final bool? result = await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
        ?.requestPermission(); // هذه الدالة يجب أن تكون معرفة الآن
    debugPrint("Notification permission granted (main): $result");
  } catch (e) {
    debugPrint("Error requesting notification permission: $e");
  }

  initServiceLocator();
  await sl<CacheHelper>().init();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  // Initialize notification service
  final notificationService = NotificationService();
  await notificationService.initNotifications();
  await notificationService.setupInitialMessage();


  runApp(

    MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => sl<GlobalCubit>()..getCacheLang(),
        ),
        BlocProvider(
          create: (context) => sl<LoginCubit>(),
        ),
        BlocProvider(
          create: (context) => sl<RegisterCubit>(),
        ),
        BlocProvider(
          create: (context) => sl<ForgetPasswordCubit>(),
        ),
        BlocProvider(
          create: (context) => sl<HomeCubit>(),
        ),
        BlocProvider(
          create: (context) => sl<RegisterSendCodeCubit>(),
        ),

        BlocProvider(
          create: (context) => sl<ArticlesCubit>()..getAllArticles(),
        ),
        BlocProvider(
          create: (context) => sl<SettingCubit>()..getProfile(),
        ),



      ],
      child: const MyApp(),
    ),
  );
}
extension on AndroidFlutterLocalNotificationsPlugin? {
  requestPermission() {}
}