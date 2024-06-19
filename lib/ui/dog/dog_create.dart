import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sanpo/models/dog_model.dart';
import 'package:sanpo/providers.dart';
import 'package:sanpo/services/auth_service.dart';
import 'package:sanpo/services/firrestore_service.dart';
import 'package:sanpo/ui/dog/dog_show.dart';
import '../services/firestore_service.dart';

class DogCreateScreen extends StatelessWidget {
  const DogCreateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: InkWell(
          onTap: () => Navigator.pop(context),
          child: Icon(
            Icons.abc,
            size: 32,
          ),
        ),
        title: const Text('犬の登録'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            OutlinedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DogCreatePage(),
                ),
              ),
              child: Text('犬を登録する'),
            ),
            OutlinedButton(
              onPressed: () => Navigator.pushReplacementNamed(context, '/'),
              child: Text('ホームへ戻る'),
            ),
          ],
        ),
      ),
    );
  }
}

class DogCreatePage extends ConsumerStatefulWidget {
  const DogCreatePage({super.key});

  @override
  _DogRegistrationPageState createState() => _DogRegistrationPageState();
}

class _DogRegistrationPageState extends ConsumerState<DogCreatePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime? _birthday;

  @override
  Widget build(BuildContext context) {
    final firestoreService = ref.watch(firestoreServiceProvider);
    final authService = ref.watch(authServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('犬の登録'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: '名前'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '名前を入力してください';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: '説明'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '説明を入力してください';
                  }
                  return null;
                },
              ),
              ElevatedButton(
                onPressed: () async {
                  final selectedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (selectedDate != null) {
                    setState(() {
                      _birthday = selectedDate;
                    });
                  }
                },
                child: Text(
                  _birthday == null
                      ? '誕生日を選択'
                      : '誕生日: ${_birthday!.year}/${_birthday!.month}/${_birthday!.day}',
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    final user = authService.currentUser;
                    if (user != null) {
                      final dog = DogModel(
                        id: '',
                        name: _nameController.text,
                        description: _descriptionController.text,
                        profileImage: '',
                        albumImages: [],
                        birthday: _birthday!,
                        users: [user.uid],
                        schedules: [],
                      );
                      final newDogId =
                          await firestoreService.addDogAndGetDogId(dog);
                      // 新しい犬を取得
                      final newDog =
                          await firestoreService.getDogById(newDogId);

                      if (newDog != null) {
                        // 登録した犬を選択
                        ref.read(selectedDogProvider.notifier).state = newDog;
                        ref.refresh(currentUserProvider);
                        Navigator.pushReplacementNamed(context, '/');
                      }
                    }
                  }
                },
                child: const Text('登録'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
