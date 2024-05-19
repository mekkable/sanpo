import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sanpo/main.dart';
import 'package:sanpo/models/dog_model.dart';
import 'package:sanpo/models/schedule_model.dart';
import 'package:sanpo/models/user_model.dart';
import 'package:sanpo/providers.dart';
import 'package:sanpo/services/auth_service.dart';
import 'package:sanpo/services/firrestore_service.dart';
import '../services/firestore_service.dart';

class ScheduleIndexPage extends HookConsumerWidget {
  const ScheduleIndexPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firestoreService = ref.watch(firestoreServiceProvider);
    final selectedDog = ref.watch(selectedDogProvider);
    if (selectedDog == null) {
      return const Center(child: Text('犬が選択されていません'));
    }

    return FutureBuilder<List<ScheduleModel>>(
      future: firestoreService.getSchedules(selectedDog!.schedules),
      builder: (context, scheduleSnapshot) {
        if (scheduleSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (scheduleSnapshot.hasError) {
          return Center(child: Text('Error: ${scheduleSnapshot.error}'));
        }

        final schedules = scheduleSnapshot.data ?? [];
        if (schedules.isEmpty) {
          return const Center(child: Text('スケジュールがありません'));
        }
        //日付とスケジュールのリストのmap型
        final groupedSchedules = groupSchedulesByDate(schedules);
        final todayIndex = findTodayIndex(groupedSchedules);

        final controller = ScrollController(
          initialScrollOffset: todayIndex * 100.0,
        );

        return ListView.builder(
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
                    ? Text('スケジュールを作成してください')
                    : Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "${date.month.toString().padLeft(2, '0')}月${date.day.toString().padLeft(2, '0')}日",
                          style: const TextStyle(
                              fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      ),
                ...daySchedules
                    .map((schedule) => ScheduleCard(schedule: schedule))
                    .toList(),
              ],
            );
          },
        );
      },
    );
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
    return map;
  }

  int findTodayIndex(Map<DateTime, List<ScheduleModel>> groupedSchedules) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return groupedSchedules.keys
        .toList()
        .indexWhere((date) => date.isAtSameMomentAs(today));
  }
}

class ScheduleCard extends StatelessWidget {
  final ScheduleModel schedule;

  const ScheduleCard({required this.schedule, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '${schedule.startTime.hour}:${schedule.startTime.minute} ~ ${schedule.endTime.hour}:${schedule.endTime.minute}',
                style: const TextStyle(fontSize: 18),
              ),
              InkWell(
                onTap: () {},
                child: const Icon(
                  Icons.add,
                  size: 48,
                ),
              ),
            ],
          ),
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ScheduleDetailPage(schedule: schedule),
                ),
              );
            },
            child: Container(
              width: 400,
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
                          schedule.memo,
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
                            Text(schedule.memo),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ScheduleDetailPage extends StatelessWidget {
  final ScheduleModel schedule;

  const ScheduleDetailPage({required this.schedule, super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedule Detail'),
      ),
      body: Center(
        child: Text('Details of schedule ${schedule.name}'),
      ),
    );
  }
}
