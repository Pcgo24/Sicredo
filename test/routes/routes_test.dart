// test/routes/router_test.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sicredo/routes/app_routes.dart';
import 'package:sicredo/routes/router.dart';
import 'package:sicredo/screens/home_screen.dart';
import 'package:sicredo/screens/slaoq_screen.dart';
import 'package:sicredo/screens/welcome_screen.dart';

void main() {
  group('AppRouter Unit Tests', () {
    test('TU-01: Deve gerar a rota /home para HomeScreen', () {
      // Arrange
      final settings = const RouteSettings(name: AppRoutes.home);

      // Act
      final route = AppRouter.generateRoute(settings);

      // Assert
      // Verifica se é um MaterialPageRoute
      expect(route, isA<MaterialPageRoute>());
      // Verifica se o builder constrói a HomeScreen
      expect(
        (route as MaterialPageRoute).builder(MockBuildContext()),
        isA<HomeScreen>(),
      );
    });

    // Você pode testar as outras rotas também
    test('TU-Extra: Deve gerar a rota / para WelcomeScreen', () {
      final settings = const RouteSettings(name: AppRoutes.welcome);
      final route = AppRouter.generateRoute(settings);
      expect(
        (route as MaterialPageRoute).builder(MockBuildContext()),
        isA<WelcomeScreen>(),
      );
    });

    test('TU-Extra: Deve gerar a rota /slaoq para SlaoqScreen', () {
      final settings = const RouteSettings(name: AppRoutes.slaoq);
      final route = AppRouter.generateRoute(settings);
      expect(
        (route as MaterialPageRoute).builder(MockBuildContext()),
        isA<SlaoqScreen>(),
      );
    });

    test(
      'TU-02: Deve gerar a tela de "Rota não encontrada" para rotas desconhecidas',
      () {
        // Arrange
        final settings = const RouteSettings(name: '/rota-que-nao-existe');

        // Act
        final route = AppRouter.generateRoute(settings);
        final widget = (route as MaterialPageRoute).builder(MockBuildContext());

        // Assert
        // Renderiza o widget para encontrar o Scaffold e o Text
        final scaffold = widget as Scaffold;
        final text = (scaffold.body as Center).child as Text;

        expect(text.data, 'Rota não encontrada: /rota-que-nao-existe');
      },
    );
  });
}

// Classe Mock para evitar erros de BuildContext
class MockBuildContext extends BuildContext {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
