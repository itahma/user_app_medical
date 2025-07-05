import 'package:flutter/material.dart';

class RadiologyResultsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('نتائج الصور الشعائية'),
        centerTitle: true,
      ),
      body: Center(
        child: Text(
          'صفحة عرض نتائج التصوير الشعاعي',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
