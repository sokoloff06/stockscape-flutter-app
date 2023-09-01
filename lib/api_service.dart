import 'dart:convert';

import 'package:http/http.dart' as http;

class APIService {
  final String finhubApiKey;

  APIService({required this.finhubApiKey, });

  Future<Map<String, dynamic>> fetchStockData(String symbol) async {
    final response = await http.get(
      Uri.parse(
        'https://finnhub.io/api/v1/quote?symbol=$symbol&token=$finhubApiKey',
      ),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return data;
    } else {
      throw Exception('Failed to fetch stock data');
    }
  }

  Future<Map<String, dynamic>> fetchTopGainersLosers() async {
    final response = await http.get(
      Uri.parse(
        'https://www.alphavantage.co/query?function=TOP_GAINERS_LOSERS&apikey=demo',
      ),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return data;
    } else {
      throw Exception('Failed to fetch top gainers and losers');
    }
  }

  Future<Map<String, dynamic>> fetchSearchResults(String query) async {
    final response = await http.get(
      Uri.parse('https://stocks.visokolov.com/keyword/$query',),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      return data;
    } else {
      throw Exception('Failed to search symbol');
    }
  }
}
