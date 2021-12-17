import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:game24_fpga/Models/player.dart';

class ShowScore extends StatefulWidget {
  const ShowScore({Key? key}) : super(key: key);

  @override
  _ShowScoreState createState() => _ShowScoreState();
}

class _ShowScoreState extends State<ShowScore> {
  List<Player> _players = [];
  var _isLoading = true;

  late DatabaseReference _playerRef;
  late StreamSubscription<DatabaseEvent> _playerSubscription;

  @override
  void initState() {
    try {
      setState(() {
        _isLoading = true;
      });
      // set db ref
      final database = FirebaseDatabase.instance;
      _playerRef = database.ref("players");

      // fetch players
      _playerSubscription = _playerRef.onValue.listen((event) async {
        _players = [];
        int _numActive = 0;
        event.snapshot.children.forEach((player) {
          final _playerObject = Player(
            name: player.child('name').value as String,
            score: player.child('score').value as int,
            isActive: player.child('isActive').value as bool,
            isAnswer: player.child('isAnswer').value as bool,
            key: player.key!,
          );
          _players.add(_playerObject);
          if (_playerObject.isActive == true) {
            _numActive += 1;
          }
        });

        setState(() {
          _isLoading = false;
        });
      }, onError: (e) {
        print(e);
      });
    } catch (error) {
      print(error);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10),
      margin: EdgeInsets.symmetric(vertical: 30),
      height: 70,
      width: double.infinity,
      child: Row(
        children: [
          // playerWidget(_players[i].name, _players[i].score)
          for (var i = 0; i < _players.length; i++)
            playerWidget(_players[i].name, _players[i].score),
        ],
      ),
    );
  }

  Widget playerWidget(String name, int score) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: Colors.amber,
        ),
        // padding: EdgeInsets.symmetric(horizontal: 20),
        margin: EdgeInsets.symmetric(horizontal: 20),
        padding: EdgeInsets.symmetric(horizontal: 10),
        // width: 80,
        child: ListTile(
          title: Text(name),
          trailing: Text(
            score.toString(),
            style: TextStyle(fontSize: 20),
          ),
        ),
      ),
    );
  }
}
