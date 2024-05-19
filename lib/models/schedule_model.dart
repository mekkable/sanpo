import 'package:cloud_firestore/cloud_firestore.dart';

class ScheduleModel {
  String id;
  String name;
  String memo;
  DateTime startTime;
  DateTime endTime;
  List<String> pictures;
  String dog; // 外部キーとして犬のID
  String user; // 外部キーとしてユーザーのID

  ScheduleModel({
    required this.id,
    required this.name,
    required this.memo,
    required this.startTime,
    required this.endTime,
    required this.pictures,
    required this.dog,
    required this.user,
  });

  factory ScheduleModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ScheduleModel(
      id: doc.id,
      name: data['name'],
      memo: data['memo'],
      startTime: (data['startTime'] as Timestamp).toDate(),
      endTime: (data['endTime'] as Timestamp).toDate(),
      pictures: List<String>.from(data['pictures']),
      dog: data['dog'],
      user: data['user'],
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'memo': memo,
      'startTime': Timestamp.fromDate(startTime),
      'endTime': Timestamp.fromDate(endTime),
      'pictures': pictures,
      'dog': dog,
      'user': user,
    };
  }
}
