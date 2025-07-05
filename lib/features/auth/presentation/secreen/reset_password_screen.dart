import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:newappgradu/core/local/app_local.dart';
import 'package:newappgradu/core/utils/app_colors.dart';
import 'package:newappgradu/core/widget/customimage.dart';
import 'package:newappgradu/features/auth/presentation/cubit/forget_password_cubit/forget_password_cubit.dart';

import '../../../../core/routes/app_routes.dart';
import '../../../../core/utils/app_assets.dart';
import '../../../../core/utils/commons.dart';
import '../../../../core/utils/app_string.dart';
import '../../../../core/widget/custom_text_form_field.dart';
import '../../../../core/widget/custombutton.dart';
import '../cubit/forget_password_cubit/forget_password_state.dart';

class ReSetPassword extends StatelessWidget {
  const ReSetPassword({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon:const Icon(Icons.arrow_back_ios),onPressed: (){
          navigateReplacement(context: context, route: Routes.sendCode);
        }),
        elevation: 0.0,
        title: Text(AppString.createYourNewPassword.tr(context)),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: BlocConsumer<ForgetPasswordCubit, ForgetPasswordState>(
            listener: (context, state) {
              if(state is ResetPasswordSuccess){
                showToast(message: AppString.passwordChangedSucessfully.tr(context), state: ToastState.success);
                navigateReplacement(context: context, route: Routes.login);
              }
              if(state is ResetPasswordErrore){
                showToast(
                    message: AppString.loginFailed.tr(context),
                    state: ToastState.error);

              }

            },
            builder: (context, state) {
              return Form(
                key: BlocProvider.of<ForgetPasswordCubit>(context).resetPasswordKey,
                child: Column(
                  children: [
                    Stack(
                      alignment: AlignmentDirectional.center,
                      children: [
                        const CustomImage(
                          imagePath: AppAssets.loginImage,
                          w: double.infinity,
                        ),
                        SizedBox(

                          width: 300.w,
                          height: 300.h,
                          child: const CustomImage(
                            imagePath: AppAssets.logoIm,
                          ),
                        ),
                      ],
                    ),
                    Text(AppString.createYourNewPassword.tr(context),
                      style: Theme
                          .of(context)
                          .textTheme
                          .bodyLarge,),
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(children: [
                        //password
                        CustomTextFormField(
                          controller: BlocProvider.of<ForgetPasswordCubit>(context)
                              .newPasswordController,
                          hint: AppLocalizations.of(context)!
                              .translate(AppString.newPassword),
                          hitColors: AppColors.grey,
                          isPassword: BlocProvider.of<ForgetPasswordCubit>(context)
                              .isNewPasswordShowing,
                          icon:
                          BlocProvider.of<ForgetPasswordCubit>(context).suffixIconNewPassword,
                          suffixIconOnPressed: () {
                            BlocProvider.of<ForgetPasswordCubit>(context)
                                .changeNewPasswordSuffixIcon();
                          },
                          validate: (data) {
                            if (data!.length < 6 || data.isEmpty) {
                              return AppString.pleaseEnterValidPassword
                                  .tr(context);
                            }
                            return null;
                          },
                        ),
                        //confirmPassword
                        SizedBox(height: 26.h,),
                        CustomTextFormField(
                          controller: BlocProvider.of<ForgetPasswordCubit>(context)
                              .confirmPasswordController,
                          hint: AppString.confirmPassword.tr(context),
                          hitColors: AppColors.grey,
                          isPassword: BlocProvider.of<ForgetPasswordCubit>(context)
                              .isConfirmPasswordShowing,
                          icon:
                          BlocProvider.of<ForgetPasswordCubit>(context).suffixIconConfirmPassword,
                          suffixIconOnPressed: () {
                            BlocProvider.of<ForgetPasswordCubit>(context)
                                .changeConfirmPasswordSuffixIcon();
                          },
                          validate: (data) {

                            if(data!= BlocProvider.of<ForgetPasswordCubit>(context).newPasswordController.text){
                              return AppString.pleaseEnterValidPassword
                                  .tr(context);
                            }
                            if (data!.length < 6 || data.isEmpty) {
                              return AppString.pleaseEnterValidPassword
                                  .tr(context);
                            }

                            return null;
                          },
                        ),
                        SizedBox(height: 26.h,),
                        //code

                        CustomTextFormField(
                          controller: BlocProvider.of<ForgetPasswordCubit>(context)
                              .codeController,
                          hint: AppString.code.tr(context),
                          icon: Icons.code,
                          validate: (data) {
                            if(num.tryParse(data!)== null){
                              return AppString.pleaseEnterValidCode.tr(context);
                            }

                            if (data.isEmpty ) {
                              return AppString.pleaseEnterValidCode
                                  .tr(context);
                            }

                            return null;
                          },
                        ),
                      ],),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child:state is ResetPasswordLoading ?const SpinKitFadingCircle(color: AppColors.primary,)
                            : CustomButton(
                        onPressed: () {
                          if (BlocProvider.of<ForgetPasswordCubit>(context)
                              .resetPasswordKey
                              .currentState!
                              .validate()) {

                            BlocProvider.of<ForgetPasswordCubit>(context).resetPassword();
                          }

                        },
                        text: AppString.confirm.tr(context),
                      ),
                    ),

                  ],
                ),
              );
            },
          ),
        ),
      ),

    );
  }
}
