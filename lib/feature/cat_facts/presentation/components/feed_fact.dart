import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../data/model/cat_fact.dart';
import '../../data/model/visibility.dart';
import '../../domain/cat_fact_bloc.dart';

class CatFactsFeed extends StatefulWidget {
  const CatFactsFeed({super.key});

  @override
  State<CatFactsFeed> createState() => _CatFactsFeedState();
}

class _CatFactsFeedState extends State<CatFactsFeed>
    with WidgetsBindingObserver {
  Timer? _timer;
  bool _isPaused = false;

  static bool _isToastShown = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _startTimer();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        _resumeTimer();
        break;
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        _pauseTimer();
        break;
    }
  }

  _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 5), (timer) {
      debugPrint('isPaused: $_isPaused');
      if (_isPaused) return;
      final catFactBloc = BlocProvider.of<CatFactBloc>(context);
      catFactBloc.add(const FetchRandomCatFactEvent());
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CatFactBloc, CatFactState>(
      builder: (context, state) {
        if (state is CatFactInitial || state is CatFactLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is CatFactError) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Failed to load cat facts: ${state.error}'),
                InkWell(
                  onTap: () {
                    BlocProvider.of<CatFactBloc>(context)
                        .add(const FetchCatFactsEvent());
                  },
                  child: Icon(
                    Icons.refresh,
                    size: 100,
                    color: Colors.teal,
                  ),
                ),
              ],
            ),
          );
        } else if (state is CatFactLoaded) {
          final catFacts = state.catFacts;

          return Column(children: [
            Text('Do you know these 🐈 facts? 🤔',
                style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: 16),
            Expanded(
                child: NotificationListener<ScrollNotification>(
              onNotification: (notification) {
                if (notification is ScrollStartNotification) {
                  _pauseTimer();
                  if (!_isToastShown) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            'Hey! Cat Enthusiast, new facts will be added soon'),
                        duration: Duration(seconds: 1),
                      ),
                    );
                    _isToastShown = true;
                  }
                  Future.delayed(const Duration(seconds: 1), () {
                    _resumeTimer();
                  });
                }
                return true;
              },
              child: ListView.separated(
                padding: const EdgeInsets.only(bottom: 20),
                physics: BouncingScrollPhysics(),
                itemCount: catFacts.length,
                itemBuilder: (context, index) {
                  final fact = catFacts[index];
                  return _CatFactTile(
                    fact: fact,
                    isFavorite: isAddedToFavorite(context, catFacts[index]),
                  );
                },
                separatorBuilder: (context, index) =>
                    Divider(color: Colors.grey[400]),
              ),
            ))
          ]);
        }
        return const Center(child: Text('Unknown state'));
      },
    );
  }

  void _pauseTimer() {
    _isPaused = true;
  }

  void _resumeTimer() {
    _isPaused = false;
  }

  bool isAddedToFavorite(BuildContext context, CatFact catFact) {
    final catBloc = BlocProvider.of<CatFactBloc>(context);
    return catBloc.isFavorite(catFact);
  }

  @override
  void dispose() {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}

class _CatFactTile extends StatefulWidget {
  const _CatFactTile({required this.fact, this.isFavorite = false});
  final CatFact fact;
  final bool isFavorite;

  @override
  State<_CatFactTile> createState() => _CatFactTileState();
}

class _CatFactTileState extends State<_CatFactTile> {
  DateTime appearanceTime = DateTime.now();
  DateTime disAppearanceTime = DateTime.now();
  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key(widget.fact.fact),
      onVisibilityChanged: (info) => _onVisibilityChanged(context, info: info),
      child: ListTile(
        leading: const Icon(Icons.pets),
        trailing: InkWell(
          onTap: () => _onAddRemove(context),
          child: widget.isFavorite
              ? Text('REMOVE',
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(color: Colors.grey[700]))
              : Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: Colors.lime.shade300,
                      border: Border.all(color: Colors.black, width: 1.2)),
                  child: Text(
                    'ADD',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                ),
        ),
        title: Text(widget.fact.fact,
            style: Theme.of(context).textTheme.bodyLarge),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(
              '${widget.fact.length.toString()} words',
              style: Theme.of(context).textTheme.bodySmall,
            )
          ],
        ),
      ),
    );
  }

  void _onVisibilityChanged(BuildContext context,
      {required VisibilityInfo info}) {
    if (info.visibleFraction == 1.0) {
      appearanceTime = DateTime.now();
    } else if (info.visibleFraction == 0.0) {
      disAppearanceTime = DateTime.now();
    }
    if (appearanceTime.microsecondsSinceEpoch <
            disAppearanceTime.microsecondsSinceEpoch &&
        mounted) {
      final visibleDuration =
          disAppearanceTime.difference(appearanceTime).inMilliseconds;

      debugPrint(
          'fact: ${widget.fact.factName} visibile For ${visibleDuration} ms');

      BlocProvider.of<CatFactBloc>(context).add(
        AddVisibilityEvent(
          VisibilityModel(
            fact: widget.fact.fact,
            appearanceTime: appearanceTime,
            visibleDuration: visibleDuration,
          ),
        ),
      );
    }
  }

  void _onAddRemove(BuildContext context) {
    if (widget.isFavorite) {
      BlocProvider.of<CatFactBloc>(context)
          .add(RemoveFromFavoriteEvent(widget.fact));
    } else {
      BlocProvider.of<CatFactBloc>(context)
          .add(AddToFavoriteEvent(widget.fact));
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(widget.isFavorite
            ? 'Removed from favourite'
            : 'Added to favorites'),
        duration: Duration(seconds: 1),
      ),
    );
  }
}
