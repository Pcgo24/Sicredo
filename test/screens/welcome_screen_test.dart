import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sicredo/screens/welcome_screen.dart';

void main() {
  testWidgets('TW-01: WelcomeScreen deve exibir ícone, título e botão',
      (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: WelcomeScreen(),
    ));

    await tester.pumpAndSettle();

    final iconFinder = find.byIcon(Icons.account_balance_wallet_outlined);
    final titleFinder = find.text('Bem-vindo(a) ao Sicredo');
    final buttonFinder = find.text('Começar');

    expect(iconFinder, findsOneWidget);
    expect(titleFinder, findsOneWidget);
    expect(buttonFinder, findsOneWidget);
  });
}