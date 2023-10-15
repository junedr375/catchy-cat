import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;

import '../model/cat_fact.dart';

class ApiSource {
  final http.Client httpClient;

  ApiSource({required this.httpClient});

  Future<CatFact> fetchRandomCatFact() async {
    final response = await httpClient
        .get(Uri.parse('https://catfact.ninja/fact?max_length=200'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      return CatFact.fromJson(data);
    } else {
      throw Exception('error fetching cat facts');
    }
  }

  Future<List<CatFact>> fetchCatFacts() async {
    final randInt = Random().nextInt(20);
    final response = await httpClient
        .get(Uri.parse('https://catfact.ninja/facts?&limit=20&page=$randInt'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      final catFacts = <CatFact>[];
      for (var catFact in data['data']) {
        catFacts.add(CatFact.fromJson(catFact));
      }
      return catFacts;
    } else {
      throw Exception('error fetching cat facts');
    }
  }
}
