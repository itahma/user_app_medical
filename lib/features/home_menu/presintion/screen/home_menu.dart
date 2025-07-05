import 'dart:ui';


import 'package:carousel_slider/carousel_slider.dart';
import 'package:carousel_slider/carousel_slider.dart' show CarouselOptions, CarouselSlider;
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:newappgradu/core/local/app_local.dart';
import 'package:newappgradu/core/routes/app_routes.dart';
import 'package:newappgradu/core/utils/app_colors.dart';
import 'package:newappgradu/core/utils/app_string.dart';
import 'package:newappgradu/core/utils/commons.dart';
import 'package:newappgradu/core/widget/customimage.dart';
import 'package:newappgradu/features/home_menu/data/model/home_menu_model.dart';
import '../../../../core/widget/custom_text_form_field.dart';

class MenuHomeScreen extends StatefulWidget {
  const MenuHomeScreen({Key? key}) : super(key: key);

  @override
  State<MenuHomeScreen> createState() => _MenuHomeScreenState();
}

class _MenuHomeScreenState extends State<MenuHomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    AppString.welcomeBack.tr(context),
                    style: const TextStyle(fontSize: 25, color: Color(0xff063970)),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  AppString.howDoYouFeel.tr(context),
                  style: const TextStyle(fontSize: 19, color: Color(0xff063970)),
                ),
              ),
              CustomTextFormField(
                controller: TextEditingController(),
                onTap: () {
                  navigate(context: context, route: Routes.searchScreen);
                },
                hint: AppString.whatAreYouLookingFor.tr(context),
                icon: Icons.search,
                validate: (data) {},
                readOnly: true, // منع ظهور لوحة المفاتيح
              ),

              const SizedBox(height: 30),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: AppColors.primary,
                ),
                child:CarouselSlider(
                  carouselController: controller,
                  items: listHome.map((e) => buildBoardingItem(e)).toList(),
                  options:CarouselOptions(
                    height: 200.0,
                    autoPlay: true,
                    enableInfiniteScroll: true,
                    enlargeCenterPage: true,
                    onPageChanged: (index, _) {
                      setState(() {
                        currentIndex = index;
                      });
                    },
                  ),
                ),
              ),

              Divider(thickness: 2, color: Colors.blue.shade50),
              // SizedBox(
              //   height: 100,
              //   // Provide a height constraint
              //   child: ListView.builder(
              //     physics: const BouncingScrollPhysics(),
              //     itemBuilder: (context, index) {
              //       return Padding(
              //         padding: const EdgeInsets.all(8.0),
              //         child: InkWell(
              //           onTap: () {
              //             Navigator.push(
              //                 context,
              //                 MaterialPageRoute(
              //                   builder: (_) => DoctorCenterMenu(
              //                     sec: section[index].title,
              //                     id: HomeSection.,
              //                   ),
              //                 ));
              //           },
              //           child: Container(
              //             decoration: BoxDecoration(
              //                 color: const Color(0xff91BAEF).withOpacity(.2),
              //                 borderRadius: BorderRadius.circular(15)),
              //             width: 80,
              //             child: Column(
              //               children: [
              //                 const SizedBox(
              //                   height: 10,
              //                 ),
              //                 SvgPicture.asset(
              //                   height: 40.0.h,
              //                   width: 40.0.w,
              //                   allowDrawingOutsideViewBox: true,
              //                   section[index].icon,
              //                   color: AppColors.primary,
              //                   matchTextDirection: true,
              //                 ),
              //                 Text(
              //                   section[index].title.tr(context),
              //                   overflow: TextOverflow.ellipsis,
              //                 ),
              //               ],
              //             ),
              //           ),
              //         ),
              //       );
              //     },
              //     itemCount: section.length,
              //     scrollDirection: Axis.horizontal,
              //   ),
              // ),
              SizedBox(
                height: 200,
                child: GridView.builder(
                  padding: const EdgeInsets.all(6),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 250,
                    childAspectRatio: 3 / 2,
                    crossAxisSpacing: 15,
                    mainAxisSpacing: 15,
                    mainAxisExtent: 75,
                  ),
                  physics: const BouncingScrollPhysics(),
                  itemCount: listGrid.length,
                  itemBuilder: (context, index) {
                    return InkWell(
                      onTap: () {



                        navigate(context: context, route: listGrid[index].rote);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: AppColors.primary.withOpacity(.8),
                          borderRadius: BorderRadius.circular(15),
                        ),
                        alignment: Alignment.center,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              listGrid[index].title.tr(context),
                              style: const TextStyle(color: AppColors.white),
                            ),
                            SvgPicture.asset(
                              height: 45.0.h,
                              width: 45.0.w,
                              listGrid[index].icon,
                              color: AppColors.white,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildBoardingItem(HomeMenuModel model) => CustomImage(
    fit: BoxFit.cover,
    imagePath: model.image,
  );
}
