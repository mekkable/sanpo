import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sanpo/models/dog_model.dart';
import 'package:sanpo/providers.dart';
import 'package:sanpo/services/firrestore_service.dart';
import 'package:sanpo/ui/dog/dog_create.dart';

class DogIndexScreen extends HookConsumerWidget {
  const DogIndexScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dogsAsyncValue = ref.watch(dogsProvider);

    return dogsAsyncValue.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => const Center(child: Text('エラーが発生しました')),
      data: (dogs) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('犬一覧'),
          ),
          body: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const DogCreatePage(),
                        ),
                      );
                    },
                    child: const Text('新規登録'),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    itemCount: dogs!.length,
                    itemBuilder: (context, index) {
                      return DogCard(
                        dog: dogs[index],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class DogCard extends HookConsumerWidget {
  const DogCard({super.key, required this.dog});
  final DogModel dog;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUserAsyncValue = ref.watch(currentUserProvider);
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: InkWell(
        onTap: () {},
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(width: 1, color: Colors.grey),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  CircleAvatar(
                    radius: 32,
                    child: Icon(Icons.pets, size: 30),
                  ),
                  Text(
                    '${dog.name}',
                    style: TextStyle(fontSize: 32),
                  )
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    currentUserAsyncValue.when(
                      data: (currentUser) {
                        if (currentUser == null) {
                          return const Text('ユーザー情報が見つかりません');
                        }
                        final isDogAlreadyAdded =
                            currentUser.dogs?.contains(dog.id) ?? false;
                        return isDogAlreadyAdded
                            ? OutlinedButton(
                                onPressed: () {
                                  ref.read(selectedDogProvider.notifier).state =
                                      dog;
                                  Navigator.pop(context);
                                },
                                child: const Text(
                                  'この犬の情報を取得する',
                                  style: TextStyle(fontSize: 16),
                                ),
                              ) // Replace with SizedBox.shrink() if needed
                            : Row(
                                children: [
                                  OutlinedButton(
                                    onPressed: () async {
                                      try {
                                        final userDogs = currentUser.dogs ?? [];
                                        if (userDogs.contains(dog.id)) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                  '${dog.name}はすでに登録されています'),
                                            ),
                                          );
                                          return;
                                        }
                                        await ref
                                            .read(firestoreServiceProvider)
                                            .addDogIdToUser(
                                                currentUser.id, dog.id);
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text(
                                                '${dog.name}を飼い犬として登録しました'),
                                          ),
                                        );
                                      } catch (e) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            content: Text('登録に失敗しました: $e'),
                                          ),
                                        );
                                      }
                                    },
                                    child: const Text(
                                      'この犬を飼い犬として登録する',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ),
                                  OutlinedButton(
                                    onPressed: () {
                                      ref
                                          .read(selectedDogProvider.notifier)
                                          .state = dog;
                                      Navigator.pop(context);
                                    },
                                    child: const Text(
                                      'この犬の情報を取得する',
                                      style: TextStyle(fontSize: 16),
                                    ),
                                  ),
                                ],
                              );
                      },
                      loading: () => const CircularProgressIndicator(),
                      error: (error, stack) => const Text('エラーが発生しました'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
