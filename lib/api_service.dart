import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

class ApiService {
  final String _apiKey = dotenv.env['API_KEY']!;
  late final String _baseUrl = 'https://v6.exchangerate-api.com/v6/$_apiKey/latest';

  Future<Map<String, dynamic>> getExchangeRates(String baseCurrency) async {
    final response = await http.get(Uri.parse('$_baseUrl/$baseCurrency'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load exchange rates');
    }
  }

  Future<List<String>> getCurrencies(String baseCurrency) async {
    var rates = await getExchangeRates(baseCurrency);
    return rates['conversion_rates'].keys.toList();
  }

  Future<double> getSpecificExchangeRate(String fromCurrency, String toCurrency) async {
    var rates = await getExchangeRates(fromCurrency);
    return rates['conversion_rates'][toCurrency];
  }
}
