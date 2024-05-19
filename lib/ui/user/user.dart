import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sanpo/providers.dart';
import 'package:sanpo/services/auth_service.dart';
import 'package:sanpo/ui/user/settings.dart';

class UserDetailPage extends StatefulWidget {
  const UserDetailPage({super.key});

  @override
  State<UserDetailPage> createState() => UserDetailPageeState();
}

class UserDetailPageeState extends State<UserDetailPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        border: Border.all(),
                      ),
                      child: const Icon(
                        Icons.person_2,
                        size: 80,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Icon(Icons.add, size: 24),
                  ],
                ),
              ),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '名前',
                      style: TextStyle(fontSize: 24),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'ユーザーの説明がここに入ります。',
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Text(
            '散歩履歴',
            style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: 3, // 項目数
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          const CircleAvatar(
                            radius: 30,
                            child: Icon(Icons.pets, size: 30),
                          ),
                          const SizedBox(width: 16),
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '5/5',
                                style: TextStyle(fontSize: 18),
                              ),
                              Text(
                                '6:00',
                                style: TextStyle(fontSize: 18),
                              ),
                            ],
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  height: 20,
                                  color: Colors.grey[300],
                                ),
                                const SizedBox(height: 4),
                                Container(
                                  height: 20,
                                  color: Colors.grey[300],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class UserAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const UserAppBar({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authService = ref.watch(authServiceProvider);
    return AppBar(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Icon(
            Icons.abc,
            size: 48,
          ),
          const Text(
            'ユーザー詳細画面',
            style: TextStyle(fontSize: 24),
          ),
          InkWell(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: ((context) => const SettingsPage()),
              ),
            ),
            child: const Icon(
              Icons.settings,
              size: 48,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
