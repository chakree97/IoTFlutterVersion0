import 'package:flutter/material.dart';
import 'package:iot/home.dart';
import 'package:iot/signin.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Splash extends StatefulWidget {
  const Splash({ Key? key }) : super(key: key);

  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  bool HomePage = false;
  String? email;
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  @override
  void initState(){
    super.initState();
    var future = new Future.delayed(const Duration(seconds: 3), ()=>CheckSignIn());
  }

  Future<void> CheckSignIn() async{
    SharedPreferences preferences = await _prefs;
    String? emailprefs = await preferences.getString('email');
    if(emailprefs != null){ 
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (BuildContext context)=> Home(email: emailprefs,)),
        (route) => false);
    }
    else{
      print("no data");
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (BuildContext context)=> SignIn()),
        (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}