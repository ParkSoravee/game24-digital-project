import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:game24_fpga/Models/player.dart';

class PlayerList extends StatefulWidget {
  const PlayerList({Key? key}) : super(key: key);

  @override
  _PlayerListState createState() => _PlayerListState();
}

class _PlayerListState extends State<PlayerList> {
  var _isLoading = false;
  var _isAllReady = false;
  late DatabaseReference _playerRef;
  late StreamSubscription<DatabaseEvent> _playerSubscription;
  List<Player> _players = [];

  @override
  void initState() {
    init();
    super.initState();
  }

  Future<void> init() async {
    setState(() {
      _isLoading = true;
    });
    final database = FirebaseDatabase.instance;
    _playerRef = database.ref("players");

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
                            color: _players[i].isActive ? Colors.amber : null,
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
        SizedBox(
          height: 15,
        ),
        ElevatedButton(
          onPressed: _isAllReady ? () {} : null,
          style: ElevatedButton.styleFrom(
            padding: EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 15,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Text(
            _isAllReady ? 'Start' : 'waiting all player ready...',
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
