import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:newappgradu/features/articles/presentation/screen/Articles_screen.dart';

import 'package:newappgradu/features/favorite/screen/Favorite_screen.dart';
import 'package:newappgradu/features/help/screen/help_screen.dart';
import 'package:newappgradu/features/home/data/models/Specialist_model.dart';
import 'package:newappgradu/features/home/data/repository/home_repository.dart';
import 'package:newappgradu/features/home_menu/presintion/screen/home_menu.dart';
import 'package:newappgradu/features/profile/presentation/secreen/profile_home_screen.dart';

import '../../../myConsultations/presentation/conversations_list_page.dart';
import 'home_state.dart';

class HomeCubit extends Cubit<HomeState> {
  HomeCubit(this.homeRepository) : super(HomeInitial());
  final HomeRepository homeRepository;
  List<Widget> screens = [
    const ConversationsListPage(),
    const AllPostsPage(),
    const MenuHomeScreen(),
    const FavoriteScreen(),
    const ProfileHome(),
  ];
  int currentIndex = 2;
 TextEditingController search=TextEditingController();
  changeIndex(index) {
    currentIndex = index;
    emit(ChangeIndexstate());
  }

  //login method

  List<SpecialistModel>? specialistModel;

  void getAllSpecialist() async {
    emit(LoadingHomeState());
    final result = await homeRepository.getAllSpecialist();
    result.fold((l) => emit(ErorrHomeState(l.toString())), (r) {
      specialistModel = r;
    });
    emit(LoadedHomeState());
  }
}
