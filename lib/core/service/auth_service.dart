import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<User?> authStateChanges() => _auth.authStateChanges();

  Future<UserCredential> signUpWithEmailPassword({
    required String email,
    required String password,
  }) {
    return _auth.createUserWithEmailAndPassword(
        email: email, password: password);
  }

  Future<UserCredential> signInWithEmailPassword({
    required String email,
    required String password,
  }) {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<UserCredential> signInWithGoogle() async {
    if (kIsWeb) {
      final provider = GoogleAuthProvider()
        ..addScope('email')
        ..setCustomParameters({'prompt': 'select_account'});
      return _auth.signInWithPopup(provider);
    } else {
      try {
        // Use the new API: authenticate() starts an interactive sign-in and
        // returns a GoogleSignInAccount on success.
        final GoogleSignInAccount gUser =
            await GoogleSignIn.instance.authenticate(scopeHint: ['email']);

        // The authentication object currently exposes only the idToken.
        final String? idToken = gUser.authentication.idToken;

        // If an access token is required, request client authorization for
        // the desired scopes. This may prompt the user.
        String? accessToken;
        final clientAuth = await gUser.authorizationClient
            .authorizationForScopes(['email', 'profile', 'openid']);
        if (clientAuth != null) {
          accessToken = clientAuth.accessToken;
        }

        final credential = GoogleAuthProvider.credential(
          idToken: idToken,
          accessToken: accessToken,
        );
        return _auth.signInWithCredential(credential);
      } on Exception catch (e) {
        // Map cancellation to a friendlier message; rethrow other errors.
        if (e is GoogleSignInException &&
            e.code == GoogleSignInExceptionCode.canceled) {
          throw Exception('Login com Google cancelado');
        }
        rethrow;
      }
    }
  }

  Future<void> signOut() => _auth.signOut();
}
