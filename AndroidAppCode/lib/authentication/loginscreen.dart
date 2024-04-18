// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables


import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../screens/datascreen.dart';
import 'SignupScreen.dart';
class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _obscurePassword = true; // Flag to toggle password visibility
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _header(),
                _inputFields(context),
                _loginInfo(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _header() {
    return Column(
      children: [
        Text(
          "Log In",
          style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
        ),
        Text("Enter your details to log in"),
      ],
    );
  }

  Widget _inputFields(context) {
    void _login() async {
      try {
        UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

        // Navigate to home screen after successful login
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (c) => FirebaseDataScreen()));
      } catch (e) {
        // Handle login errors
        print("Error during login: $e");
        // You can show an error message to the user
        // For example: ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Login failed")));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          controller: _emailController,
          decoration: InputDecoration(
            hintText: "Email id",
            fillColor: Theme.of(context).primaryColor.withOpacity(0.1),
            filled: true,
            prefixIcon: Icon(Icons.email_outlined),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        SizedBox(height: 10),
        TextField(
          controller: _passwordController,
          decoration: InputDecoration(
            hintText: "Password",
            fillColor: Theme.of(context).primaryColor.withOpacity(0.1),
            filled: true,
            prefixIcon: Icon(Icons.password_outlined),
            suffixIcon: IconButton(
              icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide.none,
            ),
          ),
          obscureText: _obscurePassword,
        ),
        SizedBox(height: 10),
        ElevatedButton(
          onPressed: _login,
          child: Text(
            "Login",
            style: TextStyle(fontSize: 20),
          ),
          style: ElevatedButton.styleFrom(
            shape: StadiumBorder(),
            padding: EdgeInsets.symmetric(vertical: 16),
          ),
        ),
        SizedBox(height: 10),
        TextButton(
          onPressed: () {
            _showForgotPasswordDialog(context);
          },
          child: Text("Forgot Password?"),
        ),
        SizedBox(height: 10),
        TextButton(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (c) => SignupScreen()));
          },
          child: Text("Don't have an account? Sign Up"),
        ),
      ],
    );
  }

  Widget _loginInfo(context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Text("Forgot your password?"),
        // TextButton(onPressed: () {}, child: Text("Reset")),
      ],
    );
  }

  Future<void> _showForgotPasswordDialog(BuildContext context) async {
    TextEditingController resetEmailController = TextEditingController();

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Forgot Password'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Enter your email to receive a password reset link:'),
                TextField(
                  controller: resetEmailController,
                  decoration: InputDecoration(
                    hintText: "Email",
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Send Reset Email'),
              onPressed: () async {
                try {
                  await _auth.sendPasswordResetEmail(email: resetEmailController.text.trim());
                  Navigator.of(context).pop();
                  _showResetEmailSentDialog(context);
                } catch (e) {
                  print("Error sending reset email: $e");
                  // Handle errors, e.g., show an error message
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _showResetEmailSentDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Reset Email Sent'),
          content: Text('Check your email for a password reset link.'),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
