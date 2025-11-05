import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'screens/welcome_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/home_screen.dart';

// Nova tela em presentation (versão com Riverpod)
import 'package:sicredo/presentation/screens/cotacoes_screen.dart';

void main() {
  runApp(const ProviderScope(child: SicredoApp()));
}

class SicredoApp extends StatelessWidget {
  const SicredoApp({super.key});

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
        // Atualizado: usa a tela baseada em Riverpod
        '/cotacao': (context) => const CotacoesScreen(),
      },
    );
  }
}