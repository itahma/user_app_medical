import 'package:carousel_slider/carousel_controller.dart' as carousel_pkg;
import 'package:carousel_slider/carousel_slider.dart' show CarouselSliderController;
import 'package:flutter/material.dart';
import 'package:newappgradu/core/routes/app_routes.dart';
import 'package:newappgradu/core/utils/app_assets.dart';
import '../../../../core/utils/app_string.dart';

class HomeSection {
  final String title;
  final String icon;
  final String rote;

  HomeSection({
    required this.icon,
    required this.title,
    required this.rote,
  });
}
class HomeSectionS {
  final String title;
  final String icon;


  HomeSectionS({
    required this.icon,
    required this.title,

  });
}

final List<HomeSectionS> section = [
  HomeSectionS(icon: AppAssets.heart1, title: AppString.cardiology), // قلبية
  HomeSectionS(icon: AppAssets.bodyUpper, title: AppString.dermatology), // جلدية
  HomeSectionS(icon: AppAssets.brain, title: AppString.neurology), // عصبية
  HomeSectionS(icon: AppAssets.baby, title: AppString.pediatrics), // أطفال
  HomeSectionS(icon: AppAssets.female, title: AppString.gynecology), // نسائية
  HomeSectionS(icon: AppAssets.eye, title: AppString.ophthalmology), // عينية
  HomeSectionS(icon: AppAssets.tooth, title: AppString.dentist), // أسنان
  HomeSectionS(icon: AppAssets.ear, title: AppString.otolaryngologist), // أنف أذن حنجرة
  HomeSectionS(icon: AppAssets.stomach, title: AppString.gastroenterologist), // هضمية
  HomeSectionS(icon: AppAssets.first, title: AppString.generalSurgery), // جراحة عامة
  HomeSectionS(icon: AppAssets.first, title: AppString.hematology), // دم
  HomeSectionS(icon: AppAssets.ball, title: AppString.orthopedics), // عظمية
  HomeSectionS(icon: AppAssets.male_head, title: AppString.psychiatry), // نفسي
  HomeSectionS(icon: AppAssets.excretory, title: AppString.nephrology), // كلى
  HomeSectionS(icon: AppAssets.first, title: AppString.oncology), // طب الأورام
];

final List<HomeSection> listGrid = [
  HomeSection(icon: AppAssets.building, title:'مجموعة الاطباء ', rote:Routes.healthCentersMenu),
  HomeSection(icon: AppAssets.microscope, title: AppString.laboratories,rote:Routes.laboratoriesMenu),
  HomeSection(icon: AppAssets.hand, title: AppString.radiologyCenters,rote:Routes.radiologyCenterItemMenu),
];

class HomeMenuModel {
  final String image;

  HomeMenuModel({
    required this.image,
  });
}
final CarouselSliderController? controller = CarouselSliderController();



final List<HomeMenuModel> listHome = [
  HomeMenuModel(image: AppAssets.onBoarding1),
  HomeMenuModel(image: AppAssets.onBoarding2),
  HomeMenuModel(image: AppAssets.onBoarding3),
  HomeMenuModel(image: AppAssets.onBoarding4),
];

int currentIndex = 0;
