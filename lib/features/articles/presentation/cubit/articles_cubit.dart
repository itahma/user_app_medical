import 'package:bloc/bloc.dart';
import 'package:newappgradu/features/articles/data/model/ArticlesModel.dart';
import 'package:newappgradu/features/articles/data/repository/articles_repository.dart';
import 'package:meta/meta.dart';

part 'articles_state.dart';

class ArticlesCubit extends Cubit<ArticlesState> {
  ArticlesCubit(this.articlesRepository) : super(ArticlesInitial());
  ArticlesRepository articlesRepository;

  void getAllArticles() async {
    emit(LoadingArticles());
    final result = await articlesRepository.getAllArticles();
    result.fold((l) => emit(ErrorArticles(l.toString())), (r) {
      emit(LoadedArticles(r));
    });
  }
}
