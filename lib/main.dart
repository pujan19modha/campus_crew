import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'pages/home.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  Firestore.instance.settings(timestampsInSnapshotsEnabled: true).then((_) {
  },  onError: (_) {
  });
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ShareFlutter',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        accentColor: Colors.teal,
      ),
      home: Home(),
    );
  }
}
