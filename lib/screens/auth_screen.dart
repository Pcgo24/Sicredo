import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/form_input.dart';
import '../services/auth_service.dart';

class AuthScreen extends StatefulWidget {
  AuthScreen({Key? key}) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  bool isLogin = true;
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();
  String email = '';
  String password = '';
  String name = '';
  bool _isLoading = false;

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

  Future<void> submit() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();
      
      setState(() {
        _isLoading = true;
      });

      try {
        if (isLogin) {
          // Sign in
          await _authService.signInWithEmailPassword(
            email: email,
            password: password,
          );
        } else {
          // Sign up
          await _authService.signUpWithEmailPassword(
            email: email,
            password: password,
            displayName: name,
          );
        }

        if (mounted) {
          Navigator.pushReplacementNamed(context, '/home');
        }
      } on FirebaseAuthException catch (e) {
        String message = 'Erro ao autenticar';
        
        switch (e.code) {
          case 'user-not-found':
            message = 'Usuário não encontrado';
            break;
          case 'wrong-password':
            message = 'Senha incorreta';
            break;
          case 'email-already-in-use':
            message = 'Email já cadastrado';
            break;
          case 'invalid-email':
            message = 'Email inválido';
            break;
          case 'weak-password':
            message = 'Senha muito fraca';
            break;
          default:
            message = e.message ?? 'Erro ao autenticar';
        }

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  Future<void> signInWithGoogle() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _authService.signInWithGoogle();
      
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao entrar com Google: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
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
                              onTap: _isLoading ? null : submit,
                              child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(25),
                                  color: _isLoading 
                                      ? Color(0xFF65a30d).withOpacity(0.5)
                                      : Color(0xFF65a30d),
                                ),
                                padding: EdgeInsets.symmetric(vertical: 16),
                                child: Center(
                                  child: _isLoading
                                      ? SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                          ),
                                        )
                                      : Text(
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
                            SizedBox(height: 16),
                            // Google Sign-In button
                            InkWell(
                              borderRadius: BorderRadius.circular(25),
                              splashColor: Colors.white.withOpacity(0.2),
                              onTap: _isLoading ? null : signInWithGoogle,
                              child: Container(
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(25),
                                  color: Colors.white,
                                  border: Border.all(color: Colors.grey.shade300),
                                ),
                                padding: EdgeInsets.symmetric(vertical: 16),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.g_mobiledata,
                                      size: 28,
                                      color: Color(0xFF1c365d),
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Entrar com Google',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF1c365d),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            SizedBox(height: 12),
                            InkWell(
                              borderRadius: BorderRadius.circular(12),
                              splashColor: Colors.white24,
                              onTap: _isLoading ? null : toggleMode,
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