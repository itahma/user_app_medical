import 'package:flutter/material.dart';

class CustomImage extends StatelessWidget {
  const CustomImage({Key? key, required this.imagePath, this.h, this.w, this.fit}) : super(key: key);
final String imagePath;
final double ? h;
final double ? w;
final BoxFit ?fit;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
        imagePath,
      width: w,
      height: h,
      fit: fit,



    );
  }
}
