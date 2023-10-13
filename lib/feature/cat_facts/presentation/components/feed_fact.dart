import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/model/cat_fact.dart';
import '../../domain/cat_fact_bloc.dart';

class CatFactsFeed extends StatefulWidget {
  const CatFactsFeed({
    super.key,
  });

  @override
  State<CatFactsFeed> createState() => _CatFactsFeedState();
}

class _CatFactsFeedState extends State<CatFactsFeed> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        BlocProvider.of<CatFactBloc>(context)
            .add(const FetchMoreCatFactsEvent());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.65,
      child: Column(
        children: [
          Text('Do you know these 🐈 facts? 🤔',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Colors.white,fontSize: 28)),
          const SizedBox(height: 16),
          BlocBuilder<CatFactBloc, CatFactState>(
            builder: (context, state) {
              if (state is CatFactInitial || state is CatFactLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (state is CatFactError) {
                return Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Failed to load cat facts: ${state.error}'),
                    InkWell(
                      onTap: () {
                        BlocProvider.of<CatFactBloc>(context)
                            .add(const FetchCatFactsEvent());
                      },
                      child: Text(
                        'Reload',
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                  ],
                );
              } else if (state is CatFactLoaded) {
                final catFacts = state.catFacts;

                return Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.only(bottom: 20),
                    controller: _scrollController,
                    itemCount: catFacts.length,
                    itemBuilder: (context, index) {
                      return Column(
                        children: [
                          _CatFactTile(
                            catFact: catFacts[index],
                            isFavorite:
                                isAddedToFavorite(context, catFacts[index]),
                          ),
                          if (index == catFacts.length - 1)
                            SizedBox(
                              height: 40,
                              width: 40,
                              child: Center(child: CircularProgressIndicator()),
                            )
                          else
                            const Divider(),
                        ],
                      );
                    },
                  ),
                );
              }
              return const Center(child: Text('Unknown state'));
            },
          ),
        ],
      ),
    );
  }

  bool isAddedToFavorite(BuildContext context, CatFact catFact) {
    final catBloc = BlocProvider.of<CatFactBloc>(context);
    return catBloc.isFavorite(catFact);
  }
}

class _CatFactTile extends StatelessWidget {
  const _CatFactTile({required this.catFact, this.isFavorite = false});
  final CatFact catFact;
  final bool isFavorite;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.pets,color: Colors.white),
      trailing: InkWell(
        child: Icon(
          isFavorite ? Icons.favorite : Icons.favorite_border,
          color: Colors.red,
          size: 30,
        ),
        onTap: () {
          if (isFavorite) {
            BlocProvider.of<CatFactBloc>(context)
                .add(RemoveFromFavoriteEvent(catFact));
          } else {
            BlocProvider.of<CatFactBloc>(context)
                .add(AddToFavoriteEvent(catFact));
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  isFavorite ? 'Removed from favourite' : 'Added to favorites'),
              duration: Duration(seconds: 1),
            ),
          );
        },
      ),
      title: Text(catFact.fact,
      style: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 18,color: Colors.white)
      ),
    );
  }
}
