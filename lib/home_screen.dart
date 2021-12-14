import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    init();
    super.initState();
  }

  Future<void> init() async {
    DatabaseReference ref = FirebaseDatabase.instance.ref("test/test1");
    // Get the data once
    DatabaseEvent event = await ref.once();
    // Print the data of the snapshot
    print(event.snapshot.value);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '0',
              style: TextStyle(fontSize: 100),
            ),
            Text(
              '0',
              style: TextStyle(fontSize: 100),
            ),
            Text(
              '0',
              style: TextStyle(fontSize: 100),
            ),
            Text(
              '0',
              style: TextStyle(fontSize: 100),
            ),
          ],
        ),
      ),
    );
  }
}
