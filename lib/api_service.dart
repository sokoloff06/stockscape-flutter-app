import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class APIService {
  final String finhubApiKey;
  final String fmpKey;

  APIService(this.finhubApiKey, this.fmpKey);

  Future<dynamic> makeRequest(Uri url) async {
    final response = await http.get(url);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception(
          'Failed to make request. Response code: ${response.statusCode}');
    }
  }

  Future<Map<String, dynamic>> fetchStockData(String symbol) async {
    var url = Uri.parse(
        'https://finnhub.io/api/v1/quote?symbol=$symbol&token=$finhubApiKey');
    return await makeRequest(url);
  }

  Future<List<dynamic>> fetchTopGainers() async {
    var url = Uri.parse(
        'https://financialmodelingprep.com/api/v3/stock_market/gainers?apikey=$fmpKey');
    return await makeRequest(url);
  }

  Future<List<dynamic>> fetchTopLosers() async {
    var url = Uri.parse(
        'https://financialmodelingprep.com/api/v3/stock_market/losers?apikey=$fmpKey');
    return await makeRequest(url);
  }

  Future<List<dynamic>> fetchTopActive() async {
    var url = Uri.parse(
        'https://financialmodelingprep.com/api/v3/stock_market/actives?apikey=$fmpKey');
    return await makeRequest(url);
  }

  Future<Map<String, dynamic>> fetchSearchResults(String query) async {
    var url = Uri.parse('https://stocks.visokolov.com/keyword/$query');
    return await makeRequest(url);
  }

  Future<List<dynamic>> fetchFavorites(Set<String> symbols) async {
    if (symbols.isEmpty) {
      return Future.error("No favorite stocks");
    }
    String path =
        symbols.toString().substring(1, symbols.toString().length - 1);
    var url = Uri.parse(
        'https://financialmodelingprep.com/api/v3/quote/$path?apikey=$fmpKey');
    return await makeRequest(url);
  }
}

class APIResponse {
  int statusCode;
  String stringData;

  APIResponse({
    required this.statusCode,
    required this.stringData,
  });
}
