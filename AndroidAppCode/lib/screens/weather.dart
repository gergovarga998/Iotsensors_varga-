import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WeatherData {
  final String temperature;
  final String weatherCondition;
  final String humidity; // Added humidity property

  WeatherData(this.temperature, this.weatherCondition, this.humidity);
}

class Pzem1 extends StatefulWidget {
  const Pzem1({Key? key}) : super(key: key);

  @override
  State<Pzem1> createState() => _Pzem1State();
}

class _Pzem1State extends State<Pzem1> {
  WeatherData? _weatherData;
  final Texttospeachcontroller = TextEditingController();
  String _searchQuery = '';
  final auth = FirebaseAuth.instance;
  late DatabaseReference dbRef;
  late User? _currentUser;
  Map<String, dynamic>? _userData;

  @override
  void initState() {
    super.initState();
    _getUserData();
    dbRef = FirebaseDatabase.instance.ref().child('Students');
    _getUserLocation(); // Get weather data when the screen initializes.
  }

  Future<void> _getUserData() async {
    _currentUser = FirebaseAuth.instance.currentUser;
    if (_currentUser != null) {
      DatabaseReference userRef =
      FirebaseDatabase.instance.reference().child("users");
      DataSnapshot snapshot = await userRef.child(_currentUser!.uid).get();
      if (snapshot.value != null) {
        setState(() {
          _userData = Map<String, dynamic>.from(snapshot.value as Map<dynamic, dynamic>);
        });
      }
    }
  }

  Future<void> _getUserLocation() async {
    // Check if the app has permission to access location.
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      // If permission is denied, request it from the user.
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // If the user denies permission, handle it here (e.g., show a message).
        print('User denied location permission.');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // If permission is permanently denied, handle it here (e.g., show a message or redirect to settings).
      print('Location permission permanently denied.');
      return;
    }

    // Get the user's location using the Geolocator package.
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    // Call the function to get weather data based on the user's location.
    _getWeatherDataForLocation(position.latitude, position.longitude);
  }

  Future<void> _getWeatherDataForLocation(
      double latitude, double longitude) async {
    final apiKey = '9ce7f37d387dff6236ab102fb7f7e810';
    final url =
        'https://api.openweathermap.org/data/2.5/weather?lat=$latitude&lon=$longitude&appid=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        double temperature = jsonData['main']['temp'].toDouble();
        double temperatureInCelsius = temperature - 273.15;
        String weatherCondition =
        jsonData['weather'][0]['description'].toString();
        String humidity = jsonData['main']['humidity'].toString(); // Fetch humidity data
        setState(() {
          _weatherData = WeatherData(temperatureInCelsius.toStringAsFixed(2), weatherCondition, humidity);
        });
      } else {
        // Handle error if the API request fails.
        // Show a default value or an error message.
        setState(() {
          _weatherData = null;
        });
      }
    } catch (e) {
      // Handle any exceptions that may occur during the API request.
      // Show a default value or an error message.
      setState(() {
        _weatherData = null;
      });
    }
  }

  void _logoutAndCloseApp(BuildContext context) async {
    // Perform the logout logic
    await auth.signOut();

    // Close the app
    exit(0);
  }

  void _saveDataLocally() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    // Implement your local data saving logic here
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Column(
          children: [
            Icon(Icons.home_filled),
            Text(
              'Live Weather Updates',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black26,
              ),
            ),
          ],
        ),
        toolbarHeight: 49,
        actions: [],
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.lightBlue.shade200,
                  Colors.blue.shade700,
                ],
              ),
            ),
          ),
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.3),
              ),
            ),
          ),
          Positioned(
            bottom: -100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.3),
              ),
            ),
          ),
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Center(
                child: Padding(
                  padding: EdgeInsets.all(10.0),
                  child: Column(
                    children: [
                      TextField(
                        onChanged: (value) {
                          setState(() {
                            _searchQuery = value;
                          });
                        },
                        decoration: InputDecoration(
                          hintText: 'Enter city or country',
                          prefixIcon: Icon(Icons.search),
                          border: OutlineInputBorder(),
                        ),
                      ),
                      SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: () {
                          // Trigger the search based on the _searchQuery
                          _searchWeatherData();
                        },
                        child: Text('Search'),
                      ),
                      const SizedBox(
                        height: 80,
                      ),
                      if (_weatherData != null)
                        Card(
                          child: Column(
                            children: [
                              if (_weatherData != null)
                                Container(
                                  padding: EdgeInsets.symmetric(vertical: 16),
                                  child: _getWeatherIcon(), // A method to get weather icon based on weather condition
                                ),
                              Text('Temperature: ${_weatherData?.temperature ?? 'N/A'}°C'),
                              Text('Weather Condition: ${_weatherData?.weatherCondition ?? 'N/A'}'),
                              Text('Humidity: ${_weatherData?.humidity ?? 'N/A'}%'), // Display humidity
                            ],
                          ),
                        ),
                      // Add your remaining widgets here
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Icon _getWeatherIcon() {
    if (_weatherData!.weatherCondition.toLowerCase().contains('rain')) {
      // Rainy weather
      return Icon(Icons.water, size: 100, color: Colors.blue);
    } else {
      // Default weather (e.g., sunny)
      return Icon(Icons.wb_sunny, size: 100, color: Colors.yellow);
    }
  }

  Future<void> _searchWeatherData() async {
    final apiKey = '9ce7f37d387dff6236ab102fb7f7e810';
    final url = 'https://api.openweathermap.org/data/2.5/weather?q=$_searchQuery&appid=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        double temperature = jsonData['main']['temp'].toDouble();
        double temperatureInCelsius = temperature - 273.15;
        String weatherCondition = jsonData['weather'][0]['description'].toString();
        String humidity = jsonData['main']['humidity'].toString(); // Fetch humidity data
        setState(() {
          _weatherData = WeatherData(temperatureInCelsius.toStringAsFixed(2), weatherCondition, humidity);
        });
      } else {
        // Handle error if the API request fails.
        // Show a default value or an error message.
        setState(() {
          _weatherData = null;
        });
      }
    } catch (e) {
      // Handle any exceptions that may occur during the API request.
      // Show a default value or an error message.
      setState(() {
        _weatherData = null;
      });
    }
  }
}
