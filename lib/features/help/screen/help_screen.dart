import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:newappgradu/core/local/app_local.dart';
import 'package:newappgradu/core/utils/app_assets.dart';
import 'package:newappgradu/core/utils/app_colors.dart';
import 'package:url_launcher/url_launcher.dart' as launcher;

import '../../../core/utils/app_string.dart';
import '../../../core/widget/custombutton.dart';
import '../../../core/widget/customimage.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(AppString.medDose,style: Theme.of(context).textTheme.displayMedium,) ,

          elevation: 0,

        ),
        body: SingleChildScrollView(
          child: Center(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
                padding: const EdgeInsets.only(left: 10),
                child: Text(
                  AppString.aboutApp.tr(context),
                  style: const TextStyle(
                    fontSize: 18,
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: InkWell(
                  onTap: () async {
                    Uri uri = Uri.parse(
                      'mailto:info@rapidtech.dev?subject=Flutter Url launcher&body=Hi, Flutter developer',
                    );
                    if (!await launcher.launchUrl(uri)) {
                      debugPrint("Could not launch the uri ");
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xff91BAEF).withOpacity(.2),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    //Border.all
                    height: 55,
                    child: const Padding(
                      padding: EdgeInsets.all(10),
                      child: Row(
                        children: [
                          Icon(
                            Icons.email_outlined,
                            size: 30,
                            color: AppColors.primary,
                          ),
                          SizedBox(width: 30),
                          Text(
                            'info@gmail.com',
                            style: TextStyle(color: AppColors.grey, fontSize: 18),
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
                  onTap: () async {
                    Uri uri = Uri.parse('tel:+963-962-694065');
                    if (!await launcher.launchUrl(uri)) {
                      debugPrint("Could not launch the uri ");
                    }
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xff91BAEF).withOpacity(.2),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    //Border.all
                    height: 55,
                    child: const Padding(
                      padding: EdgeInsets.all(10),
                      child: Row(
                        children: [
                          Icon(
                            Icons.phone_outlined,
                            size: 30,
                            color: AppColors.primary,
                          ),
                          SizedBox(
                            width: 30,
                          ),
                          Text('+963-962-694065 ',
                              style:
                                  TextStyle(color: AppColors.grey, fontSize: 18))
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Text(
                  AppString.contactUs.tr(context),
                  style: const TextStyle(
                    fontSize: 18,
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  AppString.ifCan.tr(context),
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 18,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(13),
                child: CustomButton(
                  onPressed: () async {
                    Uri uri = Uri.parse('tel:+963-962-694065');
                    if (!await launcher.launchUrl(uri)) {
                      debugPrint("Could not launch the uri ");
                    }
                  },
                  text: AppString.contactUs.tr(context),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
