sealed class ForgetPasswordState {}

final class ForgetPasswordInitial extends ForgetPasswordState {}

final class ChangeNewPasswordSuffixIcon extends ForgetPasswordState {}

final class ChangeConfirmPasswordSuffixIcon extends ForgetPasswordState {}

final class SendCodeLoading extends ForgetPasswordState {}

final class SendCodeErrore extends ForgetPasswordState {
  final String message;
  SendCodeErrore(this.message);
}

final class SendCodeSuccess extends ForgetPasswordState {
  final String message;
  SendCodeSuccess(this.message);
}
//resetPassword

final class ResetPasswordLoading extends ForgetPasswordState {}

final class ResetPasswordErrore extends ForgetPasswordState {
  final String message;
  ResetPasswordErrore(this.message);
}

final class ResetPasswordSuccess extends ForgetPasswordState {
  final String message;
  ResetPasswordSuccess(this.message);
}
