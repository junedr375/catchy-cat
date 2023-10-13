import 'dart:async';

import 'package:catfacts/feature/cat_facts/presentation/components/slider_indicatior.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../utils/database_helper.dart';
import '../../data/model/cat_fact.dart';
import '../../domain/cat_fact_bloc.dart';

class QuickFactsSlider extends StatefulWidget {
  const QuickFactsSlider({
    super.key,
  });

  @override
  State<QuickFactsSlider> createState() => _QuickFactsSliderState();
}

class _QuickFactsSliderState extends State<QuickFactsSlider> {
  static bool isToastShown = false;
  int _currentIndex = 0;
  final now = DateTime.now();
  int _totalDuration = 0;

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height * 0.25;
    return SizedBox(
      height: height,
      child: BlocBuilder<CatFactBloc, CatFactState>(
        builder: (context, state) {
          if (state is CatFactInitial || state is CatFactLoading) {
            return const SizedBox();
          } else if (state is CatFactError) {
            return Center(
                child: Text('Failed to load cat facts: ${state.error}'));
          } else if (state is CatFactLoaded) {
            final catFacts = state.randomFacts;

            return Column(
              children: [
                CarouselSlider(
                  options: CarouselOptions(
                    height: height * 0.75,
                    viewportFraction: 1,
                    autoPlay: true,
                    pauseAutoPlayOnTouch: true,
                    pauseAutoPlayOnManualNavigate: true,
                    autoPlayInterval: const Duration(seconds: 5),
                    scrollPhysics: const BouncingScrollPhysics(),
                    onPageChanged: (index, reason) {
                      setState(() => _currentIndex = index);
                      final prevIndex = index - 1 < 0 ? 0 : index - 1;
                      unawaited(_logVisibleTiming(catFacts[prevIndex]));
                      // unawaited(_loadAllCatFacts());

                      if (reason == CarouselPageChangedReason.timed) {
                        _loadNewRandomCatFacts(context);
                      } else {
                        if (!isToastShown) {
                          _showToast(
                              "Hey! Cat Enthusiast, new facts adds in every 5 seconds");
                          isToastShown = true;
                        }
                      }
                    },
                  ),
                  items: catFacts.map(
                    (catFact) {
                      final index = catFacts.indexOf(catFact);
                      return _CaraouselTile(index: index, catFact: catFact);
                    },
                  ).toList(),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SlideIndicator(
                      totalCount: catFacts.length,
                      selectedIndexColor:Colors.purple,
                      inActiveColor: const Color(0xffD9D9D9),
                      selectedIndex: _currentIndex,
                    ),
                  ],
                ),
              ],
            );
          }
          return const Center(child: Text('Unknown state'));
        },
      ),
    );
  }

  void _loadNewRandomCatFacts(BuildContext context) {
    final catFactBloc = BlocProvider.of<CatFactBloc>(context);
    catFactBloc.add(const FetchRandomCatFactEvent());
  }

  void _showToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _logVisibleTiming(CatFact catFact) async {
    final fact = catFact.fact;
    final appearanceTime = DateTime.now();

    final visibleDuration = appearanceTime
        .difference(now.add(Duration(milliseconds: _totalDuration)))
        .inMilliseconds;
    _totalDuration += visibleDuration;

    print(
        "Fact: ${fact.substring(0, 10)}\nwhich appeared at: $appearanceTime\nvisible for: $visibleDuration ms");

    await DatabaseHelper.instance
        .insertCatFact(fact, appearanceTime, visibleDuration);
  }

  Future<void> _loadAllCatFacts() async {
    final catFacts = await DatabaseHelper.instance.getAllCatFacts();
    print(catFacts);
  }
}

class _CaraouselTile extends StatefulWidget {
  const _CaraouselTile({
    required this.index,
    required this.catFact,
  });

  final int index;
  final CatFact catFact;

  @override
  State<_CaraouselTile> createState() => _CaraouselTileState();
}

class _CaraouselTileState extends State<_CaraouselTile> {
  late DateTime now;
  final bgColors = [
    Colors.green.shade300,
    Colors.blue.shade200,
    Colors.yellow.shade800,
    Colors.red.shade400,
    Colors.orange.shade800,
  ];

  @override
  void initState() {
    super.initState();
    now = DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      clipBehavior: Clip.hardEdge,
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
            color: bgColors[widget.index % 5].withOpacity(0.7),
            borderRadius: BorderRadius.circular(10)),
        child: Center(
          child: Text(
            widget.catFact.fact,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
}
