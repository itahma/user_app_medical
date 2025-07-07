import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:newappgradu/core/local/app_local.dart';
import 'package:newappgradu/core/routes/app_routes.dart';
import 'package:newappgradu/core/utils/app_assets.dart';
import 'package:newappgradu/core/utils/app_colors.dart';
import 'package:newappgradu/core/widget/customimage.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import '../../../../core/bloc/cubit/global_cubit.dart';
import '../../../../core/bloc/cubit/global_state.dart';
import '../../../../core/utils/app_string.dart';
import 'login_screen_patient.dart';

class BoardingModel {
  final String image;
  final String body;

  BoardingModel({
    required this.body,
    required this.image,
  });
}
class OnBoarding1Screen extends StatefulWidget {
  const OnBoarding1Screen({Key? key}) : super(key: key);

  @override
  State<OnBoarding1Screen> createState() => _OnBoarding1ScreenState();
}

class _OnBoarding1ScreenState extends State<OnBoarding1Screen> {
  var boardController = PageController();

  late List<BoardingModel>boarding = [
    BoardingModel(

      image: AppAssets.onBoarding1,
      body: AppString.pageOne,

    ),
    BoardingModel(
      image: AppAssets.onBoarding2,
      body:AppString.pageTow,
    ),
    BoardingModel(
      image: AppAssets.onBoarding3,
      body: AppString.pageThree,
    ),
    BoardingModel(
      image: AppAssets.onBoarding4,
      body: AppString.pageFour,
    ),
  ];


  bool isLast = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => const LoginScreenPatient()), // استبدلها بالشاشة الرئيسية لديك
                      (route) => false,
                );
              },
              child: Text(AppString.skip.tr(context),
                  style: const TextStyle(color: AppColors.blue)),
            ),
          ],
          leading: BlocBuilder<GlobalCubit, GlobalState>(
            builder: (context, state) {
              return IconButton(
                icon: const Icon(
                    Icons.language, color: AppColors.white),

                onPressed: () {

                  BlocProvider.of<GlobalCubit>(context).changeLang(
                      BlocProvider.of<GlobalCubit>(context).langCode=="en"?"ar":"en");


                },
              );
            },
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            children: [
              Expanded(
                child: PageView.builder(
                  physics: const BouncingScrollPhysics(),
                  onPageChanged: (int index) {
                    if (index == boarding.length - 1) {
                      setState(() {
                        isLast = true;
                      });
                    } else {
                      setState(() {
                        isLast = false;
                      });
                    }
                  },
                  controller: boardController,
                  itemBuilder: (context, index) =>
                      buildBoardingItem(context, boarding[index]),
                  itemCount: boarding.length,
                ),
              ),
              const SizedBox(height: 40,),
              Row(
                children: [
                  SmoothPageIndicator(
                    effect: const ExpandingDotsEffect(
                      dotColor: AppColors.grey,
                      activeDotColor: AppColors.blue,
                      dotHeight: 10,
                      expansionFactor: 4,
                      dotWidth: 10,
                      spacing: 5,

                    ),
                    controller: boardController,
                    count: boarding.length,
                  ),
                  const Spacer(),
                  FloatingActionButton(
                    backgroundColor: AppColors.white,
                    onPressed: () {
                      if (isLast) {
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(builder: (context) => const LoginScreenPatient()), // استبدلها بالشاشة الرئيسية لديك
                              (route) => false,
                        );
                      }
                      else {
                        boardController.nextPage(
                          duration: const Duration(
                            microseconds: 750,
                          ),
                          curve: Curves.fastLinearToSlowEaseIn,
                        );
                      }
                    },
                    child: const Icon(Icons.arrow_forward_ios),
                  ),
                ],
              ),

            ],
          ),
        )

    );
  }
}

Widget buildBoardingItem(BuildContext context, BoardingModel model) =>
    Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          child: CustomImage(
            imagePath: model.image,
          ),
        ),
        Text(
         AppLocalizations.of(context)!.translate( model.body)
          , style: const TextStyle(
          fontSize: 20,
          color: Colors.blue,
          fontWeight: FontWeight.bold,
        ),
        ),
      ],
    );
