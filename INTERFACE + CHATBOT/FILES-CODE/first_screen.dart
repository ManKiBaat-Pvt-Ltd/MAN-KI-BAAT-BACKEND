import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'LoginScreen/login_page.dart';
class FirstScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations(
    [
      DeviceOrientation.portraitUp,
    ]
  );
  
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: {
        '/' : (context) => LoginPage(),
      },
      initialRoute: '/',
      theme: ThemeData(
        primaryColor: Color(0xff9e579d),
        backgroundColor: Color(0xffe2f3f5),
        splashColor: Colors.lightBlueAccent,
        
      ),
    );
  }
}