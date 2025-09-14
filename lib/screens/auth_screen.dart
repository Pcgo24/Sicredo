import 'package:flutter/material.dart';
import '../widgets/form_input.dart';

class AuthScreen extends StatefulWidget {
  AuthScreen({Key? key}) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  bool isLogin = true;
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';
  String name = '';

  late AnimationController _controller;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: Duration(milliseconds: 700),
      vsync: this,
    );
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void toggleMode() {
    setState(() {
      isLogin = !isLogin;
    });
  }

  void submit() {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FadeTransition(
        opacity: _fadeAnim,
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF1c365d),
                Color(0xFF1d4ed8),
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        isLogin ? 'Entrar no Sicredo' : 'Cadastrar-se',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 32),
                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            if (!isLogin)
                              FormInput(
                                label: 'Nome',
                                icon: Icons.person_outline,
                                onSaved: (value) => name = value ?? '',
                                validator: (value) => value != null && value.isNotEmpty
                                    ? null
                                    : 'Informe o nome',
                              ),
                            FormInput(
                              label: 'E-mail',
                              icon: Icons.email_outlined,
                              keyboardType: TextInputType.emailAddress,
                              onSaved: (value) => email = value ?? '',
                              validator: (value) => value != null && value.contains('@')
                                  ? null
                                  : 'E-mail inválido',
                            ),
                            FormInput(
                              label: 'Senha',
                              icon: Icons.lock_outline,
                              obscureText: true,
                              onSaved: (value) => password = value ?? '',
                              validator: (value) => value != null && value.length >= 6
                                  ? null
                                  : 'Mínimo 6 caracteres',
                            ),
                            SizedBox(height: 32),
                            InkWell(
                              borderRadius: BorderRadius.circular(25),
                              splashColor: Color(0xFF65a30d).withOpacity(0.2),
                              onTap: submit,
                              child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(25),
                                  color: Color(0xFF65a30d),
                                ),
                                padding: EdgeInsets.symmetric(vertical: 16),
                                child: Center(
                                  child: Text(
                                    isLogin ? 'Entrar' : 'Cadastrar',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 12),
                            InkWell(
                              borderRadius: BorderRadius.circular(12),
                              splashColor: Colors.white24,
                              onTap: toggleMode,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
                                child: Text(
                                  isLogin
                                      ? 'Não tem conta? Cadastre-se'
                                      : 'Já tem conta? Entrar',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}