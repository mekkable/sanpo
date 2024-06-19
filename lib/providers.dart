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

final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});
//
//
//固定のユーザー、犬
final selectedDogProvider = StateProvider<DogModel?>((ref) => null);
final currentUserProvider = FutureProvider<UserModel?>((ref) async {
  final authService = ref.watch(authServiceProvider);
  final firestoreService = ref.watch(firestoreServiceProvider);
  final user = authService.currentUser;
  if (user != null) {
    return firestoreService.getUser(user.uid);
  }
  return null;
});
//
//
//コレ必要？FutureBuilderでもいいのでは->逆。Riverpodで統一(FutureProvider)
//犬に基づいたschedule一覧
final schedulesProvider =
    FutureProvider.family<List<ScheduleModel>, String>((ref, dogId) async {
  final firestoreService = ref.watch(firestoreServiceProvider);
  final dog = await firestoreService.getDogById(dogId);
  print('dog: $dog');
  return firestoreService.getSchedules(dog!.schedules);
});
//スケジュールを犬とユーザーに基づいて表示

//
///mada
//いぬ一覧を表示
final dogsProvider = FutureProvider<List<DogModel>>((ref) async {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.getAllDogs();
});
//userIdに基づいて犬を取得
final dogsByUserProvider =
    FutureProvider.family<List<DogModel>, String>((ref, userId) async {
  final firestoreService = ref.watch(firestoreServiceProvider);
  final user = await firestoreService.getUser(userId);
  return firestoreService.getDogsByIds(user!.dogs);
});
//ユーザー一覧を表示
final usersProvider = FutureProvider<List<UserModel>>((ref) async {
  final firestoreService = ref.watch(firestoreServiceProvider);
  return firestoreService.getAllUsers();
});
