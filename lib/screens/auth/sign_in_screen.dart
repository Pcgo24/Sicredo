import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/service/auth_service.dart';
import '../../core/service/firestore_service.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();

  bool _isLogin = true;
  bool _loading = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  String? _error;

  Future<void> _submit() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final email = _email.text.trim();
      final password = _password.text;

      if (email.isEmpty) {
        throw Exception('Informe o email.');
      }
      if (password.length < 6) {
        throw Exception('A senha deve ter pelo menos 6 caracteres.');
      }

      if (_isLogin) {
        await AuthService.instance.signInWithEmailPassword(
          email: email,
          password: password,
        );
      } else {
        final name = _name.text.trim();
        if (name.isEmpty) {
          throw Exception('Informe o nome.');
        }
        final confirm = _confirmPassword.text;
        if (confirm != password) {
          throw Exception('As senhas não conferem.');
        }

        final cred = await AuthService.instance.signUpWithEmailPassword(
          email: email,
          password: password,
        );

        // Atualiza displayName (Auth) e salva perfil no Firestore
        await cred.user?.updateDisplayName(name);
        await cred.user?.reload();

        await FirestoreService.instance.upsertUserProfile(
          name: name,
          email: email,
          // sem foto (email/senha)
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

      // Após login com Google, garante o perfil no Firestore com foto
      final u = FirebaseAuth.instance.currentUser;
      if (u != null) {
        await FirestoreService.instance.upsertUserProfile(
          name: u.displayName ?? 'Usuário',
          email: u.email,
          photoUrl: u.photoURL,
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

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final title = _isLogin ? 'Entrar' : 'Criar conta';
    return Scaffold(
      appBar: AppBar(title: Text(title)),
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
                    child: Text(
                      _error!,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                if (!_isLogin)
                  TextField(
                    controller: _name,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: 'Nome',
                      prefixIcon: Icon(Icons.person),
                    ),
                  ),
                if (!_isLogin) const SizedBox(height: 8),
                TextField(
                  controller: _email,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _password,
                  decoration: InputDecoration(
                    labelText: 'Senha',
                    prefixIcon: const Icon(Icons.lock),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () => setState(
                        () => _obscurePassword = !_obscurePassword,
                      ),
                      tooltip: _obscurePassword ? 'Mostrar senha' : 'Ocultar senha',
                    ),
                  ),
                  obscureText: _obscurePassword,
                ),
                if (!_isLogin) const SizedBox(height: 8),
                if (!_isLogin)
                  TextField(
                    controller: _confirmPassword,
                    decoration: InputDecoration(
                      labelText: 'Confirmar senha',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirm ? Icons.visibility : Icons.visibility_off,
                        ),
                        onPressed: () => setState(
                          () => _obscureConfirm = !_obscureConfirm,
                        ),
                        tooltip: _obscureConfirm
                            ? 'Mostrar confirmação'
                            : 'Ocultar confirmação',
                      ),
                    ),
                    obscureText: _obscureConfirm,
                  ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _loading ? null : _submit,
                  child: Text(_isLogin ? 'Entrar' : 'Cadastrar'),
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
                  child: Text(
                    _isLogin
                        ? 'Não tem conta? Cadastre-se'
                        : 'Já tem conta? Entrar',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}