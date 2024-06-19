import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  AuthService(this._firebaseAuth);
  User? get currentUser => _firebaseAuth.currentUser;

  // ユーザー登録時にユーザードキュメントを作成
  Future<void> signUpWithEmailAndPassword(
      String email, String password, String name) async {
    UserCredential userCredential =
        await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    User? user = userCredential.user;
    if (user != null) {
      // UserModelのtoFirestoreメソッドを使って、ユーザードキュメントを作成してもいい
      //
      //
      await _firestore.collection('users').doc(user.uid).set({
        'name': name,
        'email': email,
        'introduction': '',
        'profileImage': '',
        'dogs': [],
        'schedules': [],
      });
      //
      //
      //
    }
  }

  Future<void> signInWithEmailAndPassword(String email, String password) async {
    await _firebaseAuth.signInWithEmailAndPassword(
        email: email, password: password);
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }
}
