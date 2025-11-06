import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:sicredo/presentation/screens/cotacoes_screen.dart';

// Note: firebase_options.dart should be generated using FlutterFire CLI
// Run: flutterfire configure --project=sicredo-34f2e
// This file is gitignored and must be generated locally
// import 'firebase_options.dart';

// Imports relativos do próprio projeto após os imports de package:
import 'screens/welcome_screen.dart';
import 'screens/auth_screen.dart';
import 'screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    // If .env file doesn't exist, continue with defaults
    debugPrint('Warning: .env file not found. Using defaults.');
  }
  
  // Initialize Firebase
  // Note: Uncomment the following lines after generating firebase_options.dart
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );
  
  // Configure Firebase Emulator if enabled
  // if (dotenv.env['USE_FIREBASE_EMULATOR'] == 'true') {
  //   final firestorePort = int.tryParse(dotenv.env['FIRESTORE_EMULATOR_PORT'] ?? '8080') ?? 8080;
  //   final authPort = int.tryParse(dotenv.env['AUTH_EMULATOR_PORT'] ?? '9099') ?? 9099;
  //   
  //   FirebaseFirestore.instance.useFirestoreEmulator('localhost', firestorePort);
  //   await FirebaseAuth.instance.useAuthEmulator('localhost', authPort);
  // }
  
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