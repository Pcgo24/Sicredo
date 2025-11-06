import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:sicredo/main.dart' as app;
import 'package:sicredo/widgets/form_input.dart';

// NOTE: Firebase integration tests require special setup
// See README.firebase.md section "Testing" for instructions
// You need to either:
// 1. Use Firebase Emulator (recommended for CI/CD)
// 2. Use a test Firebase project
// 3. Mock Firebase services (for unit tests only)

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Basic App Flow Tests', () {
    testWidgets('TI-01: Should navigate from Welcome to Auth screen',
        (WidgetTester tester) async {
      // NOTE: This test only verifies navigation, not Firebase functionality
      // For full Firebase integration tests, use Firebase Emulator
      
      // Arrange: Start the app
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // --- WELCOME SCREEN ---
      // Assert: Check we're on welcome screen
      expect(find.text('Bem-vindo(a) ao Sicredo'), findsOneWidget);

      // Act: Tap the start button
      await tester.tap(find.text('Começar'));
      await tester.pumpAndSettle();

      // Assert: Verify we're on the Auth screen
      expect(find.text('Entrar no Sicredo'), findsOneWidget);
      expect(find.widgetWithText(FormInput, 'E-mail'), findsOneWidget);
      expect(find.widgetWithText(FormInput, 'Senha'), findsOneWidget);
    });

    testWidgets('TI-02: Should show validation errors on empty auth form',
        (WidgetTester tester) async {
      // Arrange: Navigate to auth screen
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));
      await tester.tap(find.text('Começar'));
      await tester.pumpAndSettle();

      // Act: Try to submit empty form
      await tester.tap(find.text('Entrar'));
      await tester.pump();

      // Assert: Validation errors should appear
      expect(find.text('E-mail inválido'), findsOneWidget);
      expect(find.text('Mínimo 6 caracteres'), findsOneWidget);
    });

    testWidgets('TI-03: Should toggle between login and signup modes',
        (WidgetTester tester) async {
      // Arrange: Navigate to auth screen
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));
      await tester.tap(find.text('Começar'));
      await tester.pumpAndSettle();

      // Assert: Initially in login mode
      expect(find.text('Entrar no Sicredo'), findsOneWidget);
      expect(find.text('Entrar'), findsOneWidget);

      // Act: Switch to signup mode
      await tester.tap(find.text('Não tem conta? Cadastre-se'));
      await tester.pumpAndSettle();

      // Assert: Now in signup mode
      expect(find.text('Cadastrar-se'), findsOneWidget);
      expect(find.text('Cadastrar'), findsOneWidget);
      expect(find.widgetWithText(FormInput, 'Nome'), findsOneWidget);

      // Act: Switch back to login mode
      await tester.tap(find.text('Já tem conta? Entrar'));
      await tester.pumpAndSettle();

      // Assert: Back to login mode
      expect(find.text('Entrar no Sicredo'), findsOneWidget);
      expect(find.text('Entrar'), findsOneWidget);
    });
  });

  // For full Firebase integration tests with authentication and Firestore:
  // 1. Set up Firebase Emulator: firebase emulators:start
  // 2. Configure app to use emulator (see main.dart)
  // 3. Create test user accounts in emulator
  // 4. Test CRUD operations with Firestore
  // 
  // Example test structure (requires Firebase Emulator):
  // 
  // testWidgets('TI-04: Full flow with Firebase Auth and Firestore', (tester) async {
  //   // 1. Create test user
  //   // 2. Sign in with test credentials
  //   // 3. Add transaction to Firestore
  //   // 4. Verify transaction appears in UI
  //   // 5. Delete transaction
  //   // 6. Sign out
  // });
}
