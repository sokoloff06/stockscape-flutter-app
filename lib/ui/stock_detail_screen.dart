import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_adsense/adsense.dart';
import 'package:provider/provider.dart';
import 'package:stockscape/main.dart';
import 'package:stockscape/models/favorites.dart';

class StockDetailScreen extends StatefulWidget {
  final String symbol;

  const StockDetailScreen(this.symbol, {super.key});

  @override
  State<StockDetailScreen> createState() => _StockDetailScreenState();
}

class _StockDetailScreenState extends State<StockDetailScreen> {
  late Future<Map<String, dynamic>> stockDataFuture;

  _StockDetailScreenState();

  @override
  void initState() {
    super.initState();
    stockDataFuture = MyApp.apiService.fetchStockData(widget.symbol);
    stockDataFuture.then((data) {
      return FirebaseAnalytics.instance.logViewItem(
          currency: "USD",
          value: double.parse(data['c'].toString()),
          items: <AnalyticsEventItem>[
            AnalyticsEventItem(itemName: widget.symbol)
          ]);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stock Detail'),
      ),
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints viewportConstraints) {
          return SingleChildScrollView(
            child: Column(
              children: [
                FutureBuilder(
                  future: stockDataFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else {
                      final Map<String, dynamic>? quote = snapshot.data;
                      final double currentPrice =
                          double.parse(quote!['c'].toString());
                      return Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  widget.symbol, // Display stock symbol
                                  style: const TextStyle(
                                      fontSize: 18, color: Colors.grey),
                                ),
                                const Spacer(),
                                FavoritesToggle(widget.symbol, currentPrice),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'Price: \$${currentPrice.toStringAsFixed(2)}',
                              // Display stock price
                              style: const TextStyle(fontSize: 18),
                            ),
                            // Add more stock information and charts here
                          ],
                        ),
                      );
                    }
                  },
                ),
                Column(children: [
                  Container(
                    color: Colors.blue,
                    height: 2000,
                  ),
                  Container(
                      color: Colors.red,
                      height: 600,
                      child: () {
                        if (kIsWeb) {
                          return Align(
                              alignment: Alignment.bottomCenter,
                              child: Adsense().adView(
                                  adSlot: "4773943862",
                                  adClient: "0556581589806023",
                                  isAdTest: MyApp.IS_DEBUG_BUILD));
                        } else {
                          return null;
                        }
                      }()),
                ]),
              ],
            ),
          );
        },
      ),
    );
  }

  // TODO: Deduplicate
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
}
