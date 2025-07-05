import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:newappgradu/core/database/api/end_points.dart';
import 'package:newappgradu/core/database/cache/cache_helper.dart';
import 'package:newappgradu/core/local/app_local.dart';
import 'package:newappgradu/core/routes/app_routes.dart';
import 'package:newappgradu/core/utils/app_assets.dart';
import 'package:newappgradu/core/utils/app_colors.dart';
import 'package:newappgradu/core/utils/commons.dart';

import '../../../../core/service/service_locatro.dart';
import '../../../../core/widget/customimage.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  void initState(){
    navigateAfterThreeSeconds();
    super.initState();
  }
  void navigateAfterThreeSeconds(){
    Future.delayed(const Duration(seconds: 3)).then((value) async{
     await sl<CacheHelper>().getData(key: ApiKeys.token,
     )==null
         ?navigate(context: context, route: Routes.onBoarding1Screen)
         :navigate(context: context, route: Routes.home);
    });
  }
  @override

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body:Center(
        child: CustomImage(
          imagePath: AppAssets.logoIm,
        ),
      )

    );
  }
}
