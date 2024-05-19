import 'package:cloud_firestore/cloud_firestore.dart';

class DogModel {
  String id;
  String name;
  String description;
  String profileImage; //URLを格納
  List<String> albumImages;
  DateTime birthday;
  List<String> users;
  List<String> schedules;

  DogModel({
    required this.id,
    required this.name,
    required this.description,
    required this.profileImage,
    required this.albumImages,
    required this.birthday,
    required this.users,
    required this.schedules,
  });

  factory DogModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return DogModel(
      id: doc.id,
      name: data['name'],
      description: data['description'],
      profileImage: data['profileImage'],
      albumImages: List<String>.from(data['albumImages']),
      birthday: (data['birthday'] as Timestamp).toDate(),
      users: List<String>.from(data['users']),
      schedules: List<String>.from(data['schedules']),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'profileImage': profileImage,
      'albumImages': albumImages,
      'birthday': Timestamp.fromDate(birthday),
      'users': users,
      'schedules': schedules,
    };
  }
}
