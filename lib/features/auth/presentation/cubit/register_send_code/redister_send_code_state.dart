
sealed class RegisterSendCodeState {}

final class RegisterSendCodeInitial extends RegisterSendCodeState {}
final class RegisterSendCodeSuccess extends RegisterSendCodeState {
final String maseg;
RegisterSendCodeSuccess(this.maseg);
}
final class RegisterSendCodeLoading extends RegisterSendCodeState {}
final class RegisterSendCodeError extends RegisterSendCodeState {
  final String maseg;
  RegisterSendCodeError(this.maseg);

}
