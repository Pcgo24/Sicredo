// test/screens/welcome_screen_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sicredo/screens/welcome_screen.dart';

void main() {
  testWidgets('TW-01: WelcomeScreen deve exibir título e botão "Começar"', (
    WidgetTester tester,
  ) async {
    // Arrange: Renderiza o widget dentro de um MaterialApp
    // (Necessário por causa do Navigator e temas)
    await tester.pumpWidget(const MaterialApp(home: WelcomeScreen()));

    // Act
    final titleFinder = find.text('Bem-vindo ao Sicredo Finanças!');
    final buttonFinder = find.widgetWithText(ElevatedButton, 'Começar');

    // Assert
    expect(titleFinder, findsOneWidget);
    expect(buttonFinder, findsOneWidget);
  });
}
