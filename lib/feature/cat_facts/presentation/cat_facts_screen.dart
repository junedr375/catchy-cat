import 'dart:math';

import 'package:catfacts/assets/images.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../domain/cat_fact_bloc.dart';
import 'components/feed_fact.dart';
import 'components/quick_facts.dart';

class CatFactsScreen extends StatelessWidget {
  const CatFactsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final catFactBloc = BlocProvider.of<CatFactBloc>(context);
    catFactBloc.add(const FetchCatFactsEvent());
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple,
        centerTitle: true,
        title: const Text('Catchy Cat'),
      ),
      body: Container(
        height: size.height,
        width: size.width,
        decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage(getRandomImage()), fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                Colors.grey.withOpacity(0.6), BlendMode.darken),
              ),
        ),
        child: Column(
          children: [
            QuickFactsSlider(),
            CatFactsFeed(),
          ],
        ),
      ),
    );
  }

  String getRandomImage() {
    final random = Random();
    final randomImage = random.nextInt(100);

    switch (randomImage % 3) {
      case 0:
        return Images.cat1;
      case 1:
        return Images.cat2;
      case 2:
      default:
        return Images.cat3;
    }
  }
}
