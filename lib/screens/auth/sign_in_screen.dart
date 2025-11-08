import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/service/auth_service.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _isLogin = true;
  bool _loading = false;
  String? _error;

  Future<void> _submit() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      if (_isLogin) {
        await AuthService.instance.signInWithEmailPassword(
          email: _email.text.trim(),
          password: _password.text,
        );
      } else {
        await AuthService.instance.signUpWithEmailPassword(
          email: _email.text.trim(),
          password: _password.text,
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() => _error = e.message);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _google() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await AuthService.instance.signInWithGoogle();
    } on FirebaseAuthException catch (e) {
      setState(() => _error = e.message);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Entrar')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Text(_error!, style: const TextStyle(color: Colors.red)),
                  ),
                TextField(
                  controller: _email,
                  decoration: const InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _password,
                  decoration: const InputDecoration(labelText: 'Senha'),
                  obscureText: true,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loading ? null : _submit,
                  child: Text(_isLogin ? 'Entrar' : 'Criar conta'),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: _loading ? null : _google,
                  icon: const Icon(Icons.login),
                  label: const Text('Entrar com Google'),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: _loading
                      ? null
                      : () => setState(() => _isLogin = !_isLogin),
                  child: Text(_isLogin
                      ? 'Não tem conta? Cadastre-se'
                      : 'Já tem conta? Entrar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}