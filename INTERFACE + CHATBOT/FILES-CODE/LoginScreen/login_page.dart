import 'package:flutter/material.dart';
import 'login_data.dart';
import 'package:flutter/services.dart';
import 'package:mann_ki_baat/QuestionaryPage/second_page.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


final GoogleSignIn _googleSignIn = GoogleSignIn();
final FirebaseAuth _auth = FirebaseAuth.instance;
final _fireStore = Firestore.instance;
var facebookLogin = FacebookLogin();

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

enum Sex { Male, Female, Other }

class _LoginPageState extends State<LoginPage> {
  final Color textColor = Color(0xfffffdd0);
  String _username;
  // String _id;
  int _age;
  Sex _sex;

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('images/woman.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        constraints: BoxConstraints.expand(),
        child: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.only(bottom: 10, top: 300),
            child: Column(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.only(left: 25),
                  child: TextField(
                    style: TextStyle(color: Colors.black, fontSize: 18),
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                        hintStyle: TextStyle(color: Colors.red, fontSize: 20),
                        hintText: 'Username'),
                    onChanged: (String val) {
                      _username = val;
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 25),
                  child: TextField(
                    style: TextStyle(color: Colors.black, fontSize: 18),
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintStyle: TextStyle(color: Colors.red, fontSize: 20),
                      hintText: 'Age',
                    ),
                    onChanged: (String val) {
                      _age = int.parse(val);
                    },
                  ),
                ),
                RadioListTile<Sex>(
                  activeColor: Color(0xffa6341b),
                  title: const Text(
                    'Male',
                    style: TextStyle(color: Colors.red, fontSize: 20),
                  ),
                  value: Sex.Male,
                  groupValue: _sex,
                  onChanged: (Sex val) {
                    setState(() {
                      _sex = val;
                    });
                  },
                ),
                RadioListTile<Sex>(
                  activeColor: Color(0xffa6341b),
                  title: const Text('Female',
                      style: TextStyle(color: Colors.red, fontSize: 20)),
                  value: Sex.Female,
                  groupValue: _sex,
                  onChanged: (Sex val) {
                    setState(() {
                      _sex = val;
                    });
                  },
                ),
                RadioListTile<Sex>(
                  activeColor: Color(0xffa6341b),
                  title: const Text(
                    'Other',
                    style: TextStyle(color: Colors.red, fontSize: 20),
                  ),
                  value: Sex.Other,
                  groupValue: _sex,
                  onChanged: (Sex val) {
                    setState(() {
                      _sex = val;
                    });
                  },
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 25, right: 50),
                  child: Row(
                    children: <Widget>[
                      RaisedButton(
                        shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10))),
                        color: Color(0xffd93d3d),
                        child: Padding(
                          padding: const EdgeInsets.all(18.0),
                          child: Text(
                            'SIGN UP',
                            style:
                                TextStyle(color: Colors.white, fontSize: 14.0),
                          ),
                        ),
                        onPressed: () async {
                            // implement email and password login
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => QuestionaryPage(
                                      data: Data(
                                        username: _username,
                                        age: _age,
                                        sex: _sex == Sex.Male
                                            ? 'male'
                                            : _sex == Sex.Female
                                                ? 'female'
                                                : 'other',
                                        hasImage: false,
                                        imageUrl: null,
                                      ),
                                    )),
                          );
                        },
                      ),
                      Spacer(),
                      GestureDetector(
                        onTap: () async {
                          //   //implement google sign-in

                          FirebaseUser firebaseUser =
                              await _handleGoogleSignIn();

                          if (firebaseUser != null) {
                            //   // Check is already sign up
                            final QuerySnapshot result = await Firestore
                                .instance
                                .collection('users')
                                .where('id', isEqualTo: firebaseUser.uid)
                                .getDocuments();
                            final List<DocumentSnapshot> documents =
                                result.documents;

                            if (documents.length == 0) {
                              // Update data to server if new user
                              _fireStore
                                  .collection('users')
                                  .document(firebaseUser.uid)
                                  .setData({
                                'nickname': firebaseUser.displayName,
                                'photoUrl': firebaseUser.photoUrl,
                                'id': firebaseUser.uid,
                                'isAvailable': 0,
                              });
                            }
                          }

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => QuestionaryPage(
                                      data: Data(
                                          id: firebaseUser.uid,
                                          username: firebaseUser.displayName,
                                          hasImage: true,
                                          imageUrl: firebaseUser.photoUrl),
                                      googleSignIn: _googleSignIn,
                                      firebaseUser: firebaseUser,
                                      facebookLogin: null,
                                    )),
                          );
                        },
                        child: CircleAvatar(
                          backgroundImage: AssetImage('images/google_logo.jpg'),
                          radius: 30,
                        ),
                      ),
                      Spacer(),
                      GestureDetector(
                        onTap: () async {
                          //implement facebook sign-in

                          FacebookLoginResult facebookLoginResult =
                              await _handleFBSignIn();

                          final accessToken =
                              facebookLoginResult.accessToken.token;
                          if (facebookLoginResult.status ==
                              FacebookLoginStatus.loggedIn) {
                            final facebookAuthCred =
                                FacebookAuthProvider.getCredential(
                                    accessToken: accessToken);
                            final user = await _auth
                                .signInWithCredential(facebookAuthCred);

                            var graphResponse = await http.get(
                                'https://graph.facebook.com/v2.12/me?fields=name,email,picture.height(200)&access_token=${facebookLoginResult.accessToken.token}');
                            var profileData = jsonDecode(graphResponse.body);

                            if (user != null) {
                              final QuerySnapshot result = await Firestore
                                  .instance
                                  .collection('users')
                                  .where('id', isEqualTo: profileData['id'])
                                  .getDocuments();
                              final List<DocumentSnapshot> documents =
                                  result.documents;

                              if (documents.length == 0) {
                                // Update data to server if new user
                                _fireStore
                                    .collection('users')
                                    .document(profileData['id'])
                                    .setData({
                                  'nickname': profileData['name'],
                                  'photoUrl': profileData['picture']['data']
                                      ['url'],
                                  'id': profileData['id'],
                                  'isAvailable': 0,
                                });
                              }
                            }

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => QuestionaryPage(
                                        data: Data(
                                            id: profileData['id'],
                                            username: profileData['name'],
                                            hasImage: true,
                                            imageUrl: profileData['picture']
                                                ['data']['url']),
                                        facebookLogin: facebookLogin,
                                        googleSignIn: null,
                                      )),
                            );
                          }
                        },
                        child: CircleAvatar(
                          backgroundImage: AssetImage('images/facebook.jpg'),
                          radius: 35,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Future<FirebaseUser> _handleGoogleSignIn() async {
  final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
  final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

  final AuthCredential credential = GoogleAuthProvider.getCredential(
    accessToken: googleAuth.accessToken,
    idToken: googleAuth.idToken,
  );

  final FirebaseUser user = (await _auth.signInWithCredential(credential)).user;
  print("signed in " + user.displayName);

  return user;
}

Future<FacebookLoginResult> _handleFBSignIn() async {
  FacebookLogin facebookLogin = FacebookLogin();
  FacebookLoginResult facebookLoginResult =
      await facebookLogin.logIn(['email']);
  switch (facebookLoginResult.status) {
    case FacebookLoginStatus.cancelledByUser:
      print("Cancelled");
      break;
    case FacebookLoginStatus.error:
      print("error");
      break;
    case FacebookLoginStatus.loggedIn:
      print("Logged In");
      break;
  }
  return facebookLoginResult;
}
