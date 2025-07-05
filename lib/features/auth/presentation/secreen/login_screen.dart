import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:newappgradu/core/local/app_local.dart';
import 'package:newappgradu/core/routes/app_routes.dart';
import 'package:newappgradu/core/utils/app_assets.dart';
import 'package:newappgradu/core/utils/app_colors.dart';
import 'package:newappgradu/core/utils/commons.dart';
import 'package:newappgradu/core/utils/app_string.dart';
import 'package:newappgradu/core/widget/custom_text_form_field.dart';
import 'package:newappgradu/core/widget/customimage.dart';
import 'package:newappgradu/features/auth/presentation/cubit/login/login_cubit/login_cubit.dart';
import 'package:newappgradu/features/auth/presentation/cubit/login/login_cubit/login_state.dart';

import '../../../../core/widget/custombutton.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
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
              SizedBox(
                height: 40.h,
              ),
              Padding(
                padding: const EdgeInsets.all(24),
                child: BlocConsumer<LoginCubit, LoginState>(
                  listener: (context, state) {
                    print(state);
                    if (state is LoginSucessState){
                      showToast(
                          message: AppString.loginSuccessfully.tr(context),
                          state: ToastState.success);
                      navigateReplacement(context: context, route: Routes.home);
                    }
                    if (state is LoginErrorState) {
                      showToast(
                          message: state.message, state: ToastState.error);
                    }
                  },
                  builder: (context, state) {
                    return Form(
                      key: BlocProvider.of<LoginCubit>(context).loginKey,
                      child: Column(
                        children: [
                          CustomTextFormField(
                            controller: BlocProvider.of<LoginCubit>(context)
                                .emailController,
                            hint: AppLocalizations.of(context)!
                                .translate(AppString.email),
                            hitColors: AppColors.grey,
                            icon: Icons.email,
                            validate: (data) {
                              if (data!.isEmpty ||
                                  !data.contains('@gmail.com')) {
                                return AppString.pleaseEnterValidEmail
                                    .tr(context);
                              }
                              return null;
                            },
                          ),
                          const SizedBox(
                            height: 32,
                          ),
                          CustomTextFormField(
                            controller: BlocProvider.of<LoginCubit>(context)
                                .passwordController,

                            hint: AppLocalizations.of(context)!
                                .translate(AppString.password),
                            hitColors: AppColors.grey,
                            isPassword: BlocProvider.of<LoginCubit>(context)
                                .isLoginPasswordShowing,
                            icon:
                                BlocProvider.of<LoginCubit>(context).suffixIcon,
                            suffixIconOnPressed: () {
                              BlocProvider.of<LoginCubit>(context)
                                  .changeLoginPasswordSuffixIcon();
                            },
                            validate: (data) {
                              if (data!.length < 6 || data.isEmpty) {
                                return AppString.pleaseEnterValidPassword
                                    .tr(context);
                              }
                              return null;
                            },
                          ),
                          SizedBox(
                            height: 24.h,
                          ),
                          Row(
                            children: [
                              TextButton(
                                onPressed: () {
                                  navigate(context: context, route: Routes.sendCode);
                                },
                                child: Text(

                                  AppString.forgetPassword.tr(context),
                                  style: TextStyle(fontSize: 16),

                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 32.h,
                          ),
                        state is LoginLoadingState?const SpinKitFadingCircle(color: AppColors.primary,):
                        CustomButton(
                            onPressed: () {
                              if (BlocProvider.of<LoginCubit>(context)
                                  .loginKey
                                  .currentState!
                                  .validate()) {
                                 BlocProvider.of<LoginCubit>(context).login();
                              }
                            },
                            text: AppString.signIn.tr(context),
                          ),
                          SizedBox(
                            height: 24.h,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(AppString.dont_have_account.tr(context),
                              style: const TextStyle(fontSize: 16),
                              ),
                              TextButton(
                                onPressed: () {
                                  navigateReplacement(context: context, route: Routes.register);
                                },
                                child: Text(
                                  AppString.signUp.tr(context),
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
