import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:game24_fpga/screens/play_screen.dart';
import 'firebase_options.dart';

import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Game24 FPGA',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
        backgroundColor: Color(0xFF29315D),
        fontFamily: "BlackAndWhite",
      ),
      // home: HomeScreen(),
      home: PlayScreen(),
    );
  }
}
