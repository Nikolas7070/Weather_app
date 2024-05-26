import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: WeatherScreen(),
    );
  }
}

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({Key? key}) : super(key: key);

  @override
  _WeatherScreenState createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  late Future<Weather> futureWeather;
  final TextEditingController _cityController = TextEditingController();
  double _currentTemperature = 0.0;
  String _weatherIcon = '1'; // Нова змінна стан для збереження імені погода іконки

  @override
  void initState() {
    super.initState();
    _cityController.text = 'Kyiv'; // Встановити початкове значення
    futureWeather = fetchWeather(_cityController.text);
  }

  Future<Weather> fetchWeather(String city) async {
    final apiKey = 'e90fab7014064d2c88795d9fd95afa6f'; 
    final url =
        'https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey&units=metric';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final weather = Weather.fromJson(jsonDecode(response.body));
      setState(() {
        _currentTemperature = weather.temperature; // Встановлення температури у стан
        _weatherIcon = weather.icon; // Налаштування іконки погоди в стан
      });
      return weather;
    } else if (response.statusCode == 404) {
      throw Exception('City not found');
    } else {
      throw Exception('Failed to load weather');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomLeft,
          end: Alignment.topRight,
          colors: _currentTemperature < 15
              ? [Colors.blue, Colors.lightBlueAccent]
              : [Colors.orange, Colors.yellow],
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent, // Прозорий фон для Scaffold
        appBar: AppBar(
          title: const Text('Weather App'),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                FutureBuilder<Weather>(
                  future: futureWeather,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else if (snapshot.hasData) {
                      final temperature = snapshot.data!.temperature.round();
                      final wind = snapshot.data!.wind;
                      final pressure = snapshot.data!.pressure;
                      final humidity = snapshot.data!.humidity;
                      return Column(
                        children: [
                          Image.asset(
                            'assets/$_weatherIcon.png',
                            width: 200, // Ширина зображення відповідає ширині кнопки
                          ),
                          Container(
                            padding: const EdgeInsets.only(bottom: 20.0),
                            child: Text(
                              '$temperature°C',
                              style: const TextStyle(fontSize: 80, color: Colors.black),
                            ),
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.only(bottom: 10.0),
                                child: Text(
                                  'Wind: $wind km/h',
                                  style: const TextStyle(fontSize: 18, color: Colors.black),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.only(bottom: 10.0),
                                child: Text(
                                  'Pressure: $pressure KPa',
                                  style: const TextStyle(fontSize: 18, color: Colors.black),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.only(bottom: 10.0),
                                child: Text(
                                  'Humidity: $humidity %',
                                  style: const TextStyle(fontSize: 18, color: Colors.black),
                                ),
                              ),
                            ],
                          ),
                        ],
                      );
                    } else {
                      return const Text('No data');
                    }
                  },
                ),
                SizedBox(
                  width: 300,
                  child: TextField(
                    controller: _cityController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      labelText: 'Enter city',
                      border: OutlineInputBorder(),
                      suffixIcon: IconButton(
                        onPressed: () {
                          _cityController.clear();
                        },
                        icon: Icon(Icons.clear),
                      ),
                      prefixIcon: Icon(Icons.location_city),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: 300,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.zero,
                        side: const BorderSide(color: Colors.black), 
                      ),
                    ),
                    onPressed: () {
                      setState(() {
                        futureWeather = fetchWeather(_cityController.text);
                      });
                    },
                    child: const Text('Get Weather'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class Weather {
  final String city;
  final double temperature;
  final double humidity;
  final double pressure;
  final double wind;
  final String icon;

  Weather({required this.city, required this.temperature, required this.pressure, required this.humidity, required this.wind, required this.icon});

  factory Weather.fromJson(Map<String, dynamic> json) {
    return Weather(
      city: json['name'],
      temperature: json['main']['temp'].toDouble(),
      wind: json['wind']['speed'].toDouble(),
      humidity: json['main']['humidity'].toDouble(),
      pressure: json['main']['pressure'].toDouble(),
      icon: json['weather'][0]['icon'], 
    );
  }
}
