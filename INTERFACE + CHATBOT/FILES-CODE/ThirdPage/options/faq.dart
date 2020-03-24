import 'package:flutter/material.dart';

class FAQ extends StatefulWidget {
  FAQ({Key key}) : super(key: key);

  @override
  _FAQState createState() => _FAQState();
}

class _FAQState extends State<FAQ> {
  @override
  Widget build(BuildContext context) {
    return Container(
       child: Center(child: Text('FAQ\'s Page'),)
    );
  }
}