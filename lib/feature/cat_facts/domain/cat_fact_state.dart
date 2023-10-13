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
  final List<CatFact> catFacts;
  final List<CatFact> randomFacts;

  const CatFactLoaded({
    required this.catFacts,
    required this.randomFacts,
  });
}

class CatFactError extends CatFactState {
  final String error;

  const CatFactError({required this.error});
}
