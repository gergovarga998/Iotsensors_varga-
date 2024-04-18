
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../authentication/loginscreen.dart';
import '../screens/datascreen.dart';



class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Add a delay of 3 seconds before navigating
    Future.delayed(const Duration(seconds: 3), () {
      // Check if the user is already logged in
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // If the user is logged in, navigate to the HomeScreen
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => FirebaseDataScreen()));
      } else {
        // If the user is not logged in, navigate to the SignInScreen
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) =>  LoginScreen()));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            "images/iotsplash.jpg",
            fit: BoxFit.cover,
          ),
        ],
      ),
    );
  }
}