import 'package:flutter/material.dart';

class Talk extends StatefulWidget {
  Talk({Key key}) : super(key: key);

  @override
  _TalkState createState() => _TalkState();
}

class _TalkState extends State<Talk> {
  @override
  Widget build(BuildContext context) {
    return Container(
       child: Center(child: Text('Talk to doctor'),),
    );
  }
}