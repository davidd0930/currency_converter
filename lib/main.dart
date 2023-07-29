import 'package:flutter/material.dart';
// import 'package:flutter_dotenv/flutter_dotenv.dart' as dotenv;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:currency_converter/api_service.dart';

Future main() async {
  await dotenv.load(fileName: ".env");
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Currency Converter',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _apiService = ApiService();
  String _fromCurrency = 'USD';
  String _toCurrency = 'EUR';
  double _conversionRate = 0.0;
  final _inputController = TextEditingController();
  List<String> _currencies = ['USD', 'EUR'];

  @override
  void initState() {
    super.initState();
    _fetchCurrencies();
    _fetchSpecificRate();
  }

  void _fetchSpecificRate() async {
    var rate = await _apiService.getSpecificExchangeRate(
        _fromCurrency, _toCurrency);
    setState(() {
      _conversionRate = rate;
    });
  }

  void _fetchCurrencies() async {
    var currencies = await _apiService.getCurrencies(_fromCurrency);
    setState(() {
      _currencies = currencies;
    });
  }

  void _convertCurrency() {
    double input = double.parse(_inputController.text);
    double result = input * _conversionRate;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Text('$input $_fromCurrency = $result $_toCurrency'),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Currency Converter'),
        backgroundColor: Colors.blueGrey,
      ),
      body: Padding(
        padding: EdgeInsets.all(8.0),
        child: Card(
          elevation: 8.0,
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  "Select the currency you want to convert from:",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                buildDropdownButton(_fromCurrency, (val) {
                  _fromCurrency = val!;
                  _fetchSpecificRate();
                }),
                SizedBox(height: 20),
                Text(
                  "Select the currency you want to convert to:",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                buildDropdownButton(_toCurrency, (val) {
                  _toCurrency = val!;
                  _fetchSpecificRate();
                }),
                SizedBox(height: 20),
                TextField(
                  controller: _inputController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Enter amount',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _convertCurrency,
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.blueGrey),
                    padding: MaterialStateProperty.all(EdgeInsets.all(12.0)),
                  ),
                  child: Text('Convert'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  DropdownButton<String> buildDropdownButton(String value,
      ValueChanged<String?> onChanged,) {
    return DropdownButton<String>(
      value: value,
      onChanged: onChanged,
      items: _currencies.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }
}
