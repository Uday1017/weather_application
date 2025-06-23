import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  debugDisableShadows = true;
  runApp(UrbanSkiesApp());
}

class UrbanSkiesApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Urban Skies',
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.indigo,
        scaffoldBackgroundColor: const Color(0xFFe0e7ff),
        fontFamily: 'Roboto',
      ),
      home: WeatherHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}
class WeatherHomePage extends StatefulWidget {
  @override
  _WeatherHomePageState createState() => _WeatherHomePageState();
}

class _WeatherHomePageState extends State<WeatherHomePage> {
  final TextEditingController _cityController = TextEditingController();
  String? temperature;
  String? condition;
  String? cityName;
  String? iconCode;
  bool isLoading = false;
  String? error;

  Future<void> fetchWeather(String city) async {
    final apiKey = 'e9193481aea70f2ac37fe02a883fb29e'; // 🔐 Replace with your OpenWeatherMap API key
    final url =
        'https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey&units=metric';

    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          temperature = data['main']['temp'].toString();
          condition = data['weather'][0]['main'];
          cityName = data['name'];
          iconCode = data['weather'][0]['icon'];
          isLoading = false;
        });
      } else {
        setState(() {
          error = "City not found";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = "Something went wrong";
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            children: [
              Text(
                "Urban Skies",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo[800],
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _cityController,
                decoration: InputDecoration(
                  hintText: 'Enter city name',
                  prefixIcon: Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
                onSubmitted: (value) {
                  if (value.trim().isNotEmpty) {
                    fetchWeather(value.trim());
                  }
                },
              ),
              const SizedBox(height: 20),
              if (isLoading)
                CircularProgressIndicator()
              else if (error != null)
                Text(
                  error!,
                  style: TextStyle(color: Colors.red),
                )
              else if (temperature != null)
                  Expanded(
                    child: Center(
                      child: Card(
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        color: Colors.indigo[100],
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '$cityName',
                                style: TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.indigo[900],
                                ),
                              ),
                              const SizedBox(height: 10),
                              Image.network(
                                'https://openweathermap.org/img/wn/$iconCode@2x.png',
                                scale: 1.5,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                '$temperature°C',
                                style: TextStyle(
                                  fontSize: 36,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Text(
                                '$condition',
                                style: TextStyle(
                                  fontSize: 20,
                                  color: Colors.grey[800],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: Center(
                      child: Text(
                        "Search a city to get weather info",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}

