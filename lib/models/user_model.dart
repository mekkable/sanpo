import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  String id;
  String name;
  String introduction;
  String profileImage;
  List<String> dogs;
  List<String> schedules;

  UserModel({
    required this.id,
    required this.name,
    required this.introduction,
    required this.profileImage,
    required this.dogs,
    required this.schedules,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      name: data['name'],
      introduction: data['introduction'],
      profileImage: data['profileImage'],
      dogs: List<String>.from(data['dogs']),
      schedules: List<String>.from(data['schedules']),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'introduction': introduction,
      'profileImage': profileImage,
      'dogs': dogs,
      'schedules': schedules,
    };
  }
}
