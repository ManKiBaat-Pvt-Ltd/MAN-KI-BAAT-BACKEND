import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';

class Data {
  String username;
  // String mobileNumber;
  String id;
  int age;
  String sex;
  String email;
  String imageUrl;
  bool hasImage;
  GoogleSignIn googleSignIn;
  FirebaseUser firebaseUser;
  FacebookLogin facebookLogin;
  Data({this.username,this.age,this.sex,this.email = ' ', this.imageUrl, this.hasImage = false, this.id= '', this.googleSignIn, this.facebookLogin, this.firebaseUser});

 

}