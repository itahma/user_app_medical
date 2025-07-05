import 'package:newappgradu/features/profile/data/models/profile_model.dart';

sealed class SettingState {}

final class SettingInitial extends SettingState {}

final class LoadingProfile extends SettingInitial {}

final class LoadedProfile extends SettingInitial {
  ProfileModel profileModel;
  LoadedProfile(this.profileModel);
}

final class ErrorLoadProfile extends SettingInitial {
  String error;
  ErrorLoadProfile(this.error);
}
