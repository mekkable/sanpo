import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sanpo/providers.dart';
import 'package:sanpo/ui/user/profile_edit.dart';
import '../../services/auth_service.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authService = ref.watch(authServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('設定画面'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                      builder: (context) => const ProfileEditPage()),
                );
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(200, 50), // ボタンの大きさを指定
              ),
              child: const Text('プロフィール編集'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await authService.signOut();
                Navigator.of(context).pushNamedAndRemoveUntil(
                    '/login', (Route<dynamic> route) => false);
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(200, 50),
              ),
              child: const Text('ログアウト'),
            ),
          ],
        ),
      ),
    );
  }
}
