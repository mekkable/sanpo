import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sanpo/models/schedule_model.dart';
import 'package:sanpo/providers.dart';

class ScheduleDetailPage extends HookConsumerWidget {
  final ScheduleModel schedule;
  const ScheduleDetailPage(this.schedule, {super.key});

  Future<void> _deleteSchedule(BuildContext context, WidgetRef ref) async {
    final firestoreService = ref.read(firestoreServiceProvider);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('スケジュールを削除しますか？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('キャンセル'),
            ),
            TextButton(
              onPressed: () async {
                await firestoreService.deleteSchedule(
                  schedule.id,
                  schedule.dog,
                  schedule.user,
                );
                Navigator.of(context).popUntil((route) => route.isFirst);
                ref.refresh(schedulesProvider(schedule.dog));
              },
              child: const Text('削除'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('散歩詳細'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        actions: [
          IconButton(
              onPressed: () => _deleteSchedule(context, ref),
              icon: const Icon(Icons.delete))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundImage: NetworkImage(
                          'https://images.dog.ceo/breeds/schnauzer/n02097298_3900.jpg'),
                    ),
                    const SizedBox(height: 8),
                    const Icon(Icons.pets, size: 24),
                  ],
                ),
                const SizedBox(width: 16),
                Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundImage: NetworkImage('URL_TO_USER_IMAGE'),
                    ),
                    const SizedBox(height: 8),
                    const Icon(Icons.person, size: 24),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "${schedule.startTime.month.toString().padLeft(2, '0')}月${schedule.startTime.day.toString().padLeft(2, '0')}日",
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${schedule.startTime.hour}:${schedule.startTime.minute} ~ ${schedule.endTime.hour}:${schedule.endTime.minute}',
                    style: const TextStyle(fontSize: 18),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'メモ',
              style: const TextStyle(
                fontSize: 24,
                decoration: TextDecoration.underline,
              ),
            ),
            Container(
              height: 150,
              width: 400,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  schedule.memo,
                  style: const TextStyle(
                    fontSize: 24,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 4.0,
                    mainAxisSpacing: 4.0),
                itemCount: schedule.pictures.length,
                itemBuilder: (context, index) {
                  return Image.network(
                    schedule.pictures[index],
                    fit: BoxFit.cover,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
