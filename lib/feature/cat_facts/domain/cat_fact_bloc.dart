import 'dart:async';
import 'dart:math';
import 'package:bloc/bloc.dart';
import 'package:catfacts/feature/cat_facts/data/api/api_source.dart';
import 'package:catfacts/feature/cat_facts/data/model/visibility.dart';
import 'package:hive/hive.dart';
import 'package:meta/meta.dart';
import 'package:flutter/foundation.dart';

import 'package:catfacts/feature/cat_facts/data/model/cat_fact.dart';

import '../../../utils/database_helper.dart';

part 'cat_fact_event.dart';
part 'cat_fact_state.dart';

class CatFactBloc extends Bloc<CatFactEvent, CatFactState> {
  final ApiSource apiSource;

  final List<CatFact> catFacts = [];

  late Box<CatFact> box;

  CatFactBloc({required this.apiSource}) : super(CatFactInitial()) {
    _loadHiveBox();
    on<FetchCatFactsEvent>(_onFetchCatevent);
    on<FetchRandomCatFactEvent>(_onFetchRandomCatevent);
    on<AddVisibilityEvent>(_addVisibilityToDB);
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

      emit(CatFactLoaded(
        catFacts: catFacts,
      ));
    } catch (e) {
      emit(CatFactError(error: e.toString()));
    }
  }

  void _onFetchRandomCatevent(
      FetchRandomCatFactEvent event, Emitter<CatFactState> emit) async {
    try {
      final fact = await apiSource.fetchRandomCatFact();

      final index = Random().nextInt(catFacts.length - 1);

      catFacts.insert(index, fact);

      emit(CatFactLoaded(
        catFacts: catFacts,
      ));
    } catch (e) {
      emit(CatFactError(error: e.toString()));
    }
  }

  void _addVisibilityToDB(
      AddVisibilityEvent event, Emitter<CatFactState> emit) async {
    try {
      await DatabaseHelper.instance.insertCatFact(event.visibilityModel);
    } catch (e) {
      print(e);
    }
  }

  void _onAddToFavoriteEvent(
      AddToFavoriteEvent event, Emitter<CatFactState> emit) async {
    try {
      await box.add(event.catFact);
      emit(CatFactLoaded(
        catFacts: catFacts,
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
