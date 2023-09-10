import 'dart:async';

import 'package:flutter/material.dart';
import 'package:stockscape/analytics.dart';
import 'package:stockscape/api_service.dart';
import 'package:stockscape/screens/stock_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final APIService apiService =
      APIService(finhubApiKey: 'cjp2419r01qj85r47bhgcjp2419r01qj85r47bi0');

  int _currentIndex = 0; // Index of the selected tab

  late Future<Map<String, dynamic>> topGainersLosersFuture;

  // late Future<Map<String, dynamic>> searchResultsFuture;
  late FutureOr<Map<String, dynamic>> searchListFuture;
  var searchController = SearchController();

  @override
  void initState() {
    super.initState();
    topGainersLosersFuture = apiService.fetchTopGainersLosers();
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
                suggestionsBuilder: (BuildContext context, searchController) {
                  var text = searchController.text;
                  List<Widget> widgets = [];
                  if (text.isEmpty){
                    return widgets;
                  }
                  var apiResponse =
                      apiService.fetchSearchResults(searchController.text);
                  return apiResponse.then((suggestionsData) {
                    var matches = suggestionsData['results'];
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
                  });
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
    Future<Map<String, dynamic>> futureData;
    if (_currentIndex >= 0 && _currentIndex <= 2) {
      futureData = topGainersLosersFuture;
      // } else if (_currentIndex == 3) {
      //   futureData = searchListFuture;
    } else {
      return const Center(child: Text('Invalid Tab Index'));
    }
    return FutureBuilder<Map<String, dynamic>>(
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

  Widget _buildTopGainersLosers(List<dynamic> stocks, String lastUpdated) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            "As of $lastUpdated\nClick on the symbol to check real-time price",
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ),
        Expanded(
          child: ListView.builder(
              itemCount: stocks.length,
              itemBuilder: (context, index) {
                final stock = stocks[index];
                final changeString = stock['change_percentage'].toString();
                Color textBackground;
                Color textColor;
                var change = double.parse(
                    changeString.substring(0, changeString.length - 1));
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
                              child: Text(stock['ticker']),
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
                              "${stock['change_percentage']}",
                              style: TextStyle(
                                color: textColor,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    onTap: () {
                      _navigateToDetailScreen(context, stock['ticker']);
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

  Widget _buildStockList(Map<String, dynamic> stocksData) {
    if (_currentIndex == 0) {
      return _buildTopGainersLosers(stocksData['top_gainers'] as List<dynamic>,
          stocksData["last_updated"]);
    } else if (_currentIndex == 1) {
      return _buildTopGainersLosers(stocksData['top_losers'] as List<dynamic>,
          stocksData["last_updated"]);
    } else if (_currentIndex == 2) {
      return _buildTopGainersLosers(
          stocksData['most_actively_traded'] as List<dynamic>,
          stocksData["last_updated"]);
      // } else if (_currentIndex == 3) {
      //   return _buildSearchResultsList(
      //       stocksData['results'] as List<dynamic>);
    } else {
      return const Center(child: Text('Invalid Tab Index'));
    }
  }
}

void _navigateToDetailScreen(BuildContext context, String symbol) {
  Analytics.logEvent("Details", Map.of({"symbol": symbol}));
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => StockDetailScreen(symbol),
    ),
  );
}
