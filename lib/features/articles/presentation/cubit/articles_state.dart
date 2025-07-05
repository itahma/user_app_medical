part of 'articles_cubit.dart';

@immutable
sealed class ArticlesState {}

final class ArticlesInitial extends ArticlesState {}
final class LoadingArticles extends ArticlesState{}
final class LoadedArticles extends ArticlesState{
  List articlesModel;
  LoadedArticles(this.articlesModel);
}
final class ErrorArticles extends ArticlesState{
  String error;
  ErrorArticles(this.error);
}