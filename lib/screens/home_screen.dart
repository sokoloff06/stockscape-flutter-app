import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stockscape/analytics.dart';
import 'package:stockscape/main.dart';
import 'package:stockscape/screens/stock_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  final SharedPreferences? prefs;

  const HomeScreen(this.prefs, {super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0; // Index of the selected tab

  late Future<List<dynamic>> topGainersFuture;
  late Future<List<dynamic>> topLosersFuture;
  late Future<List<dynamic>> topActiveFuture;

  // late Future<Map<String, dynamic>> searchResultsFuture;
  late FutureOr<Map<String, dynamic>> searchListFuture;
  var searchController = SearchController();

  @override
  void initState() {
    super.initState();
    topGainersFuture = MyApp.apiService.fetchTopGainers();
    topLosersFuture = MyApp.apiService.fetchTopLosers();
    topActiveFuture = MyApp.apiService.fetchTopActive();
    // searchController.addListener(() {
    //   _loadAndNavigateToSearchTab(searchController);
    // });
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
                builder: (BuildContext context, searchController) {
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
                    apiResponse = await MyApp.apiService
                        .fetchSearchResults(searchController.text);
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
                  } on Exception catch (_, e) {
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
            label: 'Top Actively Traded in US',
          ),
          // BottomNavigationBarItem(
          //   icon: Icon(Icons.search),
          //   label: 'Search',
          // ),
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
          final stocksData = snapshot.data!;
          return _buildStockList(stocksData);
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
                final changeString = stock['changesPercentage'].toString();
                Color textBackground;
                Color textColor;
                var change = double.parse(
                    changeString);
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
                return ListTile(
                    title: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
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
                        Card(
                          color: textBackground,
                          child: Padding(
                            padding: const EdgeInsets.all(5),
                            child: Text(
                              "${stock['changesPercentage']}",
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
              }),
        ),
      ],
    );
  }

  // _loadAndNavigateToSearchTab(TextEditingController textController) {
  //   var query = textController.text;
  //   if (query.isNotEmpty) {
  //     setState(() {
  //       _currentIndex = 3;
  //       searchResultsFuture =
  //           apiService.fetchSearchResults(textController.text);
  //     });
  //   }
  // }

  // Widget _buildSearchResultsList(List stocksToDisplay) {
  //   return Expanded(
  //     child: ListView.builder(
  //         itemCount: stocksToDisplay.length,
  //         itemBuilder: (context, index) {
  //           return ListTile(
  //             title: Text(stocksToDisplay[index]['1. symbol']),
  //           );
  //         }),
  //   );
  // }

  Widget _buildStockList(List<dynamic> stocksData) {
    if (_currentIndex >= 0 && _currentIndex <= 2) {
      return _buildTopGainersLosers(stocksData);
    } else {
      return const Center(child: Text('Invalid Tab Index'));
    }
  }

  void _navigateToDetailScreen(BuildContext context, String symbol) {
    Analytics.logEvent("Details", Map.of({"symbol": symbol}));
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StockDetailScreen(symbol, widget.prefs),
      ),
    );
  }
}
