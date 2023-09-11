import 'package:flutter/material.dart';
import 'package:stockscape/api_service.dart';

class StockDetailScreen extends StatelessWidget {
  final APIService apiService = APIService('cjp2419r01qj85r47bhgcjp2419r01qj85r47bi0');
  final String symbol;

  StockDetailScreen(this.symbol);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Stock Detail'),
      ),
      body: FutureBuilder(
        future: apiService.fetchStockData(symbol),
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
                    'Price: \$${currentPrice.toStringAsFixed(2)}', // Display stock price
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
