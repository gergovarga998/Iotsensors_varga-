import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fluttertoast/fluttertoast.dart';

class FanControlScreen extends StatefulWidget {
  const FanControlScreen({Key? key}) : super(key: key);

  @override
  _FanControlScreenState createState() => _FanControlScreenState();
}

class _FanControlScreenState extends State<FanControlScreen> {
  late DatabaseReference _fanRef;
  late DatabaseReference _manualControlRef;
  bool isFanOn = false;
  bool manualControl = false;

  @override
  void initState() {
    super.initState();
    _fanRef = FirebaseDatabase.instance.reference().child('fan');
    _manualControlRef =
        FirebaseDatabase.instance.reference().child('manual_control');
    _listenToFanStatus();
    _listenToManualControl();
  }

  void _listenToFanStatus() {
    _fanRef.onValue.listen((event) {
      if (event.snapshot.value != null) {
        setState(() {
          isFanOn = (event.snapshot.value as bool?) ?? false;
        });
      }
    });
  }

  void _listenToManualControl() {
    _manualControlRef.onValue.listen((event) {
      if (event.snapshot.value != null) {
        setState(() {
          manualControl = (event.snapshot.value as bool?) ?? false;
        });
      }
    });
  }

  void _toggleFan() {
    if (manualControl) {
      _fanRef.set(!isFanOn);
    } else {
      Fluttertoast.showToast(
        msg: 'Manual control is off',
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Fan Control'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            isFanOn
                ? Icon(Icons.ac_unit, size: 100, color: Colors.blue)
                : Icon(Icons.ac_unit, size: 100, color: Colors.grey),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _toggleFan();
              },
              child: Text(isFanOn ? 'Turn Off Fan' : 'Turn On Fan'),
            ),
          ],
        ),
      ),
    );
  }
}
