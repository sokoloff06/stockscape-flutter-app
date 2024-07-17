import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_adsense/adsense.dart';
import 'package:provider/provider.dart';
import 'package:stockscape/main.dart';

import '../models/favorites.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() {
    return _HomeScreenState();
  }
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0; // Index of the selected tab
  late Future<List<dynamic>> topGainersFuture;
  late Future<List<dynamic>> topLosersFuture;
  late Future<List<dynamic>> topActiveFuture;
  late Future<List<dynamic>> favoritesFuture;
  var adHeight = 50.0;

  var searchController = SearchController();

  @override
  void initState() {
    super.initState();
    topGainersFuture = MyApp.apiService.fetchTopGainers();
    topLosersFuture = MyApp.apiService.fetchTopLosers();
    topActiveFuture = MyApp.apiService.fetchTopActive();
    favoritesFuture = MyApp.apiService
        .fetchFavorites(FavoritesModel.getInstance().getFavorites());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stock Market Tracker'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: SizedBox(
              height: 50,
              child: SearchAnchor(
                builder:
                    (BuildContext context, SearchController searchController) {
                  return SearchBar(
                    onTap: () {
                      searchController.openView();
                    },
                    onChanged: (_) {
                      searchController.openView();
                    },
                    controller: searchController,
                    leading: const Icon(Icons.search),
                  );
                },
                suggestionsBuilder:
                    (BuildContext context, searchController) async {
                  var text = searchController.text;
                  List<Widget> widgets = [];
                  if (text.isEmpty) {
                    return widgets;
                  }
                  Map<String, dynamic> apiResponse;
                  try {
                    var futureApiResponse = MyApp.apiService
                        .fetchSearchResults(searchController.text);
                    // futureApiResponse.ignore();
                    apiResponse = await futureApiResponse;
                    var matches = apiResponse['results'];
                    matches?.forEach((match) {
                      var symbol = match['symbol'];
                      widgets.add(ListTile(
                        title: Text(match['symbol']),
                        subtitle: Text(match['name']),
                        onTap: () {
                          _navigateToDetailScreen(context, symbol);
                        },
                      ));
                    });
                    return widgets;
                  } on Exception catch (_) {
                    widgets.add(const ListTile(
                      title: Text(
                          "Can't find matching symbols, please check your input!"),
                    ));
                    return widgets;
                  }
                },
              ),
            ),
          ),
          // const Column(children: [
          //   SizedBox(height: 50, child: AdViewWidget()),
          //   SizedBox(height: 50, child: AdViewWidget()),
          // ]),
          Expanded(child: _buildTabContent()),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.trending_up),
            label: 'Top Gainers in US',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.trending_down),
            label: 'Top Losers in US',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.swap_horiz),
            label: 'Top Traded in US',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent() {
    Future<List<dynamic>> futureData;
    switch (_currentIndex) {
      case 0:
        futureData = topGainersFuture;
        break;
      case 1:
        futureData = topLosersFuture;
        break;
      case 2:
        futureData = topActiveFuture;
        break;
      case 3:
        favoritesFuture = MyApp.apiService
            .fetchFavorites(FavoritesModel.getInstance().getFavorites());
        futureData = favoritesFuture;
        break;
      default:
        return const Center(child: Text('Invalid Tab Index'));
    }
    return FutureBuilder<List<dynamic>>(
      future: futureData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else {
          var stocksData = snapshot.data!;
          stocksData.sort((dynamic a, dynamic b) =>
              a['changesPercentage'].compareTo(b['changesPercentage']));
          if (_currentIndex == 0) {
            stocksData = stocksData.reversed.toList();
          } else if (_currentIndex == 2) {
            stocksData.sort((dynamic a, dynamic b) =>
                double.parse(a['change'].toString())
                    .abs()
                    .compareTo(double.parse(b['change'].toString()).abs()));
            stocksData = stocksData.reversed.toList();
          }
          return _buildTopGainersLosers(stocksData);
        }
      },
    );
  }

  Widget _buildTopGainersLosers(List<dynamic> stocks) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
              itemCount: stocks.length,
              itemBuilder: (context, index) {
                final stock = stocks[index];
                return listStockItem(stock, index);
              }),
        ),
      ],
    );
  }

  void _navigateToDetailScreen(BuildContext context, String symbol) {
    context.push('/stocks/$symbol');
  }

  Widget FavoritesToggle(String symbol, double price) {
    return Consumer<FavoritesModel>(
      builder: (
        BuildContext context,
        FavoritesModel favoritesModel,
        Widget? child,
      ) {
        return GestureDetector(
          onTap: () {
            setState(() {
              favoritesModel.isFavorite(symbol)
                  ? favoritesModel.removeFromFavorites(symbol)
                  : favoritesModel.addToFavorites(symbol, price);
            });
          },
          child: Icon(favoritesModel.isFavorite(symbol)
              ? Icons.favorite
              : Icons.favorite_border),
        );
      },
    );
  }

  Widget listStockItem(stock, index) {
    final changeString = stock['changesPercentage'].toString();
    var change = double.parse(changeString);
    Color textBackground;
    Color textColor;
    if (change > 0) {
      textBackground = Colors.green;
      textColor = Colors.white;
    } else if (change < 0) {
      textBackground = Colors.red;
      textColor = Colors.white;
    } else {
      textBackground = Colors.blueGrey;
      textColor = Colors.white;
    }
    var listTile = ListTile(
        title:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          SizedBox(
            child: Card(
                child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(stock['symbol']),
            )),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text("\$${stock['price']}"),
          ),
        ]),
        subtitle: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Padding(
              padding: EdgeInsets.all(8.0),
              // child: Text("Some long name of the company"),
            ),
            FavoritesToggle(stock['symbol'], stock['price']),
            const Spacer(),
            Card(
              color: textBackground,
              child: Padding(
                padding: const EdgeInsets.all(5),
                child: Text(
                  "$change %",
                  style: TextStyle(
                    color: textColor,
                  ),
                ),
              ),
            ),
          ],
        ),
        onTap: () {
          _navigateToDetailScreen(context, stock['symbol']);
        });
    if (index > 1 && index % 5 == 0 && kIsWeb) {
      var adView = Container(
        // constraints: const BoxConstraints(
        //   maxWidth: 500,
        // ),
        child: Adsense().adView(
            adSlot: "4773943862",
            adClient: "0556581589806023",
            isAdTest: MyApp.IS_DEBUG_BUILD),
      );
      return Column(children: [adView, listTile]);
    } else {
      return listTile;
    }
  }
}
