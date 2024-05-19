import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../models/dog_model.dart';
import '../models/schedule_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<UserModel?> getUser(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    if (doc.exists) {
      print('Fetched user model: $UserModel.fromFirestore(doc)');
      return UserModel.fromFirestore(doc);
    }
    print('User not found for userId: $userId');
    return null;
  }

  Future<DogModel?> getDog(String dogId) async {
    final doc = await _firestore.collection('dogs').doc(dogId).get();
    if (doc.exists) {
      return DogModel.fromFirestore(doc);
    }
    return null;
  }

  Future<void> deleteDog(String dogId, String userId) async {
    final dogDoc = await _firestore.collection('dogs').doc(dogId).get();
    if (!dogDoc.exists) {
      throw Exception("Dog not found");
    }

    final dogData = dogDoc.data();
    if (dogData == null) {
      throw Exception("Dog data is null");
    }

    final List<String> scheduleIds =
        List<String>.from(dogData['schedules'] ?? []);

    // スケジュールを削除
    for (final scheduleId in scheduleIds) {
      await _firestore.collection('schedules').doc(scheduleId).delete();
    }

    // 犬のドキュメントを削除
    await _firestore.collection('dogs').doc(dogId).delete();

    // ユーザードキュメントから該当する犬のIDとスケジュールIDを削除
    final userDoc = _firestore.collection('users').doc(userId);
    await userDoc.update({
      'dogs': FieldValue.arrayRemove([dogId]),
      'schedules': FieldValue.arrayRemove(scheduleIds),
    });
  }

  Future<DogModel?> getDogById(String dogId) async {
    final doc = await _firestore.collection('dogs').doc(dogId).get();
    if (doc.exists) {
      return DogModel.fromFirestore(doc);
    }
    return null;
  }

  Future<void> updateDog(DogModel dog) async {
    await _firestore.collection('dogs').doc(dog.id).update(dog.toFirestore());
  }

  Future<List<DogModel>> getDogs(List<String> dogIds) async {
    final dogs = await Future.wait(dogIds.map((id) async {
      final doc = await _firestore.collection('dogs').doc(id).get();
      return DogModel.fromFirestore(doc);
    }));
    return dogs;
  }

  Future<String> addDogAndGetDogId(DogModel dog) async {
    final docRef = _firestore.collection('dogs').doc();
    dog.id = docRef.id; // IDをここで設定
    await docRef.set(dog.toFirestore());

    final userDoc = _firestore.collection('users').doc(dog.users.first);
    final userSnap = await userDoc.get();
    if (userSnap.exists) {
      await userDoc.update({
        'dogs': FieldValue.arrayUnion([dog.id]),
      });
    }
    return docRef.id; // 新しいIDを返す
  }

  Future<List<ScheduleModel>> getSchedules(List<String> scheduleIds) async {
    final schedules = await Future.wait(scheduleIds.map((id) async {
      final doc = await _firestore.collection('schedules').doc(id).get();
      return ScheduleModel.fromFirestore(doc);
    }));
    return schedules;
  }
}
