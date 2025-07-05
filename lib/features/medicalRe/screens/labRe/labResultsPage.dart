import 'package:flutter/material.dart';

class LabResultsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('نتائج التحاليل الطبية'),
        centerTitle: true,
      ),
      body: Center(
        child: Text(
          'صفحة عرض نتائج التحاليل الطبية',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
