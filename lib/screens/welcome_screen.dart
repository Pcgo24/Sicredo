import 'package:flutter/material.dart';
import '../routes/app_routes.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 1. Logo do App
              Image.asset(
                'assets/images/sicredo.png',
                width: 250, // Ajuste o tamanho conforme necessário
              ),
              const SizedBox(height: 40),

              // 2. Título de apresentação
              const Text(
                'Bem-vindo ao Sicredo Finanças!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF003366), // Um azul escuro
                ),
              ),
              const SizedBox(height: 16),

              // 3. Breve descrição
              const Text(
                'O seu assistente pessoal para uma vida financeira mais saudável. Controle seus gastos, planeje seu futuro e alcance seus objetivos.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
              const SizedBox(height: 50),

              // 4. Botão para começar
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green, // Cor do botão
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 15,
                  ),
                  textStyle: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onPressed: () {
                  // Usamos pushReplacementNamed para que o usuário não possa "voltar" para a tela de welcome
                  Navigator.pushReplacementNamed(context, AppRoutes.home);
                },
                child: const Text('Começar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
