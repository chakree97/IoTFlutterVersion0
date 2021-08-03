import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:connectivity/connectivity.dart';
import 'package:http/http.dart' as http;
import 'package:iot/home.dart';
import 'package:iot/model/model.dart';
import 'package:iot/signup.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SignIn extends StatefulWidget {
  const SignIn({ Key? key }) : super(key: key);

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  final String Url = 'http://104.198.132.47:8080/SignIn';
  TextEditingController emailControl = TextEditingController();
  TextEditingController passControl = TextEditingController();
  Message message = Message();
  bool emailempty = false;
  bool passempty = false;

  Future<void> CheckInternet() async{
    ConnectivityResult result = ConnectivityResult.none;
    final Connectivity _connectivity = Connectivity();
    try{
      result = await _connectivity.checkConnectivity();
    }catch(e){
      print(e.toString());
    }
   return SignIn(result);
  }

  Future<void> SignIn(ConnectivityResult result) async{
    switch (result){
      case ConnectivityResult.wifi:
      case ConnectivityResult.mobile:
        await CheckAccount(emailControl.text,passControl.text);
      break;
      case ConnectivityResult.none:
        await AlertError("Internet Lost Connect");
      break;
      default :
  
      break;
    }
  }

  Future<void> CheckAccount(String email,String password) async{
    Map<String,String> data = {
      'email' : email,
      'pass' : password
    };

    final response = await http.post(Uri.parse(
      Url),
      body: data
    );

    if(response.statusCode == 200){
      final SharedPreferences prefs = await _prefs;
      prefs.setString("email", email);
      prefs.setString("password", password);
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (BuildContext context)=> Home(email: email,))
        ,(route) => false);
    }
    else{
      var obj = jsonDecode(response.body);
      message = Message.fromJson(obj);
      AlertError(message.message!);
    }
  }

  Future<void>AlertError(String text) async{
    return await showDialog(
      context: context, 
      builder: (BuildContext context){
        return AlertDialog(
          backgroundColor: Theme.of(context).inputDecorationTheme.fillColor,
          title: Text('Error For Sign In'),
          content: Text(text),
          actions: [
            FlatButton(
              child: Text("Ok"),
              onPressed: (){
                Navigator.pop(context);
              },
            )
          ],
        );
      }
    );
  }

  @override
  void dispose(){
    emailControl.dispose();
    passControl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Width = MediaQuery.of(context).size.width;
    final Height = MediaQuery.of(context).size.height;
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: Width*0.06,
          vertical: Height*0.04
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              'img/smartcity.png',
              width: Width,
              height: Height*0.4,
            ),
            SizedBox(height: Height*0.06,),
            Text('- Welcome To IoT World -',style: TextStyle(fontSize: 14.0),),
            SizedBox(height: Height*0.04,),
            Container(
              height: Height*0.08,
              child: TextField(
                controller: emailControl,
                maxLines: 1,
                style: TextStyle(fontSize: 14),
                textAlignVertical: TextAlignVertical.center,
                decoration: InputDecoration(
                  filled: true,
                  prefixIcon:
                      Icon(Icons.email, color: Theme.of(context).iconTheme.color),
                  border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.all(Radius.circular(Height*0.04))),
                  fillColor: Theme.of(context).inputDecorationTheme.fillColor,
                  contentPadding: EdgeInsets.zero,
                  hintText: emailempty? 'Email Is Empty Please Fill Again':'Please Fill Your Email',
                  hintStyle: TextStyle(
                    color: emailempty? Colors.red: Colors.white
                  )
                ),
              ),
            ),
            SizedBox(height: Height*0.01,),
            Container(
              height: Height*0.08,
              child: TextField(
                controller: passControl,
                maxLines: 1,
                style: TextStyle(fontSize: 14),
                textAlignVertical: TextAlignVertical.center,
                obscureText: true,
                decoration: InputDecoration(
                  filled: true,
                  prefixIcon:
                      Icon(Icons.vpn_key ,color: Theme.of(context).iconTheme.color),
                  border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.all(Radius.circular(Height*0.04))),
                  fillColor: Theme.of(context).inputDecorationTheme.fillColor,
                  contentPadding: EdgeInsets.zero,
                  hintText: passempty? 'Password Is Empty Please Fill Again':'Please Fill Your Password',
                  hintStyle: TextStyle(
                    color: passempty? Colors.red: Colors.white
                  )
                ),
              ),
            ),
            SizedBox(height: Height*0.02,),
            Row(
              children: [
                Container(
                  width: Width*0.4,
                  height: Height*0.05,
                  decoration: BoxDecoration(
                    color: Colors.orangeAccent,
                    borderRadius: BorderRadius.circular(Height*0.025)
                  ),
                  child: FlatButton(
                    child: Text(
                      'Sign In',
                      style: TextStyle(fontSize: 14.0,color: Colors.white),
                    ),
                    onPressed: (){
                      if(emailControl.text.isEmpty){
                        setState(() {
                          emailempty = true;
                        });
                      }
                      if(passControl.text.isEmpty){
                        setState(() {
                          passempty = true;
                        });
                      }
                      if(emailControl.text.isNotEmpty && passControl.text.isNotEmpty){
                        CheckInternet();
                      }
                    },
                  ),
                ),
                Expanded(child: SizedBox(width: Width/1000,)),
                Container(
                  width: Width*0.4,
                  height: Height*0.05,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(Height*0.025)
                  ),                  
                  child: FlatButton(
                    child: Text(
                      'Sign Up',
                      style: TextStyle(fontSize: 14.0,color: Colors.black87),
                    ),
                    onPressed: (){
                      Navigator.push(context, MaterialPageRoute(builder: (BuildContext context)=> SignUp()));
                    },
                  ),
                )
              ],
            )
          ],
        ),
      )
    );
  }
}