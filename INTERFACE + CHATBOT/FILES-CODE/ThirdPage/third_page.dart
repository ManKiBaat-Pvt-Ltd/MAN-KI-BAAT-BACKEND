import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mann_ki_baat/ThirdPage/options/blog.dart';
import 'chat_page.dart';
import 'result_data.dart';
import 'package:mann_ki_baat/ThirdPage/options/result_page.dart';
import 'package:mann_ki_baat/ThirdPage/options/faq.dart';
import 'package:mann_ki_baat/ThirdPage/options/doctor_talk.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:mann_ki_baat/componenets.dart';

final _fireStore = Firestore.instance;
final FirebaseAuth _auth = FirebaseAuth.instance;

enum Options { result, FAQ, talk, blog }

class ThirdPage extends StatefulWidget {
  ThirdPage(
      {Key key,
      this.result,
      this.googleSignIn,
      this.firebaseUser,
      this.facebookLogin});
  @override
  _ThirdPageState createState() => _ThirdPageState();
  final Result result;
  final GoogleSignIn googleSignIn;
  final FirebaseUser firebaseUser;
  final FacebookLogin facebookLogin;
}

class _ThirdPageState extends State<ThirdPage> {
  @override
  bool _showSnackBar = false;
  void initState() {
    super.initState();
    _selectedOption = Options.result;
    _fireStore.collection('users').document(widget.result.data.id).updateData({
      'isAvailable': 0,
    });
    // print(widget.result.data.imageUrl);
  }

  Options _selectedOption;
  var appBarText = 'Result';
  bool _showSpinner = false;

  Widget getSelectedWidget(Options option) {
    switch (_selectedOption) {
      case Options.result:
        appBarText = 'Result';
        return ResultPage();
      case Options.FAQ:
        appBarText = 'FAQ';
        return FAQ();
      case Options.talk:
        appBarText = 'Talk To Doctor';
        return Talk();
      case Options.blog:
        appBarText = 'Blog';
        return Blog();
    }
  }

  void displaySnackBar() {
    if (_showSnackBar) {
      final snackBar = SnackBar(
        content: Text('Noone is online try again!!'),
        backgroundColor: Colors.black12,
        duration: Duration(seconds: 5),
      );
      Scaffold.of(context).showSnackBar(snackBar);
    }
  }

  String getEmail() {
    return widget.googleSignIn != null ? widget.firebaseUser.email : " ";
  }

  var fireStore = Firestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Mann Ki Baat'),
      ),
      drawer: SafeArea(
        child: Drawer(
          child: ListView(
            children: <Widget>[
              UserAccountsDrawerHeader(
                accountName: Text('${widget.result.data.username}'),
                accountEmail: Text(getEmail()),
                currentAccountPicture: widget.result.data.hasImage
                    ? Image.network(widget.result.data.imageUrl)
                    : DefaultAvatar(username: widget.result.data.username),
              ),
              ListTile(
                title: Text("Result"),
                trailing: Icon(Icons.receipt),
                onTap: () {
                  setState(() {
                    Navigator.of(context).pop();
                    _selectedOption = Options.result;
                  });
                },
              ),
              ListTile(
                title: Text("FAQ"),
                trailing: Icon(Icons.add_comment),
                onTap: () {
                  setState(() {
                    Navigator.of(context).pop();

                    _selectedOption = Options.FAQ;
                  });
                },
              ),
              ListTile(
                title: Text("Talk to doctor"),
                trailing: Icon(Icons.question_answer),
                onTap: () {
                  setState(() {
                    Navigator.of(context).pop();

                    _selectedOption = Options.talk;
                  });
                },
              ),
              ListTile(
                title: Text("Blog"),
                trailing: Icon(Icons.book),
                onTap: () {
                  setState(() {
                    Navigator.of(context).pop();

                    _selectedOption = Options.blog;
                  });
                },
              ),
              Divider(height: 45),
              ListTile(
                onTap: () async {
                  setState(() {
                    _showSpinner = true;
                    Navigator.of(context).pop();
                  });
                  _auth.signOut();
                  setState(() {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  });
                },
                title: Text('Logout'),
                trailing: Icon(
                  Icons.exit_to_app,
                ),
              )
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: SafeArea(child: getSelectedWidget(_selectedOption)),
      ),
      floatingActionButton: FloatingActionButton.extended(
        label: Text('CHAT'),
        icon: Icon(Icons.chat_bubble),
        onPressed: () async {

          _fireStore
              .collection('users')
              .document(widget.result.data.id)
              .updateData({
            'isAvailable': 1,
          });

          final QuerySnapshot result = await Firestore.instance
              .collection('users')
              .where('isAvailable', isEqualTo: 1)
              .getDocuments();

          final List<DocumentSnapshot> users = result.documents;

          if (users.length == 1) {
            print('Noone is online!!!');
            setState(() {
              _showSnackBar = true;
            });
            // TODO: handle showing proper message when no online user was found

          } else {
            print('${users.length - 1} persons are online excluding you ');
            var otherUserId;
            var otherUserName;
            var otherUserImage;
            bool isUserAvailable = false;
            for (var user in users) {
              final currentUser = user.data['id'];
              if (currentUser != widget.result.data.id) {
                // {
                isUserAvailable = true;
                otherUserId = currentUser;
                otherUserName = user['nickname'];
                otherUserImage = user['photoUrl'];
                break;
              }
              if (isUserAvailable) break;
            }
            if (isUserAvailable) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatPage(
                    myId: widget.result.data.id,
                    otherId: otherUserId,
                    otherUserName: otherUserName,
                    imageUrlOther: otherUserImage,
                  ),
                ),
              );
            }
          }
        },
      ),
    );
  }
}
