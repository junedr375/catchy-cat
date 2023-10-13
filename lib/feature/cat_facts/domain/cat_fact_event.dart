part of 'cat_fact_bloc.dart';

@immutable
abstract class CatFactEvent {
  const CatFactEvent();
}

class FetchCatFactsEvent extends CatFactEvent {
  const FetchCatFactsEvent();
}

class FetchMoreCatFactsEvent extends CatFactEvent {
  const FetchMoreCatFactsEvent();
}

class FetchRandomCatFactEvent extends CatFactEvent {
  const FetchRandomCatFactEvent();
}

class AddToFavoriteEvent extends CatFactEvent {
  final CatFact catFact;
  const AddToFavoriteEvent(this.catFact);
}

class RemoveFromFavoriteEvent extends CatFactEvent {
  final CatFact catFact;
  const RemoveFromFavoriteEvent(this.catFact);
}
