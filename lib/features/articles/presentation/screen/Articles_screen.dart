import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:newappgradu/features/articles/data/api_service_art.dart';
import 'articles_detials.dart';


class AllPostsPage extends StatefulWidget {
  const AllPostsPage({super.key});

  @override
  State<AllPostsPage> createState() => _AllPostsPageState();
}

class _AllPostsPageState extends State<AllPostsPage> {
  late Future<List<dynamic>> _postsFuture;
  final ApiServiceArt _apiService = ApiServiceArt();

  @override
  void initState() {
    super.initState();
    _postsFuture = _apiService.getAllPosts();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<dynamic>>(
        future: _postsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.teal));
          }
          if (snapshot.hasError) {
            return Center(child: Text('خطأ: ${snapshot.error.toString().replaceFirst("Exception: ", "")}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('لا توجد مقالات لعرضها حاليًا.', style: TextStyle(fontSize: 18, color: Colors.grey)));
          }

          final posts = snapshot.data!;

          posts.sort((a, b) {
            final aDate = a?['createdAt'] != null ? DateTime.tryParse(a['createdAt']) : null;
            final bDate = b?['createdAt'] != null ? DateTime.tryParse(b['createdAt']) : null;
            if (aDate == null && bDate == null) return 0;
            if (aDate == null) return 1;
            if (bDate == null) return -1;
            return bDate.compareTo(aDate);
          });

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: posts.length,
            itemBuilder: (context, index) {
              return _PostCard(post: posts[index]);
            },
          );
        },
      ),
    );
  }
}

class _PostCard extends StatelessWidget {
  final Map<String, dynamic> post;
  const _PostCard({required this.post});

  @override
  Widget build(BuildContext context) {
    final baseUrl = ApiServiceArt().dio.options.baseUrl;
    final photoPath = post['photo'] as String?;
    final imageUrl = (photoPath != null && photoPath.isNotEmpty) ? '$baseUrl/$photoPath' : null;

    final fromInfo = post['from'] as Map<String, dynamic>?;
    final docFirstName = fromInfo?['First_Name'] ?? '';
    final docLastName = fromInfo?['Last_Name'] ?? '';
    final doctorName = 'د. $docFirstName $docLastName';

    // --- بداية التعديل: معالجة آمنة للتاريخ ---
    String formattedDate = 'تاريخ غير محدد';
    final dateString = post['createdAt'] as String?;
    if (dateString != null) {
      try {
        final createdAt = DateTime.parse(dateString);
        formattedDate = DateFormat('d MMMM, y', 'ar_SA').format(createdAt.toLocal());
      } catch(e) {
        print("Could not format date for post card: ${post['_id']}");
      }
    }
    // --- نهاية التعديل ---

    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => PostDetailsPage(post: post)));
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (imageUrl != null)
              SizedBox(
                height: 200,
                width: double.infinity,
                child: Image.network(imageUrl, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.image_not_supported, color: Colors.grey, size: 50)),
              ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(post['title'] ?? 'بلا عنوان', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(children: [
                    Text(doctorName, style: TextStyle(fontSize: 15, color: Colors.teal[800], fontWeight: FontWeight.w500)),
                    const Spacer(),
                    Text(formattedDate, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                  ]),
                  const SizedBox(height: 12),
                  Text(post['text'] ?? '', maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 15, color: Colors.grey[700], height: 1.6)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}