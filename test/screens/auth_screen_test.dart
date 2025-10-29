import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sicredo/screens/auth_screen.dart';
import 'package:sicredo/widgets/form_input.dart';

void main() {
  // Helper para renderizar a AuthScreen (evita repetição)
  Future<void> pumpAuthScreen(WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(

      routes: {
        '/': (context) => AuthScreen(),
        '/home': (context) => const Scaffold(body: Text('HomePage Mock')),
      },
    ));

    await tester.pumpAndSettle();
  }

  group('AuthScreen Widget Tests', () {
    testWidgets('TW-02: Deve exibir erros de validação com campos vazios',
        (WidgetTester tester) async {
      // Arrange
      await pumpAuthScreen(tester);

      // Act
      await tester.tap(find.text('Entrar'));
      await tester.pump();

      // Assert
      expect(find.text('E-mail inválido'), findsOneWidget);
      expect(find.text('Mínimo 6 caracteres'), findsOneWidget);
    });

    testWidgets('Deve alternar para o modo Cadastro e exibir o campo "Nome"',
        (WidgetTester tester) async {
      // Arrange
      await pumpAuthScreen(tester);

      // Act
      await tester.tap(find.text('Não tem conta? Cadastre-se'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Cadastrar-se'), findsOneWidget);
      expect(find.text('Cadastrar'), findsOneWidget);
      expect(find.widgetWithText(FormInput, 'Nome'), findsOneWidget);
    });
  });
}