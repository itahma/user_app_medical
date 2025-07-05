import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

import '../utils/app_colors.dart';

class CustomCachedNetworkImage extends StatelessWidget {
  const CustomCachedNetworkImage({Key? key, required this.imageUrl, this.fit}) : super(key: key);
 final String imageUrl;
 final BoxFit? fit;

  @override
  Widget build(BuildContext context) {
    return  CachedNetworkImage(

      fit: fit,
      imageUrl: imageUrl,
      placeholder: (context, url) => SpinKitFadingCircle(color: AppColors.primary,),
      errorWidget: (context, url, error) => Icon(Icons.error),
    );
  }
}
