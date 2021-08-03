import 'package:flutter/material.dart';
import 'package:iot/home.dart';
import 'package:iot/signin.dart';
import 'package:iot/splashpage.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      darkTheme: ThemeData(
        brightness: Brightness.dark
      ),
      themeMode: ThemeMode.dark,
      home: Splash(),
    );
  }
}
