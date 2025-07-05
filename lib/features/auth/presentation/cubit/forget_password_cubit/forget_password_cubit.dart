
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:newappgradu/features/auth/data/repository/auth_repository.dart';

import 'forget_password_state.dart';

class ForgetPasswordCubit extends Cubit<ForgetPasswordState> {
  ForgetPasswordCubit(this.authRepository) : super(ForgetPasswordInitial());
  final AuthRepository authRepository;
  GlobalKey<FormState>sendCodeKey = GlobalKey<FormState>(debugLabel: '2');

  TextEditingController emailController = TextEditingController();

  void sendCode() async {
    emit(SendCodeLoading());
    final res = await authRepository.sendCode(emailController.text);

    res.fold((l) => emit(SendCodeErrore(l)), (r) => emit(SendCodeSuccess(r)));
  }

  //NewPassword
  GlobalKey<FormState>resetPasswordKey = GlobalKey<FormState>(debugLabel: '1');
  TextEditingController newPasswordController = TextEditingController();
  bool isNewPasswordShowing = true;
  IconData suffixIconNewPassword = Icons.visibility;

  void changeNewPasswordSuffixIcon() {
    isNewPasswordShowing = !isNewPasswordShowing;
    suffixIconNewPassword =
    isNewPasswordShowing ? Icons.visibility : Icons.visibility_off;
    emit(ChangeNewPasswordSuffixIcon());
  }
//ConfirmPassword
  TextEditingController confirmPasswordController = TextEditingController();
  bool isConfirmPasswordShowing = true;
  IconData suffixIconConfirmPassword = Icons.visibility;

  void changeConfirmPasswordSuffixIcon() {
    isConfirmPasswordShowing = !isConfirmPasswordShowing;
    suffixIconConfirmPassword =
    isConfirmPasswordShowing ? Icons.visibility : Icons.visibility_off;
    emit(ChangeConfirmPasswordSuffixIcon());


  }

  // code
  TextEditingController codeController = TextEditingController();

  //change password method that recive new password and confirm password and code and email
  void resetPassword() async {
    emit(ResetPasswordLoading());
    final res = await authRepository.resetPassword(
      email:  emailController.text,
      password: newPasswordController.text,
      code: codeController.text,

    );
    res.fold((l) => emit(ResetPasswordErrore(l)),
            (r) => emit(ResetPasswordSuccess(r)));
  }

}
