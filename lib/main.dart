import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mylocation/MyHomePage.dart';
import 'package:mylocation/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  SharedPreferences preferences=await SharedPreferences.getInstance();
  bool login=preferences.getBool("admin")??false;
  runApp( MyApp(login: login,));
}

class MyApp extends StatelessWidget {
  final login;
  const MyApp({this.login});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home:Login(),
    );
  }
}
