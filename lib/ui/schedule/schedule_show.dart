import 'package:flutter/material.dart';

class ScheduleDeatailPage extends StatelessWidget {
  const ScheduleDeatailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: InkWell(
          onTap: () => Navigator.pop(context),
          child: Icon(Icons.arrow_back),
        ),
        title: Text('散歩詳細'),
      ),
      body: Center(
        child: Text('dta'),
      ),
    );
  }
}
