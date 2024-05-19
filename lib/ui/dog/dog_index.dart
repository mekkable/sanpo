import 'package:flutter/material.dart';

class DogIndexScreen extends StatelessWidget {
  const DogIndexScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: InkWell(
          onTap: () => Navigator.pop(context),
          child: Icon(Icons.arrow_back),
        ),
        title: Text('一覧'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            InkWell(
              onTap: () {},
              child: Container(
                padding: EdgeInsets.all(12),
                width: 400,
                decoration: BoxDecoration(
                  border: Border.all(width: 1, color: Colors.grey),
                ),
                child: Column(
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CircleAvatar(
                          radius: 32,
                          child: Icon(Icons.pets, size: 30),
                        ),
                        Text(
                          'DogName',
                          style: TextStyle(fontSize: 32),
                        )
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Icon(
                          Icons.photo,
                          size: 128,
                        ),
                        Icon(
                          Icons.photo,
                          size: 128,
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
            SizedBox(
              height: 16,
            ),
            InkWell(
              onTap: () {},
              child: Container(
                padding: EdgeInsets.all(12),
                width: 400,
                decoration: BoxDecoration(
                  border: Border.all(width: 1, color: Colors.grey),
                ),
                child: const Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CircleAvatar(
                          radius: 32,
                          child: Icon(Icons.pets, size: 30),
                        ),
                        Text(
                          'DogName',
                          style: TextStyle(fontSize: 32),
                        )
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Icon(
                          Icons.photo,
                          size: 128,
                        ),
                        Icon(
                          Icons.photo,
                          size: 128,
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
