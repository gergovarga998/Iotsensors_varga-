import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class ComingHomeSettingsScreen extends StatefulWidget {
  @override
  _ComingHomeSettingsScreenState createState() =>
      _ComingHomeSettingsScreenState();
}

class _ComingHomeSettingsScreenState extends State<ComingHomeSettingsScreen> {
  TimeOfDay _selectedTime = TimeOfDay.now();
  final DatabaseReference _comingHomeHourRef =
  FirebaseDatabase.instance.reference().child('coming_home_hour');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Coming Home Settings'),
      ),
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () {
                _selectTime(context);
              },
              child: Text('Select Coming Home Hour'),
            ),
            SizedBox(height: 20.0),
            Text(
              'Selected Coming Home Hour: ${_selectedTime.format(context)}',
              style: TextStyle(fontSize: 18.0),
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: () {
                _saveComingHomeHour();
              },
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _saveComingHomeHour() {
    String comingHomeHour =
        '${_selectedTime.hour}:${_selectedTime.minute} ${_selectedTime.period == DayPeriod.am ? 'AM' : 'PM'}';
    _comingHomeHourRef.set(comingHomeHour).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Coming Home Hour saved successfully!'),
        duration: Duration(seconds: 2),
      ));
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to save Coming Home Hour: $error'),
        duration: Duration(seconds: 2),
      ));
    });
  }
}

