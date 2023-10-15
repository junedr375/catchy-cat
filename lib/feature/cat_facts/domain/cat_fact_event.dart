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
  final VisibilityModel visibilityModel;
  const AddVisibilityEvent(
    this.visibilityModel,
  );
}

class AddToFavoriteEvent extends CatFactEvent {
  final CatFact catFact;
  const AddToFavoriteEvent(this.catFact);
}

class RemoveFromFavoriteEvent extends CatFactEvent {
  final CatFact catFact;
  const RemoveFromFavoriteEvent(this.catFact);
}
