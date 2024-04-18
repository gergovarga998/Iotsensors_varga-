import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fluttertoast/fluttertoast.dart';

class CurtainControllScreen extends StatefulWidget {
  const CurtainControllScreen({Key? key}) : super(key: key);

  @override
  _CurtainControllScreenState createState() => _CurtainControllScreenState();
}

class _CurtainControllScreenState extends State<CurtainControllScreen> {
  late DatabaseReference _curtainRef;
  late DatabaseReference _manualControlRef;
  bool isCurtainOpen = false;
  bool manualControl = false;

  @override
  void initState() {
    super.initState();
    _curtainRef = FirebaseDatabase.instance.reference().child('curtain');
    _manualControlRef =
        FirebaseDatabase.instance.reference().child('manual_control');
    _listenToCurtainStatus();
    _listenToManualControl();
  }

  void _listenToCurtainStatus() {
    _curtainRef.onValue.listen((event) {
      if (event.snapshot.value != null) {
        setState(() {
          isCurtainOpen = (event.snapshot.value as bool?) ?? false;
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

  void _toggleCurtain() {
    if (manualControl) {
      _curtainRef.set(!isCurtainOpen);
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
        title: Text('Ventillation Hole Control'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            isCurtainOpen
                ? Image.asset('images/open.PNG', width: 200, height: 200)
                : Image.asset('images/closed.PNG', width: 200, height: 200),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _toggleCurtain();
              },
              child: Text(isCurtainOpen ? 'Close Ventillation Hole' : 'Open Ventillation Hole'),
            ),
          ],
        ),
      ),
    );
  }
}
