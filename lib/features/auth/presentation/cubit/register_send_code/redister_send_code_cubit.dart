

import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:newappgradu/features/auth/data/repository/auth_repository.dart';
import 'package:newappgradu/features/auth/presentation/cubit/registr_cubit/register_state.dart';
import 'redister_send_code_state.dart';




class RegisterSendCodeCubit extends Cubit<RegisterSendCodeState> {
  RegisterSendCodeCubit(this.authRepo) : super(RegisterSendCodeInitial());
  GlobalKey<FormState>sendCodeKeyRegister = GlobalKey<FormState>(debugLabel: '5');
  TextEditingController registerCodeController = TextEditingController();
  final AuthRepository authRepo;





}
