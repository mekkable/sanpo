import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sanpo/models/dog_model.dart';
import 'package:sanpo/models/user_model.dart';
import 'package:sanpo/providers.dart';
import 'package:sanpo/services/auth_service.dart';
import 'package:sanpo/services/firrestore_service.dart';
import 'package:sanpo/ui/dog/dog_create.dart';
import 'package:sanpo/ui/dog/dog_edit.dart';
import 'package:sanpo/ui/dog/dog_index.dart';
import '../services/firestore_service.dart';

class DogDetailPage extends HookConsumerWidget {
  const DogDetailPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    print('DogDetailPage build method called');
    final currentUserAsyncValue = ref.watch(currentUserProvider);
    final firestoreService = ref.watch(firestoreServiceProvider);
    final selectedDog = ref.watch(selectedDogProvider);
    final tabController = useTabController(initialLength: 3);

    useEffect(() {
      currentUserAsyncValue.whenData((userModel) {
        if (userModel == null || userModel.dogs.isEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => const DogCreateScreen(),
              ),
            );
          });
        } else if (selectedDog == null) {
          final dogId = userModel.dogs[0];
          firestoreService.getDogById(dogId).then((dog) {
            if (dog != null) {
              ref.read(selectedDogProvider.notifier).state = dog;
            }
          });
        }
      });
      return null;
    }, [currentUserAsyncValue]);

    return currentUserAsyncValue.when(
      data: (userModel) {
        if (userModel == null) return Text('ログインしてください');
        if (userModel.dogs.isEmpty) return Text('犬を登録してください');
        if (selectedDog == null)
          //この遷移先でボタンがなぜか押せない
          //
          //
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const DogCreateScreen(),
            ),
          );
        ;
        //
        //
        //
        //

        final dog = selectedDog;
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              OutlinedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DogIndexScreen(),
                    ),
                  );
                },
                child: const Text(
                  '犬一覧',
                  style: TextStyle(fontSize: 24),
                ),
              ),
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
                            Icons.pets,
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
                          dog!.name,
                          style: const TextStyle(fontSize: 24),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          dog.description,
                          style: const TextStyle(fontSize: 16),
                        ),
                        const Icon(Icons.male, size: 24),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 50,
                child: Material(
                  child: TabBar(
                    controller: tabController,
                    tabs: const <Widget>[
                      Tab(
                        child: Icon(
                          Icons.image,
                          size: 32,
                        ),
                      ),
                      Tab(
                        child: Icon(
                          Icons.schedule,
                          size: 32,
                        ),
                      ),
                      Tab(
                        child: Icon(
                          Icons.person,
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
                  controller: tabController,
                  children: const [
                    _PictureTabView(),
                    _MemoTabView(),
                    _UserTabView(),
                  ],
                ),
              ),
              Align(
                alignment: Alignment.bottomRight,
                child: FloatingActionButton(
                  onPressed: () {},
                  child: const Icon(Icons.add),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error: $error')),
    );
  }
}

class DogAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const DogAppBar({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDog = ref.watch(selectedDogProvider);
    return AppBar(
      automaticallyImplyLeading: false,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                ref.read(selectedDogProvider.notifier).state = selectedDog;
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        DeleteConfirmationPage(dogId: selectedDog!.id),
                  ),
                );
              }),
          const Text(
            'My Dog',
            style: TextStyle(fontSize: 24),
          ),
          InkWell(
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const DogEditPage(),
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
  Size get preferredSize => Size.fromHeight(kToolbarHeight);
}

class _PictureTabView extends StatelessWidget {
  const _PictureTabView({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      children: List.generate(6, (index) {
        return Container(
          margin: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            border: Border.all(),
          ),
          child: Center(
            child: Text('画像 ${index + 1}'),
          ),
        );
      }),
    );
  }
}

class _MemoTabView extends StatelessWidget {
  const _MemoTabView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

class _UserTabView extends StatelessWidget {
  const _UserTabView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

class DeleteConfirmationPage extends ConsumerWidget {
  final String dogId;

  const DeleteConfirmationPage({Key? key, required this.dogId})
      : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('削除確認'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'この犬の情報を削除してもよろしいですか？',
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('キャンセル'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final user = ref.read(authStateProvider).asData?.value;
                    if (user != null) {
                      await ref
                          .read(firestoreServiceProvider)
                          .deleteDog(dogId, user.uid);
                      print('Dog deleted and navigating back');
                      ref.read(selectedDogProvider.notifier).state = null;
                      Navigator.of(context).pop(); // 削除後に元の画面に戻る
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('ユーザー情報が見つかりませんでした。再度ログインしてください。')),
                      );
                    }
                  },
                  child: const Text('削除'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
