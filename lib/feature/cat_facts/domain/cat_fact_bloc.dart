import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:catfacts/feature/cat_facts/data/api/api_source.dart';
import 'package:hive/hive.dart';
import 'package:meta/meta.dart';
import 'package:flutter/foundation.dart';

import 'package:catfacts/feature/cat_facts/data/model/cat_fact.dart';

part 'cat_fact_event.dart';
part 'cat_fact_state.dart';

class CatFactBloc extends Bloc<CatFactEvent, CatFactState> {
  final ApiSource apiSource;

  final List<CatFact> catFacts = [];
  final List<CatFact> randomFacts = [];

  late Box<CatFact> box;

  CatFactBloc({required this.apiSource}) : super(CatFactInitial()) {
    _loadHiveBox();
    on<FetchCatFactsEvent>(_onFetchCatevent);
    on<FetchMoreCatFactsEvent>(_onFetchMoreCatevent);
    on<FetchRandomCatFactEvent>(_onFetchRandomCatevent);
    on<AddToFavoriteEvent>(_onAddToFavoriteEvent);
    on<RemoveFromFavoriteEvent>(_onRemoveFromFavoriteEvent);
  }

  void _loadHiveBox() async {
    box = await Hive.openBox<CatFact>('catfacts');
  }

  void _onFetchCatevent(
      FetchCatFactsEvent event, Emitter<CatFactState> emit) async {
    emit(CatFactLoading());
    try {
      final facts = await apiSource.fetchCatFacts();

      catFacts
        ..clear()
        ..addAll(facts);
      randomFacts
        ..clear()
        ..addAll(facts.take(5));

      emit(CatFactLoaded(
        catFacts: catFacts,
        randomFacts: randomFacts,
      ));
    } catch (e) {
      emit(CatFactError(error: e.toString()));
    }
  }

  void _onFetchMoreCatevent(
      FetchMoreCatFactsEvent event, Emitter<CatFactState> emit) async {
    try {
      final facts = await apiSource.fetchCatFacts();

      catFacts.addAll(facts);

      emit(CatFactLoaded(
        catFacts: catFacts,
        randomFacts: randomFacts,
      ));
    } catch (e) {
      emit(CatFactError(error: e.toString()));
    }
  }

  void _onFetchRandomCatevent(
      FetchRandomCatFactEvent event, Emitter<CatFactState> emit) async {
    try {
      final fact = await apiSource.fetchRandomCatFact();
      randomFacts
        ..removeAt(0)
        ..add(fact);

      emit(CatFactLoaded(
        catFacts: catFacts,
        randomFacts: randomFacts,
      ));
    } catch (e) {
      emit(CatFactError(error: e.toString()));
    }
  }

  void _onAddToFavoriteEvent(
      AddToFavoriteEvent event, Emitter<CatFactState> emit) async {
    try {
      await box.add(event.catFact);
      emit(CatFactLoaded(
        catFacts: catFacts,
        randomFacts: randomFacts,
      ));
    } catch (e) {
      emit(CatFactError(error: e.toString()));
    }
  }

  void _onRemoveFromFavoriteEvent(
      RemoveFromFavoriteEvent event, Emitter<CatFactState> emit) async {
    try {
      final index = box.values.toList().indexOf(event.catFact);

      await box.deleteAt(index);
      emit(CatFactLoaded(
        catFacts: catFacts,
        randomFacts: randomFacts,
      ));
    } catch (e) {
      print(e);
      emit(CatFactError(error: e.toString()));
    }
  }

  bool isFavorite(CatFact catFact) {
    return box.values.contains(catFact);
  }

  @override
  Future<void> close() {
    return super.close();
  }
}
