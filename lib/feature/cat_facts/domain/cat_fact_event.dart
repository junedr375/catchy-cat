part of 'cat_fact_bloc.dart';

@immutable
abstract class CatFactEvent {
  const CatFactEvent();
}

class FetchCatFactsEvent extends CatFactEvent {
  const FetchCatFactsEvent();
}

class FetchRandomCatFactEvent extends CatFactEvent {
  const FetchRandomCatFactEvent();
}

class AddVisibilityEvent extends CatFactEvent {
  const AddVisibilityEvent(
    this.visibilityModel,
  );
  final VisibilityModel visibilityModel;
}

class AddToFavoriteEvent extends CatFactEvent {
  const AddToFavoriteEvent(this.catFact);
  final CatFact catFact;
}

class RemoveFromFavoriteEvent extends CatFactEvent {
  const RemoveFromFavoriteEvent(this.catFact);
  final CatFact catFact;
}
