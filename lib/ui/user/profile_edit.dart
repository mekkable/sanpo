import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import '../../models/user_model.dart';
import '../../services/auth_service.dart';

class ProfileEditPage extends ConsumerWidget {
  const ProfileEditPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = UserModel(
      id: 'userId',
      name: 'Sample User',
      introduction: 'This is a sample introduction.',
      profileImage: 'https://via.placeholder.com/150',
      dogs: ['Dog1', 'Dog2'],
      schedules: ['Schedule1', 'Schedule2'],
    );

    final nameController = TextEditingController(text: user.name);
    final introController = TextEditingController(text: user.introduction);

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
                backgroundImage: NetworkImage(user.profileImage),
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
              controller: introController,
              decoration: const InputDecoration(
                labelText: '自己紹介',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            const Text('犬のリスト', style: TextStyle(fontSize: 16)),
            ...user.dogs.map((dog) => ListTile(
                  leading: const Icon(Icons.pets),
                  title: Text(dog),
                )),
            const SizedBox(height: 16),
            const Text('スケジュールのリスト', style: TextStyle(fontSize: 16)),
            ...user.schedules.map((schedule) => ListTile(
                  leading: const Icon(Icons.schedule),
                  title: Text(schedule),
                )),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // プロフィール更新の処理
                },
                child: const Text('更新'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
