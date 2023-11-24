import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stockscape/main.dart';

class StockDetailScreen extends StatefulWidget {
  final String symbol;

  StockDetailScreen(this.symbol);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stock Detail'),
      ),
      body: FutureBuilder(
        future: MyApp.apiService.fetchStockData(widget.symbol),
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
                  // Text(
                  //   stock?['name'], // Display stock name
                  //   style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  // ),
                  // SizedBox(height: 10),
                  Text(
                    symbol, // Display stock symbol
                    style: const TextStyle(fontSize: 18, color: Colors.grey),
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
}
