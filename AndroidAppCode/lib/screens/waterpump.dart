import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class WaterPumpScreen extends StatefulWidget {
  @override
  _WaterPumpScreenState createState() => _WaterPumpScreenState();
}

class _WaterPumpScreenState extends State<WaterPumpScreen> {
  final DatabaseReference _waterPumpRef = FirebaseDatabase.instance.reference().child('waterPump');

  // Initialize startTime and stopTime to midnight
  TimeOfDay startTime = TimeOfDay(hour: 0, minute: 0);
  TimeOfDay stopTime = TimeOfDay(hour: 0, minute: 0);

  @override
  void initState() {
    super.initState();
    _getSavedTimes();
  }

  void _getSavedTimes() async {
    DataSnapshot dataSnapshot = await _waterPumpRef.get();
    if (dataSnapshot.value != null) {
      Map<String, dynamic> pumpTimes = dataSnapshot.value as Map<String, dynamic>;

      setState(() {
        startTime = TimeOfDay(hour: pumpTimes['startHour'], minute: pumpTimes['startMinute']);
        stopTime = TimeOfDay(hour: pumpTimes['stopHour'], minute: pumpTimes['stopMinute']);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Water Pump Settings'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            _buildTimeSelector('Select Start Time', startTime, (newTime) {
              setState(() {
                startTime = newTime;
              });
            }),
            SizedBox(height: 20),
            _buildTimeSelector('Select Stop Time', stopTime, (newTime) {
              setState(() {
                stopTime = newTime;
              });
            }),
            SizedBox(height: 20),
            _buildTimeDisplay('Saved Start Time', startTime),
            SizedBox(height: 10),
            _buildTimeDisplay('Saved Stop Time', stopTime),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _savePumpTimes();
              },
              child: Text('Save Pump Times'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeSelector(String title, TimeOfDay selectedTime, ValueChanged<TimeOfDay> onTimeChanged) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: () async {
            TimeOfDay? pickedTime = await showTimePicker(
              context: context,
              initialTime: selectedTime,
            );

            if (pickedTime != null) {
              onTimeChanged(pickedTime);
            }
          },
          child: Text(title),
        ),
        SizedBox(height: 10),
      ],
    );
  }

  Widget _buildTimeDisplay(String title, TimeOfDay time) {
    return Column(
      children: [
        Text(
          '$title: ${time.format(context)}',
          style: TextStyle(fontSize: 18),
        ),
        SizedBox(height: 10),
      ],
    );
  }

  void _savePumpTimes() async {
    await _waterPumpRef.set({
      'startHour': startTime.hour,
      'startMinute': startTime.minute,
      'stopHour': stopTime.hour,
      'stopMinute': stopTime.minute,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Water pump times saved successfully!'),
      ),
    );
  }
}
