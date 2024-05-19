import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class APIService {
  final String finhubApiKey;
  final String fmpKey;
  final Cache cache = Cache.getInstance();

  APIService(this.finhubApiKey, this.fmpKey);

  Future<dynamic> makeRequest(Uri url) async {
    // Checking cache
    var cachedResponse = cache.read(url);
    if (cachedResponse != null) {
      return jsonDecode(cachedResponse);
    }
    // Cache is empty, making request
    final response = await http.get(url);
    if (response.statusCode == 200) {
      // Saving to cache
      cache.save(response.body, url);
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

class Cache {
  final SharedPreferences _prefs;
  static late Cache instance;

  Cache(this._prefs) {
    instance = this;
  }

  static Cache getInstance() {
    return instance;
  }

  save(String data, Uri url) {
    _prefs.setString(url.toString(), data);
  }

  read(Uri url) {
    return _prefs.get(url.toString());
  }

  delete(Uri url) {
    _prefs.remove(url.toString());
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
