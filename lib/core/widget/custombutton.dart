import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:newappgradu/core/utils/app_colors.dart';

class CustomButton extends StatelessWidget {
  const CustomButton({Key? key,
    this.height=48,
     this.width=double.infinity,
    required this.onPressed,
    this.background,
    required this.text,
  }) : super(key: key);
final double ? height;
final double ? width;
final VoidCallback onPressed;
final Color? background;
final String text ;
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height!.h,
      width: width!.w,
      child: ElevatedButton(

        onPressed: onPressed,
        style: Theme.of(context).elevatedButtonTheme.style!.copyWith(
          backgroundColor: MaterialStateProperty.all(
            background ?? AppColors.primary
            ,
          )
        ),
        child: Text(
          text,

        ),

      ),

    );
  }
}
