import 'dart:core';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_model.dart';
import '../models/dog_model.dart';
import '../models/schedule_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

//user
  Future<UserModel?> getUser(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    if (doc.exists) {
      print('Fetched user model: $UserModel.fromFirestore(doc)');
      return UserModel.fromFirestore(doc);
    }
    print('User not found for userId: $userId');
    return null;
  }

  Future<List<UserModel?>> getUserByDogId(String dogId) async {
    QuerySnapshot querySnapshot = await _firestore
        .collection('users')
        .where('dogs', arrayContains: dogId)
        .get();
    return querySnapshot.docs
        .map((doc) => UserModel.fromFirestore(doc))
        .toList();
  }

  Future<List<UserModel>> getAllUsers() async {
    QuerySnapshot querySnapshot = await _firestore.collection('users').get();
    return querySnapshot.docs
        .map((doc) => UserModel.fromFirestore(doc))
        .toList();
  }

  Future<void> addDogIdToUser(String userId, String dogId) async {
    final userDoc = _firestore.collection('users').doc(userId);
    print(userDoc);
    await userDoc.update({
      'dogs': FieldValue.arrayUnion([dogId])
    });
  }

//
//
//
//
//
//
//
//dog

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

  // 複数の犬のIDを受け取り、その情報を取得するメソッド
  Future<List<DogModel>> getDogsByIds(List<String> dogIds) async {
    final futures = dogIds.map((dogId) => getDogById(dogId)).toList();
    final dogs = await Future.wait(futures);
    return dogs.where((dog) => dog != null).cast<DogModel>().toList();
  }

  Future<List<DogModel>> getAllDogs() async {
    QuerySnapshot querySnapshot = await _firestore.collection('dogs').get();
    return querySnapshot.docs
        .map((doc) => DogModel.fromFirestore(doc))
        .toList();
  }

  Future<String> addDogAndGetDogId(DogModel dog) async {
    final docRef = _firestore.collection('dogs').doc();
    dog.id = docRef.id; // IDをここで設定
    await docRef.set(dog.toFirestore());
    //新規作成の場合、currentUser(=dog.users.first)のドキュメントに犬作成したIDを追加
    final userDoc = _firestore.collection('users').doc(dog.users.first);
    final userSnap = await userDoc.get();
    if (userSnap.exists) {
      await userDoc.update({
        'dogs': FieldValue.arrayUnion([dog.id]),
      });
    }
    return docRef.id; // 新しいIDを返す
  }

//
//
//
//
//
//
//
//schedules
  Future<List<ScheduleModel>> getSchedules(List<String> scheduleIds) async {
    final schedules = await Future.wait(scheduleIds.map((id) async {
      final doc = await _firestore.collection('schedules').doc(id).get();
      return ScheduleModel.fromFirestore(doc);
    }));
    return schedules;
  }

//dogIdとUserIdでスケジュールを取得
  Future<List<ScheduleModel>> getSchedulesByUserIdAndDogId(
      String userId, String dogId) async {
    QuerySnapshot querySnapshot = await _firestore
        .collection(
          'schedules',
        )
        .where('user', isEqualTo: userId)
        .where('dog', isEqualTo: dogId)
        .get();
    return querySnapshot.docs
        .map((doc) => ScheduleModel.fromFirestore(doc))
        .toList();
  }

  Future<void> addSchedule(ScheduleModel schedule) async {
    final docRef = _firestore.collection('schedules').doc();
    schedule.id = docRef.id; // IDをここで設定
    await docRef.set(schedule.toFirestore());

    // スケジュールに設定された犬のドキュメントにスケジュールIDを追加
    final dogDocRef = _firestore.collection('dogs').doc(schedule.dog);
    await dogDocRef.update({
      'schedules': FieldValue.arrayUnion([docRef.id])
    });

    // スケジュールに設定されたユーザーのドキュメントにスケジュールIDを追加
    final userDocRef = _firestore.collection('users').doc(schedule.user);
    await userDocRef.update(
      {
        'schedules': FieldValue.arrayUnion([docRef.id])
      },
    );
  }

  Future<void> updateSchedule(ScheduleModel schedule) async {
    await _firestore
        .collection('schedules')
        .doc(schedule.id)
        .update(schedule.toFirestore());
  }

  Future<void> deleteSchedule(
      String scheduleId, String dogId, String userId) async {
    await _firestore.collection('schedules').doc(scheduleId).delete();
    final dogDocRef = _firestore.collection('dogs').doc(dogId);
    await dogDocRef.update({
      'schedules': FieldValue.arrayRemove([scheduleId])
    });
    final userDocRef = _firestore.collection('users').doc(userId);
    await userDocRef.update({
      'schedules': FieldValue.arrayRemove([scheduleId])
    });
  }
}
