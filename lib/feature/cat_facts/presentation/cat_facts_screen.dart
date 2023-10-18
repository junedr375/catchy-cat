import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../domain/cat_fact_bloc.dart';
import 'components/feed_fact.dart';

class CatFactsScreen extends StatefulWidget {
  const CatFactsScreen({Key? key}) : super(key: key);

  @override
  State<CatFactsScreen> createState() => _CatFactsScreenState();
}

class _CatFactsScreenState extends State<CatFactsScreen> {
  @override
  Widget build(BuildContext context) {
    BlocProvider.of<CatFactBloc>(context).add(const FetchCatFactsEvent());
    final size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Container(
        height: size.height,
        width: size.width,
        margin: const EdgeInsets.only(top: 32),
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: const CatFactsFeed(),
      ),
    );
  }

  @override
  void dispose() {
    BlocProvider.of<CatFactBloc>(context).close();
    super.dispose();
  }
}
