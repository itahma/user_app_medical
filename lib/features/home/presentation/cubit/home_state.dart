sealed class HomeState {}

final class HomeInitial extends HomeState {}

final class ChangeIndexstate extends HomeState {}

final class LoadingHomeState extends HomeState {}

final class ErorrHomeState extends HomeState {
  final String error;

  ErorrHomeState(this.error);
}

final class LoadedHomeState extends HomeState {}
