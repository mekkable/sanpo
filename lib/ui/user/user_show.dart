import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sanpo/main.dart';
import 'package:sanpo/providers.dart';
import 'package:sanpo/ui/dog/dog_index.dart';
import 'package:sanpo/ui/user/settings.dart';

class UserDetailPage extends HookConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    final firestoreService = ref.watch(firestoreServiceProvider);
    final TabController _tabController = useTabController(initialLength: 2);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: currentUser.when(
        loading: () => CircularProgressIndicator(), // データ取得中はローディングインジケータを表示
        error: (err, stack) => Text('エラーが発生しました: $err'),
        data: (user) {
          if (user == null) {
            return Center(child: Text('ユーザー情報が見つかりません。'));
          }
          final userDogsAsyncValue = ref.watch(dogsByUserProvider(user.id));

          return Column(
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
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${user.name}',
                          style: TextStyle(fontSize: 24),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'user.introduction',
                          style: TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              ScheduleByUser(user.id),
              SizedBox(
                height: 50,
                child: Material(
                  child: TabBar(
                    controller: _tabController,
                    tabs: const <Widget>[
                      Tab(
                        child: Icon(
                          Icons.image,
                          size: 32,
                        ),
                      ),
                      Tab(
                        child: Icon(
                          Icons.pets,
                          size: 32,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Expanded(
                child: TabBarView(
                  physics: const NeverScrollableScrollPhysics(),
                  controller: _tabController,
                  children: [
                    Column(
                      children: [
                        const Text(
                          '散歩履歴',
                          style: TextStyle(
                              fontSize: 32, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: ListView.builder(
                            itemCount: 3, // 項目数
                            itemBuilder: (context, index) {
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8.0),
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
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
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
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
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
                    Column(
                      children: [
                        Text(
                          '飼い犬',
                          style: TextStyle(fontSize: 24),
                        ),
                        Expanded(
                          child: userDogsAsyncValue.when(
                              loading: () => const CircularProgressIndicator(),
                              error: (error, stackTrace) =>
                                  Text('エラーが発生しました: $error'),
                              data: (dogs) {
                                print(dogs);
                                return ListView.builder(
                                  itemCount: dogs.length,
                                  itemBuilder: (context, index) =>
                                      DogCard(dog: dogs[index]),
                                );
                              }),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          );
        },
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
