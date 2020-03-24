import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mann_ki_baat/LoginScreen/login_data.dart';
import 'package:mann_ki_baat/LoginScreen/login_page.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'dart:async';
import 'package:mann_ki_baat/ThirdPage/third_page.dart';
import 'package:mann_ki_baat/ThirdPage/result_data.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';

// https://medium.com/flutter/the-power-of-webviews-in-flutter-a56234b57df2

enum Sex { Male, Female, Other }
class QuestionaryPage extends StatefulWidget {
  QuestionaryPage({Key key, this.data, this.googleSignIn, this.firebaseUser, this.facebookLogin}) : super(key: key);
  final Data data;
  final GoogleSignIn googleSignIn;
  final FirebaseUser firebaseUser;
  final FacebookLogin facebookLogin;
  @override
  _QuestionaryPageState createState() => _QuestionaryPageState();
}

class _QuestionaryPageState extends State<QuestionaryPage> {

  final String _url = 'https://google.com/'; //url of questionary page
  Completer<WebViewController> _controller = Completer<WebViewController>();

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations(
    [
      DeviceOrientation.portraitUp,
    ]
  );
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              flex: 10,
              child: WebView(
                initialUrl: _url,
                javascriptMode: JavascriptMode.unrestricted,
                onWebViewCreated: (WebViewController webViewController) {
                  _controller.complete(webViewController);
                },
              ),
            ),
            Divider(
              color: Colors.amberAccent,
              thickness: 40,
              height: 20,
            ),
            Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: RaisedButton(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(10))),
                    color: Color(0xffd93d3d),
                    child: Text(
                      'SUBMIT',
                      style: TextStyle(color: Colors.white, fontSize: 14.0),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ThirdPage(
                            result: Result(
                            
                              data: widget.data,
                            ),
                            googleSignIn: widget.googleSignIn,
                            firebaseUser: widget.firebaseUser,
                            facebookLogin: facebookLogin,
                          )
                        ),
                      );
                    },
                  ),
                )),
          ],
        ),
      ),
      // floatingActionButton: FloatingActionButton.extended(
      //   label: Text('Questions'),
      //   onPressed: (){},
      // ),
    );
  }
}
