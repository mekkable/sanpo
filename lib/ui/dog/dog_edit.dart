import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sanpo/providers.dart';
import 'package:sanpo/services/firrestore_service.dart';
import 'package:sanpo/ui/dog/dog_show.dart';
import '../../models/dog_model.dart';

class DogEditPage extends HookConsumerWidget {
  const DogEditPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dog = ref.watch(selectedDogProvider);
    if (dog == null) {
      return const Center(child: Text('犬の情報がありません'));
    }
    final nameController = useTextEditingController(text: dog.name);
    final descriptionController =
        useTextEditingController(text: dog.description);
    final birthdayController =
        useTextEditingController(text: dog.birthday.toString());

    Future<void> _updateDog() async {
      final firestoreService = ref.read(firestoreServiceProvider);
      final updatedDog = DogModel(
        id: dog.id,
        name: nameController.text,
        description: descriptionController.text,
        profileImage: dog.profileImage,
        albumImages: dog.albumImages,
        birthday: DateTime.parse(birthdayController.text),
        users: dog.users,
        schedules: dog.schedules,
      );

      await firestoreService.updateDog(updatedDog);

      // 更新が完了したら前の画面に戻る
      Navigator.of(context).pop();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('プロフィール変更'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundImage: NetworkImage(dog.profileImage),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: '名前',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: '説明',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: birthdayController,
              decoration: const InputDecoration(
                labelText: '誕生日',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: _updateDog,
                child: const Text('更新'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
