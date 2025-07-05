import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:newappgradu/core/bloc/cubit/global_cubit.dart';
import 'package:newappgradu/core/local/app_local.dart';
import 'package:newappgradu/core/routes/app_routes.dart';
import 'package:newappgradu/core/service/service_locatro.dart';
import 'package:newappgradu/core/utils/app_assets.dart';
import 'package:newappgradu/core/utils/app_colors.dart';
import 'package:newappgradu/core/utils/commons.dart';
import '../../../../core/database/cache/cache_helper.dart';
import '../../../../core/utils/app_string.dart';
import '../../../../core/widget/customimage.dart';
class SettingScreen extends StatefulWidget {
  SettingScreen({Key? key}) : super(key: key);

  @override
  _SettingScreenState createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  bool _switchValue  =  sl<CacheHelper>().getCachedLanguage()=="en"??false;
  bool _switchValueAr = sl<CacheHelper>().getCachedLanguage()=="ar"??false;

  void _onSwitchChanged(bool value) {

        _switchValue=value;
        BlocProvider.of<GlobalCubit>(context).changeLang(
              "en");
       _switchValueAr=false;

  }
  void _onSwitchChangedAr(bool value) {

        _switchValueAr = value;
        BlocProvider.of<GlobalCubit>(context).changeLang(
            "ar");
        _switchValue=false;


  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(

          elevation: 0,
          title: Text(
            AppString.medDose,
            style: Theme.of(context).textTheme.displayMedium,
          ),
        ),
        body:SingleChildScrollView(
          child: Center(
            child: Column(
              // crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Center(
                  child: SizedBox(
                    width: 300.w,
                    height: 300.h,
                    child: const CustomImage(
                      imagePath: AppAssets.logoIm,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                       Padding(
                         padding: const EdgeInsets.only(left: 16,right: 16),
                         child: Text(AppString.applicationLanguage.tr(context)
                         ,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                      ),
                       ),
                      const SizedBox(height: 16),
                      SwitchListTile(
                        title:  Text(AppString.en.tr(context)),
                        value: _switchValue,
                        onChanged: _onSwitchChanged,
                        activeColor: AppColors.primary,
                        activeTrackColor: Colors.blueAccent,
                        inactiveTrackColor: Colors.grey[300],
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                        secondary: const Icon(Icons.language,color: AppColors.primary,),
                      ),
                      const SizedBox(height: 8),
                      SwitchListTile(
                        title:  Text(AppString.ar.tr(context)),
                        value: _switchValueAr,
                        onChanged: _onSwitchChangedAr,
                        activeColor:  AppColors.primary,
                        activeTrackColor: Colors.blueAccent,
                        inactiveTrackColor: Colors.grey[300],
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                        secondary:  Icon(Icons.language,color: AppColors.primary,),
                      ),
                      const SizedBox(height: 16),
                       Divider(thickness: 2,color: Colors.blue.shade50),
                      // const SizedBox(height: 16),

                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: GestureDetector(
                    onTap: () {
                      navigateReplacement(context: context, route: Routes.sendCode);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xff91BAEF).withOpacity(.2),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      //Border.all
                      height: 55,
                      child:  Padding(
                        padding: const EdgeInsets.all(10),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.password,
                              size: 25,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 30),
                            Text(
                              AppString.passwordChanged.tr(context),
                              style: const TextStyle(color: AppColors.grey, fontSize: 18),
                            )

                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: GestureDetector(
                    onTap: () {
                      navigateReplacement(context: context, route: Routes.updateProfile);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xff91BAEF).withOpacity(.2),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      //Border.all
                      height: 55,
                      child:  Padding(
                        padding: const EdgeInsets.all(10),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.person,
                              size: 25,
                              color: AppColors.primary,
                            ),
                            const SizedBox(width: 30),
                            Text(
                             "تعديل الملف الشخصي ",
                              style: const TextStyle(color: AppColors.grey, fontSize: 18),
                            )

                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: InkWell(
                    onTap: ()async{
                      await sl<CacheHelper>().clearData();
                      navigate(context: context, route: Routes.login);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.red),
                        color:  Colors.red.withOpacity(.2),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      //Border.all
                      height: 55,
                      child:  Padding(
                        padding: const EdgeInsets.all(10),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.power_settings_new,
                              size: 25,
                              color: Colors.red,
                            ),
                            const SizedBox(width: 30),
                            Text(
                              AppString.logOut.tr(context),
                              style: const TextStyle(color: AppColors.grey, fontSize: 18),
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                TextButton(onPressed: (){}
                  , child: Text(AppString.deleteAccount.tr(context),
                    style: const TextStyle(fontSize: 16,color:Colors.red),
                  ),
                ),

              ],
            ),
          ),
        ),

      ),
    );
  }
}