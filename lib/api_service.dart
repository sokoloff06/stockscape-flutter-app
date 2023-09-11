import 'dart:convert';
import 'dart:io';

class APIService {
  final String finhubApiKey;
  late HttpClient client;

  APIService(this.finhubApiKey) {
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

  Future<Map<String, dynamic>> fetchTopGainersLosers() async {
    final response = await get(
      Uri.parse(
        'https://www.alphavantage.co/query?function=TOP_GAINERS_LOSERS&apikey=demo',
      ),
    );

    if (response.statusCode == 200) {
      return json.decode(response.stringData);
    } else {
      throw Exception('Failed to fetch top gainers and losers');
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
}

class APIResponse {
  int statusCode;
  String stringData;

  APIResponse({
    required this.statusCode,
    required this.stringData,
  });
}
