

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:newappgradu/features/profile/data/repository/profile_repository.dart';

import 'setting_state.dart';

class SettingCubit extends Cubit<SettingState> {
  SettingCubit(this.profileRepository) : super(SettingInitial());
ProfileRepository profileRepository;
  void getProfile() async {
    emit(LoadingProfile());
    final result = await profileRepository.getProfile();
    result.fold((l) => emit(ErrorLoadProfile(l.toString())), (r) {
      emit(LoadedProfile(r));
    });
  }
  }

