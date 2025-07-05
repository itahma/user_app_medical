import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:newappgradu/core/local/app_local.dart';
import 'package:newappgradu/core/utils/app_assets.dart';
import 'package:newappgradu/core/utils/app_colors.dart';
import 'package:newappgradu/core/utils/commons.dart';
import 'package:newappgradu/features/auth/presentation/cubit/registr_cubit/register_cubit.dart';
import 'package:newappgradu/features/auth/presentation/cubit/registr_cubit/register_state.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/utils/app_string.dart';
import '../../../../core/widget/custom_text_form_field.dart';
import '../../../../core/widget/custombutton.dart';
import '../../../../core/widget/customimage.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios),
            onPressed: () {
              navigateReplacement(context: context, route: Routes.login);
            }),
        title: Text(AppString.signUp.tr(context)),
      ),
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
                child: BlocConsumer<RegisterCubit, RegisterState>(
                  listener: (context, state) {

                    if (state is RegisterSendCodeSucess)
                    {

                      showToast(
                          message: AppString.registerSuccessfully.tr(context),
                          state: ToastState.success);
                      navigateReplacement(
                          context: context, route: Routes.registerCode);
                    }
                    if (state is RegisterErrorState) {
                      showToast(
                          message: AppString.loginFailed.tr(context),
                          state: ToastState.error);
                    }
                  },
                  builder: (context, state) {
                    return Form(
                      key: BlocProvider.of<RegisterCubit>(context).registerKey,
                      child: Column(
                        children: [
                          CustomTextFormField(
                            controller: BlocProvider.of<RegisterCubit>(context)
                                .firstNameController,
                            hint: AppString.firstName.tr(context),
                            hitColors: AppColors.grey,
                            icon: Icons.person,
                            validate: (data) {
                              if (data!.isEmpty || data.length > 13) {
                                return AppString.pleaseEnterValidName
                                    .tr(context);
                              }
                              return null;
                            },
                          ),
                          const SizedBox(
                            height: 32,
                          ),
                          CustomTextFormField(
                            controller: BlocProvider.of<RegisterCubit>(context)
                                .lastNameController,
                            hint: AppString.lastName.tr(context),
                            hitColors: AppColors.grey,
                            icon: Icons.person,
                            validate: (data) {
                              if (data!.isEmpty || data.length > 13) {
                                return AppString.pleaseEnterValidName
                                    .tr(context);
                              }
                              return null;
                            },
                          ),
                          const SizedBox(
                            height: 32,
                          ),
                          CustomTextFormField(
                            controller: BlocProvider.of<RegisterCubit>(context)
                                .emailController,
                            hint: AppString.email.tr(context),
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
                            controller: BlocProvider.of<RegisterCubit>(context)
                                .phoneController,
                            hint: AppString.phone.tr(context),
                            hitColors: AppColors.grey,
                            keyboardType: TextInputType.phone,
                            icon: Icons.phone,
                            validate: (data) {
                              if (data!.isEmpty || data.length > 14) {
                                return AppString.pleaseEnterValidPhone
                                    .tr(context);
                              }
                              return null;
                            },
                          ),
                          const SizedBox(
                            height: 32,
                          ),
                          CustomTextFormField(
                            controller: BlocProvider.of<RegisterCubit>(context)
                                .passwordController,
                            hint: AppString.password.tr(context),
                            hitColors: AppColors.grey,
                            isPassword: BlocProvider.of<RegisterCubit>(context)
                                .isRegisterPasswordShowing,
                            icon: BlocProvider.of<RegisterCubit>(context)
                                .suffixIcon,
                            suffixIconOnPressed: () {
                              BlocProvider.of<RegisterCubit>(context)
                                  .changeRegisterPasswordSuffixIcon();
                            },
                            validate: (data) {
                              if (data!.length < 6 || data.isEmpty) {
                                return AppString.pleaseEnterValidPassword
                                    .tr(context);
                              }
                              return null;
                            },
                          ),
                          const SizedBox(
                            height: 32,
                          ),
                          CustomTextFormField(
                            controller: BlocProvider.of<RegisterCubit>(context)
                                .confirmPasswordController,
                            hint: AppString.confirmPassword.tr(context),
                            hitColors: AppColors.grey,
                            isPassword: BlocProvider.of<RegisterCubit>(context)
                                .isRegisterConfirmPasswordShowing,
                            icon: BlocProvider.of<RegisterCubit>(context)
                                .suffixIconConfirm,
                            suffixIconOnPressed: () {
                              BlocProvider.of<RegisterCubit>(context)
                                  .changeConfirmRegisterPasswordSuffixIcon();
                            },
                            validate: (data) {
                              if (data !=
                                  BlocProvider.of<RegisterCubit>(context)
                                      .passwordController
                                      .text) {
                                return AppString.pleaseEnterValidPassword
                                    .tr(context);
                              }
                              return null;
                            },
                          ),
                          const SizedBox(
                            height: 32,
                          ),
                          CustomTextFormField(
                            controller: BlocProvider.of<RegisterCubit>(context)
                                .datePickerController,
                            readOnly: true,
                            onTap: () => BlocProvider.of<RegisterCubit>(context)
                                .onTapFunction(context: context),
                            icon: Icons.date_range,
                            hint: AppString.dateOfBirth.tr(context),
                            hitColors: AppColors.grey,
                          ),
                          const SizedBox(
                            height: 32,
                          ),
                          CustomTextFormField(
                            controller: BlocProvider.of<RegisterCubit>(context)
                                .regionNameController,
                            hint: AppString.regionName.tr(context),
                            hitColors: AppColors.grey,
                            icon: Icons.location_history,
                            validate: (data) {
                              if (data!.isEmpty || data.length > 13) {
                                return AppString.pleaseEnterValidName
                                    .tr(context);
                              }
                              return null;
                            },
                          ),
                          const SizedBox(
                            height: 32,
                          ),
                          CustomTextFormField(
                            controller: BlocProvider.of<RegisterCubit>(context)
                                .subRegionController,
                            hint: AppString.subRegion.tr(context),
                            hitColors: AppColors.grey,
                            icon: Icons.location_history,
                            validate: (data) {
                              if (data!.isEmpty || data.length > 13) {
                                return AppString.pleaseEnterValidName
                                    .tr(context);
                              }
                              return null;
                            },
                          ),
                          const SizedBox(
                            height: 32,
                          ),
                          CustomTextFormField(
                            controller: BlocProvider.of<RegisterCubit>(context)
                                .addressController,
                            hint: AppString.address.tr(context),
                            hitColors: AppColors.grey,
                            icon: Icons.location_history,
                            validate: (data) {
                              if (data!.isEmpty || data.length > 13) {
                                return AppString.pleaseEnterValidName
                                    .tr(context);
                              }
                              return null;
                            },
                          ),
                          const SizedBox(
                            height: 32,
                          ),
                          Row(
                            children: [
                              Row(
                                children: [
                                  Radio(
                                      activeColor: AppColors.primary,
                                      value: 'male',
                                      //BlocProvider.of<RegisterCubit>(context).maleController.text,
                                      groupValue:
                                          BlocProvider.of<RegisterCubit>(
                                                  context)
                                              .groupVal,
                                      onChanged: (val) {
                                        BlocProvider.of<RegisterCubit>(context)
                                            .changeGroupVal(val);
                                      }),
                                  Text(AppString.male.tr(context))
                                ],
                              ),
                              const Spacer(),
                              Row(
                                children: [
                                  Radio(
                                      activeColor: AppColors.primary,
                                      value: 'female',
                                      groupValue:
                                          BlocProvider.of<RegisterCubit>(
                                                  context)
                                              .groupVal,
                                      onChanged: (val) {
                                        BlocProvider.of<RegisterCubit>(context)
                                            .changeGroupVal(val);
                                      }),
                                  Text(AppString.female.tr(context)),
                                ],
                              ),
                            ],
                          ),
                          state is RegisterLoadingState
                              ? const SpinKitFadingCircle(
                                  color: AppColors.primary,
                                )
                              : CustomButton(
                                  onPressed: () {
                                    if (BlocProvider.of<RegisterCubit>(context)
                                        .registerKey
                                        .currentState!
                                        .validate()) {
                                      BlocProvider.of<RegisterCubit>(context)
                                          .sendCodeRegister();
                                    }
                                    //navigate(context: context, route: Routes.home);
                                  },
                                  text: AppString.signUp.tr(context))
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
