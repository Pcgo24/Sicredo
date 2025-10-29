// test/screens/home_screen_test.dart
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sicredo/screens/home_screen.dart';

void main() {
  testWidgets('TW-02: HomeScreen deve exibir "SALDO ATUAL" e PieChart', (
    WidgetTester tester,
  ) async {
    // Arrange: Renderiza o widget
    // Precisamos do MaterialApp por causa do Scaffold/AppBar
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

    // Act
    final balanceFinder = find.text('SALDO ATUAL');
    final balanceAmountFinder = find.text('R\$ 2.845,00');
    final chartFinder = find.byType(PieChart);

    // Assert
    expect(balanceFinder, findsOneWidget);
    expect(balanceAmountFinder, findsOneWidget);
    expect(chartFinder, findsOneWidget);
  });
}
