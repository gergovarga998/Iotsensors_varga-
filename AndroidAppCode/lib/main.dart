
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'Splashscreen/splashscreen.dart';



Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GIFS App',
      theme: ThemeData(
        // Your theme configuration
      ),
      home:  SplashScreen(),
      debugShowCheckedModeBanner: false,// Set the SplashScreen as the initial screen
    );
  }
}

// ... Your SplashScreen class ...

// Rest of your code
