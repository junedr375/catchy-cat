part of 'cat_fact_bloc.dart';

@immutable
abstract class CatFactState {
  const CatFactState();
}

class CatFactInitial extends CatFactState {
  const CatFactInitial();
}

class CatFactLoading extends CatFactState {
  const CatFactLoading();
}

class CatFactLoaded extends CatFactState {
  const CatFactLoaded({required this.catFacts});
  final List<CatFact> catFacts;
}

class CatFactError extends CatFactState {
  const CatFactError({required this.error});
  final String error;
}
