import 'package:flutter/material.dart';

class DefaultAvatar extends StatelessWidget {
  DefaultAvatar({@required this.username});

  final String username;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
        backgroundColor:
            Theme.of(context).platform == TargetPlatform.iOS
                ? Colors.blue
                : Colors.white,
        child: Text(
          username
              .substring(0, 1)
              .toUpperCase(),
          style: TextStyle(fontSize: 40.0),
        ),
      );
  }
}