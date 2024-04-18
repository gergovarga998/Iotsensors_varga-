
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:iotsensors/screens/vantilation%20fan.dart';
import 'package:iotsensors/screens/windowscreen.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

import '../authentication/loginscreen.dart';
import 'coming home.dart';
import 'historyscreen.dart';
import 'waterpump.dart';
import 'weather.dart';


class FirebaseDataScreen extends StatefulWidget {
  @override
  _FirebaseDataScreenState createState() => _FirebaseDataScreenState();

}
FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();
void showNotification(String title, String body) async {
  AndroidNotificationDetails androidPlatformChannelSpecifics =
  AndroidNotificationDetails(
    'Sensor Alert',
    'Sensors alert',
    channelDescription: 'Get updates about Weather Updates',
    importance: Importance.max,
    priority: Priority.high,
    showWhen: false,
  );

  var platformChannelSpecifics = NotificationDetails(
    android: androidPlatformChannelSpecifics,
  );

  await flutterLocalNotificationsPlugin.show(
    0,
    title,
    body,
    platformChannelSpecifics,
  );
}

class _FirebaseDataScreenState extends State<FirebaseDataScreen> {
  late DatabaseReference _database;
  late DatabaseReference _database1;
  double temperature = 0.0;
  double humidity = 0.0;
  double gasleak = 0.0;
  double co2_ppm= 0.0;
  double CO_Concentration=0.0;
  double Lm35=0.0;
  bool manualControl = false;
  String MQ135='';
  String MQ9='';
  String MQ6='';

  @override
  void initState() {
    super.initState();
    _database = FirebaseDatabase.instance.reference();
    _database1 = FirebaseDatabase.instance.reference().child('History');
    _initializeFirebase();
    var initializationSettingsAndroid = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    var initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid);
    flutterLocalNotificationsPlugin.initialize(initializationSettings);

    // Listen for changes to the 'detected' field


  }
  void saveDataToHistory() {
    // Get current timestamp to serve as unique key for history
    String timestamp = DateTime.now().millisecondsSinceEpoch.toString();

    // Convert temperature and humidity to strings
    String temperatureString = temperature.toString();
    String humidityString = humidity.toString();

    // Create a map with the data to save
    Map<String, dynamic> historyData = {
      'timestamp': timestamp,
      'Temperature': temperatureString,
      'Humidity': humidityString,
      'Gas Lekage': gasleak,
      'co2_ppm': co2_ppm,
      'CO Concentration:':CO_Concentration,
      'Lm35':Lm35,
    };

    // Save the data to 'history' in the database
    _database1.child(timestamp).set(historyData)
        .then((value) {
      // Show a success message or perform other actions if needed
      print('Data saved to history successfully.');
    }).catchError((error) {
      // Handle errors if the data couldn't be saved
      print('Failed to save data: $error');
    });
    Fluttertoast.showToast(
      msg: 'Data saved to history successfully.',
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.green,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  void _initializeFirebase() {
    _database.child('humidity').onValue.listen((humiditySnapshot) {
      if (humiditySnapshot.snapshot.value != null) {
        setState(() {
          humidity = double.parse(humiditySnapshot.snapshot.value.toString());
          if (humidity > 80 || humidity < 40) {
            showNotification('Alert', 'Humidity is out of range!');
          }
        });
      }
    });

    _database.child('Temperature').onValue.listen((tempSnapshot) {
      if (tempSnapshot.snapshot.value != null) {
        setState(() {
          temperature = double.parse(tempSnapshot.snapshot.value.toString());
          if (temperature > 40) {
            showNotification('Alert', ' Atmospheric Temperature is too high!');
          }
        });
      }
    });



    _database.child('Gas Lekage').onValue.listen((solarSnapshot) {
      if (solarSnapshot.snapshot.value != null) {
        setState(() {
          gasleak = double.parse(solarSnapshot.snapshot.value.toString());
        });
      }
    });
    _database.child('co2_ppm').onValue.listen((co2Snapshot) {
      if (co2Snapshot.snapshot.value != null) {
        setState(() {
          co2_ppm = double.parse(co2Snapshot.snapshot.value.toString());
        });
      }
    });
    _database.child('CO Concentration:').onValue.listen((coSnapshot) {
      if (coSnapshot.snapshot.value != null) {
        setState(() {
          CO_Concentration= double.parse(coSnapshot.snapshot.value.toString());
        });
      }
    });
    _database.child('Lm35').onValue.listen((lmSnapshot) {
      if (lmSnapshot.snapshot.value != null) {
        setState(() {
          Lm35= double.parse(lmSnapshot.snapshot.value.toString());
          if (Lm35 > 40) {
            showNotification('Alert', 'Room Temperature is too high!');
          }
        });
      }
    });
    _database.child('MQ135').onValue.listen((mq135Snapshot) {
      if (mq135Snapshot.snapshot.value != null) {
        setState(() {
          MQ135 = mq135Snapshot.snapshot.value.toString();
          if (MQ135 == 'Danger') {
            showNotification('Alert', 'Co2 is in a dangerous state!');
          }
        });
      }
    });

    _database.child('MQ9').onValue.listen((mq19Snapshot) {
      if (mq19Snapshot.snapshot.value != null) {
        setState(() {
          MQ9 = mq19Snapshot.snapshot.value.toString();
          if (MQ9 == 'Danger') {
            showNotification('Alert', 'Co is in danger state!');
          }
        });
      }
    });

    _database.child('MQ6').onValue.listen((mq6Snapshot) {
      if (mq6Snapshot.snapshot.value != null) {
        setState(() {
          MQ6 = mq6Snapshot.snapshot.value.toString();
          if (MQ6 == 'Danger') {
            showNotification('Alert', 'Gas Leakage Detected!');
          }
        });
      }
    });
  }
  void updateManualControl(bool value) {
    // Update manual control value in the database
    _database.child('manual_control').set(value).then((_) {
      setState(() {
        manualControl = value;
      });
    }).catchError((error) {
      print('Failed to update manual control: $error');
    });
  }


  void signOut(BuildContext context) async {
    final FirebaseAuth _auth = FirebaseAuth.instance;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Confirm Logout'),
          content: Text('Are you sure you want to log out?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),

            TextButton(
              onPressed: () async {
                await _auth.signOut();
                Navigator.of(context).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (c) => LoginScreen()),
                );
              },
              child: Text('Logout'),
            ),

          ],
        );
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Automation'),
        actions: [
          TextButton(
            onPressed: () {
              saveDataToHistory(); // Call the function when Save button is pressed
            },
            child: Text(
              'Save',
              style: TextStyle(color: Colors.black),
            ),
          ),

          TextButton(onPressed: (){ signOut(context);}, child:Text('Sign_Out',style: TextStyle(color: Colors.black),
          ),
          ),

        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 150,
              child: SfRadialGauge(
                axes: <RadialAxis>[
                  RadialAxis(
                    minimum: 0,
                    maximum: 100,
                    ranges: <GaugeRange>[
                      GaugeRange(startValue: 0, endValue: 50, color: Colors.green),
                      GaugeRange(startValue: 50, endValue: 80, color: Colors.blue),
                      GaugeRange(startValue: 80, endValue: 100, color: Colors.red),
                    ],
                    pointers: <GaugePointer>[
                      NeedlePointer(
                        value: humidity,
                        needleLength: 0.7,
                        needleColor: Colors.blue,
                        needleStartWidth: 1,
                        needleEndWidth: 5,
                        knobStyle: KnobStyle(
                          color: Colors.blue,
                          borderColor: Colors.black,
                          borderWidth: 0.1,
                        ),
                      ),
                    ],
                    annotations: <GaugeAnnotation>[
                      GaugeAnnotation(
                        widget: Container(
                          child: Text(
                            humidity.toStringAsFixed(1)+'%',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                        ),
                        angle: 90,
                        positionFactor: 0.6,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Humidity Gauge',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            SizedBox(
              height: 150,
              child: SfRadialGauge(
                axes: <RadialAxis>[
                  RadialAxis(
                    minimum: 0,
                    maximum: 100,
                    ranges: <GaugeRange>[
                      GaugeRange(startValue: 0, endValue: 50, color: Colors.green),
                      GaugeRange(startValue: 50, endValue: 80, color: Colors.blue),
                      GaugeRange(startValue: 80, endValue: 100, color: Colors.red),
                    ],
                    pointers: <GaugePointer>[
                      NeedlePointer(
                        value: temperature,
                        needleLength: 0.7,
                        needleColor: Colors.red,
                        needleStartWidth: 1,
                        needleEndWidth: 5,
                        knobStyle: KnobStyle(
                          color: Colors.blue,
                          borderColor: Colors.black,
                          borderWidth: 0.1,
                        ),
                      ),
                    ],
                    annotations: <GaugeAnnotation>[
                      GaugeAnnotation(
                        widget: Container(
                          child: Text(
                            temperature.toStringAsFixed(1)+'c',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                          ),
                        ),
                        angle: 90,
                        positionFactor: 0.6,
                      ),

                    ],

                  ),
                ],
              ),

            ),
            SizedBox(height: 8),
            Text(
              'Temperature Gauge',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 8),
            _buildDataRow('co2_ppm', co2_ppm.toString()),
            SizedBox(height: 8),
            _buildDataRow('Gas_Leakage', gasleak.toString()),
            SizedBox(height: 8),
            _buildDataRow('CO_Concentration', CO_Concentration.toString()),
            SizedBox(height: 8),
            _buildDataRow('Lm35', Lm35.toString()),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Manual Control',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
                Switch(
                  value: manualControl,
                  onChanged: (value) {
                    updateManualControl(value); // Update manual control value in the database
                  },
                ),
              ],
            ),
            ElevatedButton(onPressed: (){Navigator.push(context, MaterialPageRoute(builder: (c)=>CurtainControllScreen()));}, child: Text("Ventillation Hole")),
            ElevatedButton(onPressed: (){Navigator.push(context, MaterialPageRoute(builder: (c)=>FanControlScreen()));}, child: Text("Fan Control")),
            ElevatedButton(onPressed: (){Navigator.push(context, MaterialPageRoute(builder: (c)=>Pzem1()));}, child: Text("Check Weather Update")),
            ElevatedButton(onPressed: (){Navigator.push(context, MaterialPageRoute(builder: (c)=>HistoryScreen()));}, child: Text("History"))
          ],

        ),

      ),

    );
  }
}
Widget _buildDataRow(String title, String value) {
  Color textColor = Colors.black; // Default text color

  // Check if the title is 'field' and the value is 'Moisture Not Detected'



  return Card(
    elevation: 3,
    child: ListTile(
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
      subtitle: Text(
        value,
        style: TextStyle(
          fontSize: 16,
          color: textColor, // Apply the determined text color
        ),
      ),
    ),
  );
}

