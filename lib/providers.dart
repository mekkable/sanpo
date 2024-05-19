import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sanpo/models/dog_model.dart';
import 'package:sanpo/models/schedule_model.dart';
import 'package:sanpo/models/user_model.dart';
import 'package:sanpo/services/auth_service.dart';
import 'package:sanpo/services/firrestore_service.dart'; //FirebaseAuthインスタンス

final firebaseAuthProvider = Provider<FirebaseAuth>((ref) {
  return FirebaseAuth.instance;
});
//ユーザーの認証状態をストリームで提供するプロバイダ。authStateChanges()メソッドを使用して、認証状態の変化を監視
final authStateProvider = StreamProvider<User?>((ref) {
  final firebaseAuth = ref.watch(firebaseAuthProvider);
  return firebaseAuth.authStateChanges();
});
//認証サービス（AuthService）のインスタンス
final authServiceProvider = Provider<AuthService>((ref) {
  final firebaseAuth = ref.watch(firebaseAuthProvider);
  return AuthService(firebaseAuth);
});

final currentUserProvider = FutureProvider<UserModel?>((ref) async {
  final authService = ref.watch(authServiceProvider);
  final firestoreService = ref.watch(firestoreServiceProvider);
  final user = authService.currentUser;
  print('user:${user}');
  if (user != null) {
    return firestoreService.getUser(user.uid);
  }
  return null;
});

final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});
final userSchedulesProvider =
    StreamProvider.family<List<ScheduleModel>, String>((ref, userId) {
  final firestore = ref.watch(firestoreProvider);
  return firestore
      .collection('users')
      .doc(userId)
      .collection('schedules')
      .snapshots()
      .map((snapshot) {
    return snapshot.docs
        .map((doc) => ScheduleModel.fromFirestore(doc))
        .toList();
  });
});
final selectedDogProvider = StateProvider<DogModel?>((ref) => null);
