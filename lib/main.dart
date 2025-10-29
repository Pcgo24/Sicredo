import 'package:flutter/material.dart';
<<<<<<< HEAD
import 'package:sicredo/routes/app_routes.dart';
import 'package:sicredo/routes/router.dart';
import 'package:sicredo/screens/home_screen.dart';
=======
import 'screens/welcome_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/home_screen.dart';
import 'screens/cotacao_screen.dart';
>>>>>>> 26963ab136b7561a9b9cce16be5bd4bbc049c2ab

void main() {
  runApp(SicredoApp());
}

class SicredoApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sicredo',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => WelcomeScreen(),
        '/auth': (context) => AuthScreen(),
        '/home': (context) => HomeScreen(),
        '/cotacao': (context) => CotacoesScreen(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}