import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../domain/cat_fact_bloc.dart';
import 'components/feed_fact.dart';

class CatFactsScreen extends StatelessWidget {
  const CatFactsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final catFactBloc = BlocProvider.of<CatFactBloc>(context);
    catFactBloc.add(const FetchCatFactsEvent());
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Container(
        height: size.height,
        width: size.width,
        margin: const EdgeInsets.only(top: 32),
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: CatFactsFeed(),
      ),
    );
  }
}
