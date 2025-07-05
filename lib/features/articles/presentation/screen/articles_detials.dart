import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../data/api_service_art.dart';

class PostDetailsPage extends StatelessWidget {
  final Map<String, dynamic> post;
  const PostDetailsPage({super.key, required this.post});

  @override
  Widget build(BuildContext context) {
    final baseUrl = ApiServiceArt().dio.options.baseUrl;
    final photoPath = post['photo'] as String?;
    final imageUrl = (photoPath != null && photoPath.isNotEmpty) ? '$baseUrl/$photoPath' : null;

    final fromInfo = post['from'] as Map<String, dynamic>?;
    final docFirstName = fromInfo?['First_Name'] ?? '';
    final docLastName = fromInfo?['Last_Name'] ?? '';
    final doctorName = 'د. $docFirstName $docLastName';

    final docPhotoPath = fromInfo?['profile'] as String?;
    final docImageUrl = (docPhotoPath != null && docPhotoPath.isNotEmpty) ? '$baseUrl/$docPhotoPath' : null;

    String formattedDate = 'تاريخ غير محدد';
    final dateString = post['createdAt'] as String?;
    if (dateString != null) {
      try {
        final createdAt = DateTime.parse(dateString);
        formattedDate = DateFormat('EEEE, d MMMM, y', 'ar_SA').format(createdAt.toLocal());
      } catch(e) { print("Could not format details date for post: ${post['_id']}"); }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(post['title'] ?? 'تفاصيل المقال', style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.teal,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // صورة المقال الرئيسية
            if (imageUrl != null)
              SizedBox(
                height: 250,
                width: double.infinity,
                child: Image.network(imageUrl, fit: BoxFit.cover),
              ),

            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // عنوان المقال
                  Text(
                    post['title'] ?? 'بلا عنوان',
                    style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, height: 1.4),
                  ),
                  const SizedBox(height: 16),

                  // معلومات الكاتب والتاريخ
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 25,
                        backgroundImage: docImageUrl != null ? NetworkImage(docImageUrl) : null,
                        child: docImageUrl == null ? const Icon(Icons.person) : null,
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(doctorName, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          Text(formattedDate, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                        ],
                      ),
                    ],
                  ),
                  const Divider(height: 30, thickness: 1),

                  // نص المقال الكامل
                  Text(
                    post['text'] ?? 'لا يوجد محتوى.',
                    style: const TextStyle(fontSize: 17, height: 1.8, color: Color(0xFF34495e)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}