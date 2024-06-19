import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker_plus/flutter_datetime_picker_plus.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sanpo/main.dart';
import 'package:sanpo/models/dog_model.dart';
import 'package:sanpo/models/schedule_model.dart';
import 'package:sanpo/models/user_model.dart';
import 'package:sanpo/providers.dart';
import 'package:sanpo/services/auth_service.dart';
import 'package:sanpo/services/firrestore_service.dart';
import 'package:sanpo/ui/dog/dog_index.dart';
import 'package:sanpo/ui/schedule/schedule_show.dart';
import '../services/firestore_service.dart';

class ScheduleIndexPage extends HookConsumerWidget {
  const ScheduleIndexPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDog = ref.watch(selectedDogProvider);
    if (selectedDog == null) {
      return const Center(child: Text('犬が選択されていません'));
    }
    final schedulesAsyncValue = ref.watch(schedulesProvider(selectedDog.id));
    return schedulesAsyncValue.when(
        loading: () => const CircularProgressIndicator(),
        error: (error, stack) => Text('エラーが発生しました: $error'),
        data: (schedules) {
          if (schedules.isEmpty) {
            return Center(
                child: ElevatedButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return Dialog(
                      child: ScheduleCreateModalSheet(
                        date: DateTime.now(),
                      ),
                    );
                  },
                ).then((_) {
                  ref.refresh(schedulesProvider(selectedDog.id));
                });
              },
              child: const Text('スケジュールを作成してください'),
            ));
          }

          // 日付とスケジュールのリストのmap型
          final groupedSchedules = groupSchedulesByDate(schedules);
          final todayIndex = findTodayIndex(groupedSchedules);

          final controller = ScrollController(
            initialScrollOffset: todayIndex * 100.0,
          );

          return Column(
            children: [
              DateAndWeather(),
              Text(
                '"${selectedDog.name}"の記録',
                style: TextStyle(
                  fontSize: 32,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              const SizedBox(
                height: 24,
              ),
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
              Expanded(
                child: ListView.builder(
                  controller: controller,
                  //日付の数だけ生成
                  itemCount: groupedSchedules.length,
                  itemBuilder: (context, index) {
                    final date = groupedSchedules.keys.elementAt(index);
                    final daySchedules =
                        groupedSchedules[date] ?? []; //mapで日付を渡して対応しているリスト取得
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        daySchedules.isEmpty
                            ? ElevatedButton(
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return Dialog(
                                        child: ScheduleCreateModalSheet(
                                          date: DateTime.now(),
                                        ), // スケジュール作成モーダルのウィジェット
                                      );
                                    },
                                  );
                                },
                                child: Text('スケジュールを作成してください'),
                              )
                            : Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  children: [
                                    Text(
                                      "${date.month.toString().padLeft(2, '0')}月${date.day.toString().padLeft(2, '0')}日",
                                      style: const TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    InkWell(
                                      onTap: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) {
                                            return Dialog(
                                              child: ScheduleCreateModalSheet(
                                                date: date,
                                              ), // スケジュール作成モーダルのウィジェット
                                            );
                                          },
                                        );
                                      },
                                      child: const Icon(
                                        Icons.add,
                                        size: 48,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                        ...daySchedules
                            .map((schedule) => ScheduleCard(schedule: schedule))
                            .toList(),
                      ],
                    );
                  },
                ),
              ),
            ],
          );
        });
  }

  Map<DateTime, List<ScheduleModel>> groupSchedulesByDate(
      List<ScheduleModel> schedules) {
    final map = <DateTime, List<ScheduleModel>>{};
    for (var schedule in schedules) {
      final date = DateTime(schedule.startTime.year, schedule.startTime.month,
          schedule.startTime.day);
      if (map.containsKey(date)) {
        map[date]!.add(schedule);
      } else {
        map[date] = [schedule];
      }
    }
    final sortedMap = Map.fromEntries(
        map.entries.toList()..sort((a, b) => a.key.compareTo(b.key)));
    return sortedMap;
  }

  int findTodayIndex(Map<DateTime, List<ScheduleModel>> groupedSchedules) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return groupedSchedules.keys
        .toList()
        .indexWhere((date) => date.isAtSameMomentAs(today));
  }
}

class ScheduleCreateModalSheet extends HookConsumerWidget {
  const ScheduleCreateModalSheet({required this.date, super.key});
  final DateTime date;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDog = ref.watch(selectedDogProvider);

    final memoController = useTextEditingController();
    final startTime = useState<DateTime?>(null);
    final endTime = useState<DateTime?>(null);
    final firestoreService = ref.watch(firestoreServiceProvider);
    final scheduleUser = useState<UserModel?>(null);
    final scheduleDog = useState<DogModel?>(selectedDog);

    Future<void> selectDog(BuildContext context) async {
      final dogs = await firestoreService.getAllDogs();
      showModalBottomSheet(
        context: context,
        builder: (context) {
          return ListView.builder(
            itemCount: dogs.length,
            itemBuilder: (context, index) {
              final dog = dogs[index];
              return ListTile(
                leading: Image.network(dog.profileImage),
                title: Text(dog.name),
                onTap: () {
                  scheduleDog.value = dog;
                  Navigator.pop(context);
                },
              );
            },
          );
        },
      );
    }

    Future<void> selectUser(BuildContext context) async {
      if (scheduleDog.value == null) {
        return;
      }
      final users =
          await firestoreService.getUserByDogId(scheduleDog.value!.id);
      showModalBottomSheet(
        context: context,
        builder: (context) {
          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              if (user == null) {
                return const Text('ユーザーが見つかりません。Dog一覧画面から追加してください');
              }
              return ListTile(
                leading: Image.network(user.profileImage),
                title: Text(user.name),
                onTap: () {
                  scheduleUser.value = user;
                  Navigator.pop(context);
                },
              );
            },
          );
        },
      );
    }

    void createSchedule(String dogId, String userId) async {
      final schedule = ScheduleModel(
        id: '',
        name: '', // ここに必要ならnameフィールドを設定
        memo: memoController.text,
        startTime: startTime.value ?? DateTime.now(),
        endTime: endTime.value ?? DateTime.now(),
        pictures: [], // 必要ならば画像リストを設定
        dog: dogId,
        user: userId,
      );
      await firestoreService.addSchedule(schedule);
      ref.refresh(schedulesProvider(selectedDog!.id));
      Navigator.pop(context);
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          ElevatedButton(
            onPressed: () => selectDog(context),
            child: Text(scheduleDog.value == null
                ? 'Dogを選択してください'
                : 'Dog: ${scheduleDog.value!.name}'),
          ),
          ElevatedButton(
            onPressed: () => selectUser(context),
            child: Text(scheduleUser.value == null
                ? '散歩するユーザーを選択してください'
                : 'ユーザー: ${scheduleUser.value!.name}'),
          ),
          TextField(
            controller: memoController,
            decoration: const InputDecoration(labelText: 'メモ'),
          ),
          ElevatedButton(
            onPressed: () {
              DatePicker.showDateTimePicker(
                context,
                minTime: DateTime.now(),
                maxTime: DateTime(2100, 12, 31),
                onConfirm: (date) {
                  startTime.value = date;
                },
                currentTime: startTime.value ?? date,
              );
            },
            child: Text('${startTime.value ?? date} 開始時間'),
          ),
          ElevatedButton(
            onPressed: () {
              DatePicker.showDateTimePicker(
                context,
                minTime: DateTime.now(),
                maxTime: DateTime(2100, 12, 31),
                onConfirm: (date) {
                  endTime.value = date;
                },
                currentTime: startTime.value ?? date,
              );
            },
            child: Text('${endTime.value ?? date} 終了時間 '),
          ),
          (scheduleDog.value != null && scheduleUser.value != null)
              ? ElevatedButton(
                  onPressed: () => {
                    createSchedule(
                      scheduleDog.value!.id,
                      scheduleUser.value!.id,
                    ),
                  },
                  child: const Text('スケジュールを作成'),
                )
              : const ElevatedButton(
                  onPressed: null,
                  child: Text('Dogとユーザーを選択してください'),
                )
        ],
      ),
    );
  }
}

class ScheduleEditModalSheet extends HookConsumerWidget {
  const ScheduleEditModalSheet({required this.schedule, super.key});
  final ScheduleModel schedule;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedDog = ref.watch(selectedDogProvider);

    final memoController = useTextEditingController(text: schedule.memo);
    final startTime = useState<DateTime>(schedule.startTime);
    final endTime = useState<DateTime>(schedule.endTime);
    final firestoreService = ref.watch(firestoreServiceProvider);
    final scheduleUser = useState<UserModel?>(null);
    final scheduleDog = useState<DogModel?>(null);
    useEffect(() {
      Future.microtask(() async {
        final dog = await firestoreService.getDogById(schedule.dog);
        final user = await firestoreService.getUser(schedule.user);
        scheduleDog.value = dog;
        scheduleUser.value = user;
      });
      return null;
    }, []);

    Future<void> selectDog(BuildContext context) async {
      final dogs = await firestoreService.getAllDogs();
      showModalBottomSheet(
        context: context,
        builder: (context) {
          return ListView.builder(
            itemCount: dogs.length,
            itemBuilder: (context, index) {
              final dog = dogs[index];
              return ListTile(
                leading: Image.network(dog.profileImage),
                title: Text(dog.name),
                onTap: () {
                  scheduleDog.value = dog;
                  Navigator.pop(context);
                },
              );
            },
          );
        },
      );
    }

    Future<void> selectUser(BuildContext context) async {
      if (scheduleDog.value == null) {
        return;
      }
      final users =
          await firestoreService.getUserByDogId(scheduleDog.value!.id);
      showModalBottomSheet(
        context: context,
        builder: (context) {
          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              final user = users[index];
              if (user == null) {
                return const Text('ユーザーが見つかりません。Dog一覧画面から追加してください');
              }
              return ListTile(
                leading: Image.network(user.profileImage),
                title: Text(user.name),
                onTap: () {
                  scheduleUser.value = user;
                  Navigator.pop(context);
                },
              );
            },
          );
        },
      );
    }

    void updateSchedule(String dogId, String userId) async {
      final updatedSchedule = ScheduleModel(
        id: schedule.id,
        name: schedule.name, // 必要ならnameフィールドを設定
        memo: memoController.text,
        startTime: startTime.value,
        endTime: endTime.value,
        pictures: schedule.pictures, // 既存の画像リストを保持
        dog: dogId,
        user: userId,
      );
      await firestoreService.updateSchedule(updatedSchedule);
      ref.refresh(schedulesProvider(selectedDog!.id));
      Navigator.pop(context);
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          ElevatedButton(
            onPressed: () => selectDog(context),
            child: Text(scheduleDog.value == null
                ? 'Dogを選択してください'
                : 'Dog: ${scheduleDog.value!.name}'),
          ),
          ElevatedButton(
            onPressed: () => selectUser(context),
            child: Text(scheduleUser.value == null
                ? '散歩するユーザーを選択してください'
                : 'ユーザー: ${scheduleUser.value!.name}'),
          ),
          TextField(
            controller: memoController,
            decoration: const InputDecoration(labelText: 'メモ'),
          ),
          ElevatedButton(
            onPressed: () {
              DatePicker.showDateTimePicker(
                context,
                minTime: DateTime.now(),
                maxTime: DateTime(2100, 12, 31),
                onConfirm: (date) {
                  startTime.value = date;
                },
                currentTime: startTime.value,
              );
            },
            child: Text('${startTime.value} 開始時間'),
          ),
          ElevatedButton(
            onPressed: () {
              DatePicker.showDateTimePicker(
                context,
                minTime: DateTime.now(),
                maxTime: DateTime(2100, 12, 31),
                onConfirm: (date) {
                  endTime.value = date;
                },
                currentTime: endTime.value,
              );
            },
            child: Text('${endTime.value} 終了時間 '),
          ),
          (scheduleDog.value != null && scheduleUser.value != null)
              ? ElevatedButton(
                  onPressed: () => {
                    updateSchedule(
                      scheduleDog.value!.id,
                      scheduleUser.value!.id,
                    ),
                  },
                  child: const Text('スケジュールを更新'),
                )
              : const ElevatedButton(
                  onPressed: null,
                  child: Text('Dogとユーザーを選択してください'),
                )
        ],
      ),
    );
  }
}

class ScheduleCard extends StatelessWidget {
  final ScheduleModel schedule;

  const ScheduleCard({required this.schedule, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ScheduleDetailPage(schedule),
            ),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(width: 1, color: Colors.grey),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              const Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CircleAvatar(
                    radius: 25,
                    child: Icon(Icons.person_3, size: 30),
                  ),
                  CircleAvatar(
                    radius: 25,
                    child: Icon(Icons.pets, size: 30),
                  ),
                ],
              ),
              SizedBox(
                width: 250,
                child: Column(
                  children: [
                    Text(
                      '${schedule.startTime.hour}:${schedule.startTime.minute} ~ ${schedule.endTime.hour}:${schedule.endTime.minute}',
                      style: const TextStyle(fontSize: 18),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Icon(
                          Icons.picture_in_picture,
                          size: 100,
                        ),
                        const SizedBox(width: 24),
                        Expanded(
                          child: Text(
                            schedule.memo,
                            style: const TextStyle(fontSize: 18),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: Icon(Icons.edit),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return Dialog(
                              child: ScheduleEditModalSheet(schedule: schedule),
                            );
                          },
                        );
                      },
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
