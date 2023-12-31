import 'package:ai_mobileapp/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_ui_auth/firebase_ui_auth.dart';
import 'package:ai_mobileapp/login.dart';
import 'package:ai_mobileapp/ajoutActivate.dart';
import 'package:ai_mobileapp/Listesdesactivities.dart';



  Future<void> main() async{
    WidgetsFlutterBinding.ensureInitialized();
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    FirebaseUIAuth.configureProviders([EmailAuthProvider()]);
    runApp(MyApp());}



class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/login',
      routes: {
        '/login': (context) => Loginecran(),
        '/addActivity': (context) => AddActivity(),
        '/ListActivity':(context) => ListActivity(),
      },
    );
  }
}