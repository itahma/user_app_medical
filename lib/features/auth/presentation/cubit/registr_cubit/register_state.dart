
sealed class RegisterState {}

final class RegisterInitial extends RegisterState {}
final class ChangeGroupState extends RegisterState {}
final class SendCodeRegisterLoading extends RegisterState {}
final class SendCodeRegisterError extends RegisterState {
final String message;
SendCodeRegisterError(this.message);
}
final class RegisterSendCodeSucess extends RegisterState {
final String message;
RegisterSendCodeSucess(this.message);
}
final class RegisterLoadingState extends RegisterState {}
final class RegisterSucessState extends RegisterState {

}
final class RegisterErrorState extends RegisterState {
final String message;
RegisterErrorState(this.message);

}
final class ChangeRegisterPasswordSuffixIcon extends RegisterState {}
final class ChangeRegisterConfirmPasswordSuffixIcon extends RegisterState {}
