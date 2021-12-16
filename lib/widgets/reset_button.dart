import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';

class ResetButton extends StatelessWidget {
  const ResetButton({Key? key}) : super(key: key);

  void clearPlayer() async {
    DatabaseReference ref = FirebaseDatabase.instance.ref("players");

// Only update the name, leave the age and address!
    await ref.set({});
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        clearPlayer();
      },
      child: Text('reset'),
    );
  }
}
