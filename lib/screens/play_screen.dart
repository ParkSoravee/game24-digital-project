import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:game24_fpga/Models/player.dart';
import 'package:game24_fpga/widgets/show_score.dart';

class PlayScreen extends StatefulWidget {
  const PlayScreen({Key? key}) : super(key: key);

  @override
  _PlayScreenState createState() => _PlayScreenState();
}

class _PlayScreenState extends State<PlayScreen> {
  var _isLoading = true;
  var _num = 0;
  var _ans = 0;

  late DatabaseReference _gameRef;
  // late StreamSubscription<DatabaseEvent> _gameSubscription;

  @override
  void initState() {
    init();
    super.initState();
  }

  Future<void> init() async {
    try {
      setState(() {
        _isLoading = true;
      });
      _gameRef = FirebaseDatabase.instance.ref('nums');
      DatabaseEvent event = await _gameRef.once();
      _num = event.snapshot.child('num').value as int;
      _ans = event.snapshot.child('ans').value as int;
      setState(() {
        _isLoading = false;
      });
    } catch (error) {
      print(error);
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      body: Container(
        width: double.infinity,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Image.asset(
                  'assets/images/ging1.png',
                  height: 200,
                ),
                Container(
                  child: Text(
                    'SPEED FPGA',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 100,
                    ),
                  ),
                ),
                Image.asset(
                  'assets/images/ging1.png',
                  height: 200,
                ),
              ],
            ),
            gameNumShow(),
            ShowScore(),
          ],
        ),
      ),
    );
  }

  Widget gameNumShow() {
    return _isLoading
        ? Center(
            child: CircularProgressIndicator(),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              textWithContainer(_num.toString(), Colors.grey),
              text('+/-'),
              textWithContainer('  ', Colors.red),
              text('='),
              textWithContainer(_ans.toString(), Colors.grey),
            ],
          );
  }

  Widget text(String str) {
    return Text(
      str,
      style: TextStyle(
        color: Colors.white,
        fontSize: 70,
        fontWeight: FontWeight.bold,
        fontFamily: "Roboto",
      ),
    );
  }

  Widget textWithContainer(String str, MaterialColor color) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20),
      // width: 120,
      // height: 120,
      child: text(str),
      padding: EdgeInsets.symmetric(horizontal: 25, vertical: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: color,
      ),
    );
  }
}
