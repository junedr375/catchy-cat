import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive/hive.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart' as path_provider;

import 'feature/cat_facts/data/api/api_source.dart';
import 'feature/cat_facts/data/model/cat_fact.dart';
import 'feature/cat_facts/domain/cat_fact_bloc.dart';
import 'feature/cat_facts/presentation/cat_facts_screen.dart';
import 'utils/database_helper.dart';

void main() async {
  try {
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp();
    await DatabaseHelper.instance.initialize();
    final appDocumentDirectory =
        await path_provider.getApplicationDocumentsDirectory();
    Hive
      ..init(appDocumentDirectory.path)
      ..registerAdapter(CatFactAdapter());
    runApp(const MyApp());
  } catch (e) {
    debugPrint(e.toString());
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primaryColor: Colors.purple),
      home: BlocProvider(
        create: (context) =>
            CatFactBloc(apiSource: ApiSource(httpClient: http.Client())),
        child: const CatFactsScreen(),
      ),
    );
  }
}
