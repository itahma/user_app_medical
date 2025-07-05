import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:newappgradu/core/local/app_local.dart';
import 'package:newappgradu/core/routes/app_routes.dart';
import 'package:newappgradu/core/utils/app_assets.dart';
import 'package:newappgradu/core/utils/app_colors.dart';
import 'package:newappgradu/core/utils/commons.dart';
import 'package:newappgradu/features/auth/presentation/cubit/forget_password_cubit/forget_password_cubit.dart';
import '../../../../core/utils/app_string.dart';
import '../../../../core/widget/custom_text_form_field.dart';
import '../../../../core/widget/custombutton.dart';
import '../../../../core/widget/customimage.dart';
import '../cubit/forget_password_cubit/forget_password_state.dart';

class SendCodeScreen extends StatelessWidget {
  const SendCodeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0.0,
        title: Text(AppString.forgetPassword.tr(context)),
      ),
      body: SafeArea(

        child: SingleChildScrollView(
          child: BlocConsumer<ForgetPasswordCubit, ForgetPasswordState>(
            listener: (context, state) {
              print(state);
              if(state is SendCodeSuccess){

                showToast(message: AppString.checkMail.tr(context), state: ToastState.success);
                navigateReplacement(context: context, route: Routes.restPassword);
              }



            },
            builder: (context, state) {
              return Form(
                key: BlocProvider.of<ForgetPasswordCubit>(context).sendCodeKey,
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
                    Padding(
                      padding: const EdgeInsets.all(10),
                      child: Text(AppString.sendResetLinkInfo.tr(context),
                        style: Theme
                            .of(context)
                            .textTheme
                            .bodyLarge,),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(children: [

                        CustomTextFormField(
                          controller: BlocProvider.of<ForgetPasswordCubit>(context)
                              .emailController,
                          icon: Icons.email,
                          hint: AppString.email.tr(context),
                          validate: (data) {
                            if (data!.isEmpty ||
                                !data.contains('@gmail.com')) {
                              return AppString.pleaseEnterValidEmail
                                  .tr(context);
                            }
                            return null;
                          },
                        ),
                      ],),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child:state is SendCodeLoading ?const SpinKitFadingCircle(color: AppColors.primary,): CustomButton(
                        onPressed: () {
                          if (BlocProvider.of<ForgetPasswordCubit>(context)
                              .sendCodeKey
                              .currentState!
                              .validate()) {
                             BlocProvider.of<ForgetPasswordCubit>(context).sendCode();
                          }
                        },
                        text: AppString.sendResetLink.tr(context),
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
