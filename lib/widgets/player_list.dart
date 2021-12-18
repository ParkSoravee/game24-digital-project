import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:game24_fpga/Models/player.dart';
import 'package:game24_fpga/screens/play_screen.dart';

class PlayerList extends StatefulWidget {
  const PlayerList({Key? key}) : super(key: key);

  @override
  _PlayerListState createState() => _PlayerListState();
}

class _PlayerListState extends State<PlayerList> {
  var _isLoading = true;
  var _isAllReady = false;

  late DatabaseReference _playerRef;
  late StreamSubscription<DatabaseEvent> _playerSubscription;
  // late DatabaseReference _roundRef;
  // late StreamSubscription<DatabaseEvent> _roundSubscription;
  late DatabaseReference _gameRef;

  List<Player> _players = [];
  int _score = 0;
  // late int _duration;

  @override
  void initState() {
    init();
    super.initState();
  }

  @override
  void dispose() {
    _playerSubscription.cancel();
    super.dispose();
  }

  Future<void> init() async {
    try {
      setState(() {
        _isLoading = true;
      });
      // set db ref
      final database = FirebaseDatabase.instance;
      _playerRef = database.ref("players");
      _gameRef = database.ref('game');

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
          if (_numActive == _players.length)
            _isAllReady = true;
          else
            _isAllReady = false;

          _isLoading = false;
        });
      }, onError: (e) {
        print(e);
      });
    } catch (error) {
      print(error);
    }

    // _gameRef.onValue.listen((event) {});
  }

  int random(min, max) {
    var rand = Random();
    return min + rand.nextInt(max - min);
  }

  Future<void> startGame() async {
    _score = _players.length;

    // reset players score
    _players.forEach((element) async {
      // print(element.key);
      await _playerRef.child(element.key).child('score').set(0);
    });

    // game system

    // rand
    final rand_op = random(0, 2);
    String operator = rand_op == 0 ? '+' : '-';
    int num = random(1, 64);
    int ans = random(1, 64);

    while (ans == num ||
        (operator == '+' && ans < num) ||
        (operator == '-' && ans > num)) {
      num = random(1, 64);
      ans = random(1, 64);
      print('rand again $num $ans');
    }
    print('$num $operator ... = $ans');
    DatabaseReference numRef = FirebaseDatabase.instance.ref('nums');
    await numRef.child('ans').set(ans);
    await numRef.child('num').set(num);

    // set value in db
    // await _gameRef.child('isGamePlaying').set(true);
    await _gameRef.child('showResult').set(false);
    await _gameRef.child('isStart').set(true);
    await _gameRef.child('winPlayer').set(0);
    Navigator.of(context)
        .pushReplacement(MaterialPageRoute(builder: (ctx) => PlayScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Card(
          color: Colors.indigo,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
            height: 400,
            width: 400,
            child: _isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      color: Theme.of(context).primaryColor,
                    ),
                  )
                : _players.isEmpty
                    ? Center(
                        child: Text(
                          'Join the game to start!',
                          style: TextStyle(color: Colors.white38),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _players.length,
                        itemBuilder: (ctx, i) => Stack(
                          children: [
                            AnimatedContainer(
                              duration: Duration(milliseconds: 300),
                              curve: Curves.easeIn,
                              width: double.infinity,
                              height: 40,
                              margin: EdgeInsets.symmetric(vertical: 6),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(15),
                                color:
                                    _players[i].isActive ? Colors.amber : null,
                              ),
                            ),
                            ListTile(
                              onTap: _players[i].isActive
                                  ? null
                                  : () {
                                      _changeName(i);
                                    },
                              leading: Icon(
                                Icons.person,
                                color: _players[i].isActive
                                    ? Colors.black87
                                    : Colors.white,
                              ),
                              title: Text(
                                _players[i].name,
                                style: TextStyle(
                                  fontSize: 20,
                                  color: _players[i].isActive
                                      ? Colors.black87
                                      : Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
          ),
        ),
        // Todo here
        // Text('duration: $_duration'),
        SizedBox(
          height: 15,
        ),
        ElevatedButton(
          onPressed: startGame,
          style: ElevatedButton.styleFrom(
            primary: Colors.amber,
            padding: EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 15,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Text(
            'Start',
            style: TextStyle(
              fontSize: 25,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _changeName(int i) async {
    final _form = GlobalKey<FormFieldState>();
    final _controller = TextEditingController();
    _controller.text = _players[i].name;
    await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
              title: Text('Change the name...'),
              content: TextFormField(
                controller: _controller,
                key: _form,
                onEditingComplete: () => _form.currentState!.save(),
                onSaved: (val) async {
                  await _playerRef
                      .child(_players[i].key)
                      .child('name')
                      .set(val);
                  Navigator.pop(context);
                },
                decoration: InputDecoration(
                  border: InputBorder.none,
                  filled: true,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                TextButton(
                    onPressed: () {
                      _form.currentState!.save();
                    },
                    child: Text('Save')),
              ],
            ));
  }
}
