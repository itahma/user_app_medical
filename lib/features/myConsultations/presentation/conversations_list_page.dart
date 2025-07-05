import 'package:flutter/material.dart';
import 'package:newappgradu/features/myConsultations/data/api_service_chat.dart';

import 'chat_page.dart';


class ConversationsListPage extends StatefulWidget {
  const ConversationsListPage({super.key});

  @override
  State<ConversationsListPage> createState() => _ConversationsListPageState();
}

class _ConversationsListPageState extends State<ConversationsListPage> {
  late Future<List<dynamic>> _conversationsFuture;
  final ApiServiceChat _apiService = ApiServiceChat();

  @override
  void initState() {
    super.initState();
    _conversationsFuture = _apiService.getConversations();
  }

  void _refreshConversations() {
    setState(() {
      _conversationsFuture = _apiService.getConversations();
    });
  }

  @override
  Widget build(BuildContext context) {
    final baseUrl = _apiService.dio.options.baseUrl;

    return Scaffold(

      body: FutureBuilder<List<dynamic>>(
        future: _conversationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.teal));
          }
          if (snapshot.hasError) {
            return Center(child: Text('خطأ: ${snapshot.error.toString().replaceFirst("Exception: ", "")}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('لا توجد لديك أي محادثات.', style: TextStyle(fontSize: 18, color: Colors.grey)));
          }

          final conversations = snapshot.data!;

          return RefreshIndicator(
            onRefresh: () async => _refreshConversations(),
            child: ListView.separated(
              itemCount: conversations.length,
              separatorBuilder: (context, index) => const Divider(height: 1, indent: 80),
              itemBuilder: (context, index) {
                final user = conversations[index];
                final photoPath = user['photo'] as String?;
                final imageUrl = (photoPath != null && photoPath.isNotEmpty) ? '$baseUrl/$photoPath' : null;
                final name = "د. ${user['name']?['first'] ?? ''} ${user['name']?['last'] ?? 'غير معروف'}";

                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  leading: CircleAvatar(
                    radius: 30,
                    backgroundImage: imageUrl != null ? NetworkImage(imageUrl) : null,
                    child: imageUrl == null ? const Icon(Icons.person) : null,
                  ),
                  title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: const Text('انقر لعرض المحادثة...', style: TextStyle(color: Colors.grey)),
                  onTap: () {
                    Navigator.push<bool>(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatPage(
                          otherUserId: user['_id'],
                          otherUserName: name,
                          otherUserAvatarUrl: imageUrl,
                        ),
                      ),
                    ).then((value) { if (value == true) _refreshConversations(); });
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}