import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:newappgradu/core/local/app_local.dart';
import 'package:newappgradu/core/routes/app_routes.dart';
import 'package:newappgradu/core/utils/commons.dart';
import 'package:newappgradu/features/auth/presentation/cubit/register_send_code/redister_send_code_cubit.dart';
import 'package:newappgradu/features/auth/presentation/cubit/register_send_code/redister_send_code_state.dart';
import 'package:newappgradu/features/auth/presentation/cubit/registr_cubit/register_cubit.dart';
import 'package:newappgradu/features/auth/presentation/cubit/registr_cubit/register_state.dart';

import '../../../../core/utils/app_assets.dart';
import '../../../../core/utils/app_colors.dart';
import '../../../../core/utils/app_string.dart';
import '../../../../core/widget/custom_text_form_field.dart';
import '../../../../core/widget/custombutton.dart';
import '../../../../core/widget/customimage.dart';

class RegisterSendCode extends StatelessWidget {
  const RegisterSendCode({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return  Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios),onPressed: (){
          navigateReplacement(context: context, route: Routes.register);
        }),
        elevation: 0.0,
        title: Text(AppString.sendResetLink.tr(context)),
      ),
      body: SafeArea(

        child: SingleChildScrollView(
          child: BlocConsumer<RegisterCubit, RegisterState>(
            listener: (context, state) {
              print(state);
              if(state is RegisterSucessState){
                showToast(message: AppString.registerSuccessfully.tr(context), state: ToastState.success);
                navigateReplacement(context: context, route: Routes.home);
              }

            },
            builder: (context, state) {
              return Form(
                key: BlocProvider.of<RegisterCubit>(context).registerSendKey,

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
                      padding: const EdgeInsets.all(24),
                      child: Column(children: [

                        CustomTextFormField(
                          controller: BlocProvider.of<RegisterCubit>(context)
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
                      child:state is RegisterSendCodeLoading ?const SpinKitFadingCircle(color: AppColors.primary,): CustomButton(
                        onPressed: () {

                          if (BlocProvider.of<RegisterCubit>(context)
                              .registerSendKey
                              .currentState!
                              .validate()) {
                            BlocProvider.of<RegisterCubit>(context)
                                .register();
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
