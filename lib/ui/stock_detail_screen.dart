import 'package:flutter/material.dart';
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stock Detail'),
      ),
      body: FutureBuilder(
        future: stockDataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else {
            final Map<String, dynamic>? quote = snapshot.data;
            final double currentPrice = double.parse(quote!['c'].toString());
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        widget.symbol, // Display stock symbol
                        style:
                            const TextStyle(fontSize: 18, color: Colors.grey),
                      ),
                      const Spacer(),
                      FavoritesToggle(widget.symbol),
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
    );
  }

  // TODO: Deduplicate
  Widget FavoritesToggle(symbol) {
    return Consumer<FavoritesModel>(
      builder: (BuildContext context,
          FavoritesModel favoritesModel, Widget? child,) {
        return GestureDetector(
          onTap: () {
            setState(() {
              favoritesModel.isFavorite(symbol)
                  ? favoritesModel
                  .removeFromFavorites(symbol)
                  : favoritesModel
                  .addToFavorites(symbol);
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
