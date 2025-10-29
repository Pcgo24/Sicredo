// integration_test/app_flow_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
// Importe seu app principal (main.dart)
import 'package:sicredo/main.dart' as app;

void main() {
  // Inicializa o binding de teste de integração
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Fluxos de Navegação Principais', () {
    testWidgets('TI-01: Fluxo de Welcome para Home', (
      WidgetTester tester,
    ) async {
      // Arrange: Inicia o app
      app.main();

      // Aguarda o app carregar
      await tester.pumpAndSettle();

      // Assert (Verificação inicial): Estamos na WelcomeScreen
      expect(find.text('Bem-vindo ao Sicredo Finanças!'), findsOneWidget);
      expect(find.text('SALDO ATUAL'), findsNothing);

      // Act: Tocar no botão "Começar"
      await tester.tap(find.text('Começar'));

      // Aguarda a navegação e animações terminarem
      await tester.pumpAndSettle();

      // Assert (Verificação final): Estamos na HomeScreen
      expect(find.text('SALDO ATUAL'), findsOneWidget);
      // Verifica se a WelcomeScreen foi removida (devido ao pushReplacementNamed)
      expect(find.text('Bem-vindo ao Sicredo Finanças!'), findsNothing);
    });

    // integration_test/app_flow_test.dart

    testWidgets('TI-02: Fluxo de Home para Slaoq (Minha Conta) e voltar', (
      WidgetTester tester,
    ) async {
      // --- CORREÇÃO ---
      // Vamos criar um localizador (Finder) específico para o TÍTULO da tela,
      // procurando por um texto "Minha Conta" que seja filho de uma AppBar.
      final slaOqScreenTitle = find.descendant(
        of: find.byType(AppBar),
        matching: find.text('Minha Conta'),
      );
      // --- FIM DA CORREÇÃO ---

      // Arrange: Inicia o app e navega para a Home
      app.main();
      await tester.pumpAndSettle();
      await tester.tap(find.text('Começar'));
      await tester.pumpAndSettle();

      // Assert (Verificação inicial): Estamos na HomeScreen
      expect(find.text('Meu Dashboard'), findsOneWidget);
      // Usamos nosso localizador específico: o TÍTULO "Minha Conta" não deve existir
      expect(slaOqScreenTitle, findsNothing);

      // Act 1: Tocar no ícone de Configurações (settings)
      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      // Assert 1: Estamos na SlaoqScreen
      // Agora o teste procura especificamente pelo TÍTULO e espera encontrar 1
      expect(slaOqScreenTitle, findsOneWidget);

      // Act 2: Tocar no botão "Voltar" da AppBar
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // Assert 2: Estamos de volta à HomeScreen
      expect(find.text('Meu Dashboard'), findsOneWidget);
      // E o TÍTULO "Minha Conta" deve sumir novamente
      expect(slaOqScreenTitle, findsNothing);
    });
  });
}
