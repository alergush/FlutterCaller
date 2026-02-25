import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  const AuthService(this._firebaseAuth);

  final FirebaseAuth _firebaseAuth;

  // User? get currentUser => _firebaseAuth.currentUser;

  Future<UserCredential> signIn(String email, String password) async {
    return await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserCredential> signUp(
    String email,
    String password,
    String username,
  ) async {
    return await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}
