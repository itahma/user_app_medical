import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'app_colors.dart';
TextStyle _textStyle({
  required Color color ,
  required double fontSize,
  required FontWeight fontWeight,

}){
  return GoogleFonts.lato(
    color:color,
    fontSize: fontSize.sp,
    fontWeight: fontWeight,

  );


}
//bold Style
TextStyle boldStyle({
   Color color =AppColors.white,
   double fontSize=24,

})=>_textStyle(
    color: Colors.black,
    fontSize: 24,
    fontWeight: FontWeight.bold);
//regular Style
TextStyle regularStyle({
  Color color =AppColors.white,
  double fontSize=24,

})=>_textStyle(
    color: Colors.white,
    fontSize: 24,
    fontWeight: FontWeight.normal);
TextStyle blueStyle({
  Color color =AppColors.primary,
  double fontSize=22,

})=>_textStyle(
    color: AppColors.primary,
    fontSize: 22,
    fontWeight: FontWeight.normal);