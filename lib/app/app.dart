import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:flutter_localizations/flutter_localizations.dart';


import '../core/bloc/cubit/global_cubit.dart';
import '../core/bloc/cubit/global_state.dart';
import '../core/local/app_local.dart';
import '../core/routes/app_routes.dart';
import '../core/theme/App_theme.dart';

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
        designSize: const Size(428, 926),
        builder: (context, child) =>
            BlocBuilder<GlobalCubit, GlobalState>(
              builder: (context, state) {
                return BlocBuilder<GlobalCubit, GlobalState>(
                  builder: (context, state) {
                    return MaterialApp(
                      // navigatorKey: NavigationService.navigatorKey,
                        localizationsDelegates: const [
                          GlobalMaterialLocalizations.delegate,
                          GlobalCupertinoLocalizations.delegate,
                          GlobalWidgetsLocalizations.delegate,
                          AppLocalizations.delegate,
                          // Add other delegates here
                        ],
                        supportedLocales: const [
                          Locale('ar', ''),
                          Locale('en', 'US'),
                        ],
                        locale:  Locale(BlocProvider.of<GlobalCubit>(context).langCode),
                        initialRoute: Routes.intitlRoute,
                        onGenerateRoute: AppRoutes.generateRoute,
                        debugShowCheckedModeBanner: false,
                        theme: getAppTheme()

                    );
                  },
                );
              },
            )
    );
  }
}
