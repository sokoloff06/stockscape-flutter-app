import 'dart:convert';
import 'dart:io';

class APIService {
  final String finhubApiKey;
  final String fmpKey;
  late HttpClient client;

  APIService(this.finhubApiKey, this.fmpKey) {
    HttpClient.enableTimelineLogging = true;
    client = HttpClient();
  }

  Future<Map<String, dynamic>> fetchStockData(String symbol) async {
    final response = await get(
      Uri.parse(
        'https://finnhub.io/api/v1/quote?symbol=$symbol&token=$finhubApiKey',
      ),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.stringData);
    } else {
      throw Exception('Failed to fetch stock data');
    }
  }

  Future<List<dynamic>> fetchTopGainers() async {
    final response = await get(
      Uri.parse(
        'https://financialmodelingprep.com/api/v3/stock_market/gainers?apikey=$fmpKey',
      ),
    );

    if (response.statusCode == 200) {
      return json.decode(response.stringData);
    } else {
      throw Exception('Failed to fetch top gainers');
    }
  }

  Future<List<dynamic>> fetchTopLosers() async {
    final response = await get(
      Uri.parse(
        'https://financialmodelingprep.com/api/v3/stock_market/losers?apikey=$fmpKey',
      ),
    );

    if (response.statusCode == 200) {
      return json.decode(response.stringData);
    } else {
      throw Exception('Failed to fetch top losers');
    }
  }

  Future<List<dynamic>> fetchTopActive() async {
    final response = await get(
      Uri.parse(
        'https://financialmodelingprep.com/api/v3/stock_market/actives?apikey=$fmpKey',
      ),
    );

    if (response.statusCode == 200) {
      return json.decode(response.stringData);
    } else {
      throw Exception('Failed to fetch top actives');
    }
  }

  Future<Map<String, dynamic>> fetchSearchResults(String query) async {
    final response = await get(
      Uri.parse(
        'https://stocks.visokolov.com/keyword/$query',
      ),
    );

    if (response.statusCode == 200) {
      return json.decode(response.stringData);
    } else {
      throw Exception(
          'Failed to search symbol. Response code: ${response.statusCode}');
    }
  }

  Future<APIResponse> get(Uri uri) async {
    HttpClientRequest request = await client.getUrl(uri);
    HttpClientResponse response = await request.close();
    final stringData = await response.transform(utf8.decoder).join();
    return APIResponse(statusCode: response.statusCode, stringData: stringData);
  }

  Future<List<dynamic>> fetchFavorites(Set<String> symbols) async {
    if (symbols.isEmpty) {
      return Future.error("No favorite stocks");
    }
    String path = symbols.toString().substring(1, symbols.toString().length-1);
    var url = 'https://financialmodelingprep.com/api/v3/quote/$path?apikey=$fmpKey';
    final response = await get(
      Uri.parse(url),
    );

    if (response.statusCode == 200) {
      return json.decode(response.stringData);
    } else {
      throw Exception('Failed to fetch top actives');
    }
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
