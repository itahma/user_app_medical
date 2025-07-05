import 'package:flutter/material.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/database/cache/cache_helper.dart';
import '../../../../core/utils/app_string.dart';

import '../component/gnav_component.dart';
import '../cubit/home_cubit.dart';
import '../cubit/home_state.dart';
class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text(AppString.medDose,style: Theme.of(context).textTheme.displayMedium,) ,
            leading: IconButton(onPressed: (){},icon: const Icon(Icons.notifications)),
            elevation: 0,

          ),
          body:  BlocProvider.of<HomeCubit>(context).screens[ BlocProvider.of<HomeCubit>(context).currentIndex],
          bottomNavigationBar:const GNavComponent(),
        );
      },
    );
  }
}


