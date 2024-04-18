import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

class HistoryItem {
  final DateTime timestamp;
  final double temperature;
  final double humidity;
  final double gasleak;
  final double CO_Concentration;
  final double Lm35;
  final double co2_ppm;

  HistoryItem({
    required this.timestamp,
    required this.temperature,
    required this.humidity,
    required this.gasleak,
    required this.CO_Concentration,
    required this.Lm35,
    required this.co2_ppm
  });
}

class HistoryScreen extends StatefulWidget {
  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late DatabaseReference _historyRef;
  List<HistoryItem> historyItemList = [];

  @override
  void initState() {
    super.initState();
    _historyRef = FirebaseDatabase.instance.reference().child('History');
    fetchDataFromHistory();
  }

  void fetchDataFromHistory() {
    _historyRef.get().then((DataSnapshot snapshot) {
      if (snapshot.value != null) {
        Map<dynamic, dynamic>? values = snapshot.value as Map<dynamic, dynamic>?;

        if (values != null) {
          values.forEach((key, item) {
            int? timestampMilliseconds = int.tryParse(item['timestamp'] ?? '');
            if (timestampMilliseconds != null) {
              DateTime timestamp = DateTime.fromMillisecondsSinceEpoch(timestampMilliseconds);

              double temperature = double.tryParse(item['Temperature'].toString()) ?? 0.0;
              double humidity = double.tryParse(item['Humidity'].toString()) ?? 0.0;
              double gasleak = double.tryParse(item['Gas Lekage'].toString()) ?? 0.0;
              double CO_Concentration = double.tryParse(item['CO Concentration:'].toString()) ?? 0.0;
              double Lm35 = double.tryParse(item['Lm35'].toString()) ?? 0.0;
              double co2_ppm = double.tryParse(item['co2_ppm'].toString()) ?? 0.0;

              // Create a HistoryItem object and add it to the list
              HistoryItem historyItem = HistoryItem(
                timestamp: timestamp,
                temperature: temperature,
                humidity: humidity,
                gasleak: gasleak,
                CO_Concentration: CO_Concentration,
                Lm35: Lm35,
                co2_ppm: co2_ppm
              );

              historyItemList.add(historyItem);
            }
          });
          setState(() {});
        } else {
          print('Data is null');
        }
      } else {
        print('Snapshot value is null');
      }
    }).catchError((error) {
      print('Failed to fetch data: $error');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('History'),
      ),
      body: ListView.builder(
        itemCount: historyItemList.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text('Timestamp: ${historyItemList[index].timestamp}'),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HistoryDetailsScreen(historyItem: historyItemList[index]),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class HistoryDetailsScreen extends StatelessWidget {
  final HistoryItem historyItem;

  const HistoryDetailsScreen({Key? key, required this.historyItem}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String formattedDateTime =
        '${historyItem.timestamp.day}-${historyItem.timestamp.month}-${historyItem.timestamp.year} ${historyItem.timestamp.hour}:${historyItem.timestamp.minute}:${historyItem.timestamp.second}';

    return Scaffold(
      appBar: AppBar(
        title: Text('Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Timestamp: $formattedDateTime'),
            Text('Temperature: ${historyItem.temperature}'),
            Text('Humidity: ${historyItem.humidity}'),
            Text('Gas Leak: ${historyItem.gasleak}'),
            Text('Co_Concentration: ${historyItem.CO_Concentration}'),
            Text('Co2_PPM: ${historyItem.co2_ppm}'),
            Text('Lm35: ${historyItem.Lm35}'),
          ],
        ),
      ),
    );
  }
}
