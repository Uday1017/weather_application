import 'package:flutter/material.dart';
import '../services/weather_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final cityController = TextEditingController();
  final weatherService = WeatherService();

  Map<String, dynamic>? weatherData;
  bool isLoading = false;
  String? error;

  void getWeather() async {
    FocusScope.of(context).unfocus(); // hide keyboard
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final data = await weatherService.fetchWeather(cityController.text.trim());
      setState(() {
        weatherData = data;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        weatherData = null;
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget weatherCard() {
    if (weatherData == null) return const SizedBox();

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 20),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              weatherData!['name'],
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '${weatherData!['main']['temp']} °C',
              style: const TextStyle(fontSize: 22),
            ),
            const SizedBox(height: 8),
            Text(weatherData!['weather'][0]['main']),
            const SizedBox(height: 8),
            Image.network(
              'http://openweathermap.org/img/wn/${weatherData!['weather'][0]['icon']}@2x.png',
              height: 80,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Weather App")),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: cityController,
              decoration: const InputDecoration(
                labelText: 'Enter city name',
                border: OutlineInputBorder(),
              ),
              onSubmitted: (_) => getWeather(),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: getWeather,
              child: const Text('Search'),
            ),
            const SizedBox(height: 20),
            if (isLoading) const CircularProgressIndicator(),
            if (error != null)
              Text(
                error!,
                style: const TextStyle(color: Colors.red),
              ),
            if (weatherData != null) weatherCard(),
          ],
        ),
      ),
    );
  }
}
