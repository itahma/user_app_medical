import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:newappgradu/core/database/cache/cache_helper.dart';

import '../../service/service_locatro.dart';
import 'global_state.dart';

class GlobalCubit extends Cubit<GlobalState> {
  GlobalCubit() : super(GlobalInitial());
 //bool isArabic =false;
String langCode='en';

  void changeLang(String codeLang)async{
    emit(ChangeLangLoading());
     langCode=codeLang;
     await sl<CacheHelper>().cacheLanguage(codeLang);
    emit(ChangeLangSucess());
  }
  void getCacheLang (){
    emit(ChangeLangLoading());
    final cacheLang=sl<CacheHelper>().getCachedLanguage();
    langCode=cacheLang;
    emit(ChangeLangSucess());

  }
}
