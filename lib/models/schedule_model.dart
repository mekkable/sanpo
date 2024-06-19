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
    print('data:${data}');
    final from = ScheduleModel(
      id: doc.id,
      name: data['name'] ?? '', // デフォルト値として空文字列を使用
      memo: data['memo'] ?? '', // デフォルト値として空文字列を使用
      startTime: (data['startTime'] as Timestamp?)?.toDate() ??
          DateTime.now(), // デフォルト値として現在の日付と時刻を使用
      endTime: (data['endTime'] as Timestamp?)?.toDate() ??
          DateTime.now(), // デフォルト値として現在の日付と時刻を使用
      pictures: List<String>.from(data['pictures'] ?? []), // デフォルト値として空のリストを使用
      dog: data['dog'] ?? '', // デフォート値として空文字列を使用
      user: data['user'] ?? '', // デフォート値として空文字列を使用
    );

    return from;
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
