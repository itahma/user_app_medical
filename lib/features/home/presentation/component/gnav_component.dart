import 'package:curved_labeled_navigation_bar/curved_navigation_bar.dart';
import 'package:curved_labeled_navigation_bar/curved_navigation_bar_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:newappgradu/core/local/app_local.dart';
import 'package:newappgradu/core/utils/app_colors.dart';
import 'package:newappgradu/core/utils/app_string.dart';
import '../cubit/home_cubit.dart';

class GNavComponent extends StatelessWidget {
  const GNavComponent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CurvedNavigationBar(
      index:BlocProvider.of<HomeCubit>(context).currentIndex,

      backgroundColor:  AppColors.primary.withOpacity(.8),

      items: [

        CurvedNavigationBarItem(
           labelStyle: const TextStyle(color: AppColors.primary),
          child: const Icon(Icons.chat_outlined),
          label:"استشاراتي ",
        ),
        CurvedNavigationBarItem(
          labelStyle: const TextStyle(color: AppColors.primary),
          child: const Icon(Icons.article_outlined, ),
          label: AppString.article.tr(context),
        ),
        CurvedNavigationBarItem(
          labelStyle: const TextStyle(color: AppColors.primary),
          child: const Icon(Icons.home_outlined),
          label: AppString.home.tr(context),
        ),
        CurvedNavigationBarItem(
          labelStyle: const TextStyle(color: AppColors.primary),
          child: const Icon(Icons.monitor_heart_outlined),
          label: AppString.content.tr(context),
        ),
        CurvedNavigationBarItem(
          labelStyle: const TextStyle(color: AppColors.primary),
          child: const Icon(Icons.person_2_outlined),
          label: AppString.profile.tr(context),
        ),
      ],
      onTap: (value) {
        BlocProvider.of<HomeCubit>(context).changeIndex(value);

      },
    );
  }
}
