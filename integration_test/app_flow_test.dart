import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:sicredo/main.dart' as app;
import 'package:sicredo/widgets/form_input.dart';
import 'package:sicredo/data/database/database_helper.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  // Initialize FFI for testing on non-mobile platforms
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  setUp(() async {
    // Reset database before each test
    await DatabaseHelper.instance.reset();
  });

  tearDown(() async {
    // Clean up after each test
    await DatabaseHelper.instance.close();
  });

  group('Fluxos de Integração do App', () {
    testWidgets('TI-01: Fluxo de Welcome -> Auth -> Home',
        (WidgetTester tester) async {
      // Arrange: Inicia o app
      app.main();
      await tester.pumpAndSettle();

      // --- TELA DE WELCOME ---
      // Assert:
      expect(find.text('Bem-vindo(a) ao Sicredo'), findsOneWidget);

      // Act:
      await tester.tap(find.text('Começar'));
      await tester.pumpAndSettle();

      // Assert: Confirma que estamos na AuthScreen
      expect(find.text('Entrar no Sicredo'), findsOneWidget);

      // Act: Preenche o formulário de login
      // Encontra os widgets FormInput pelo seu 'label' (hintText)
      final emailField = find.widgetWithText(FormInput, 'E-mail');
      final passField = find.widgetWithText(FormInput, 'Senha');

      await tester.enterText(emailField, 'teste@integracao.com');
      await tester.enterText(passField, '123456');

      await tester.tap(find.text('Entrar'));
      await tester.pumpAndSettle();

      // --- TELA DE HOME ---
      // Assert: Confirma que estamos na HomeScreen
      expect(find.text('Saldo Total'), findsOneWidget);
      // Confirma que a tela de Login sumiu
      expect(find.text('Entrar no Sicredo'), findsNothing);
    });

    testWidgets('TI-02: Fluxo de Adicionar Saldo na HomeScreen',
        (WidgetTester tester) async {
      // Arrange: Inicia o app e faz o login
      app.main();
      await tester.pumpAndSettle();
      await tester.tap(find.text('Começar'));
      await tester.pumpAndSettle();
      await tester.enterText(
          find.widgetWithText(FormInput, 'E-mail'), 'a@b.com');
      await tester.enterText(find.widgetWithText(FormInput, 'Senha'), '123456');
      await tester.tap(find.text('Entrar'));
      await tester.pumpAndSettle();

      // --- TELA DE HOME (Estado Inicial) ---

      // No início, o saldo é 0.0, então a Key é ValueKey(0.0)
      final initialBalanceFinder = find.byKey(const ValueKey(0.0));

      // Assert
      expect(initialBalanceFinder, findsOneWidget);
      expect(
          find.text('Nenhum saldo ou gasto registrado ainda.'), findsOneWidget);

      // Act: Adicionar um novo saldo
      // 1. Toca em "Adicionar Saldo"
      await tester.tap(find.text('Adicionar Saldo'));
      await tester.pumpAndSettle(); // Aguarda o Dialog aparecer

      // 2. Encontra os campos do formulário NO DIALOG
      final dialogFormFields = find.byType(TextFormField);
      final nomeField = dialogFormFields.first;
      final valorField = dialogFormFields.last;

      // 3. Preenche o formulário do dialog
      await tester.enterText(nomeField, 'Salário');
      await tester.enterText(valorField, '1200.50');

      // 4. Toca em "Salvar" (no Dialog)
      await tester.tap(find.text('Salvar'));
      await tester
          .pumpAndSettle();

      // --- TELA DE HOME (Estado Final) ---
      final updatedBalanceFinder = find.byKey(const ValueKey(1200.50));

      // Assert:
      // 1. O saldo total foi atualizado (procurando pela nova Key)
      expect(updatedBalanceFinder, findsOneWidget);
      // 2. O saldo antigo (Key 0.0) não existe mais
      expect(initialBalanceFinder, findsNothing);

      // 3. A lista de extrato foi atualizada com o item "Salário"
      expect(find.text('Salário'), findsOneWidget);
      // 4. O valor formatado está na lista
      expect(find.text('+ R\$ 1200.50'), findsOneWidget);
      // 5. A mensagem de "lista vazia" sumiu
      expect(
          find.text('Nenhum saldo ou gasto registrado ainda.'), findsNothing);
    });
  });
}
