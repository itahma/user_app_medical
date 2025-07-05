import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:newappgradu/features/myConsultations/data/api_service_chat.dart';


class ChatPage extends StatefulWidget {
  final String otherUserId;
  final String otherUserName;
  final String? otherUserAvatarUrl;

  const ChatPage({
    super.key,
    required this.otherUserId,
    required this.otherUserName,
    this.otherUserAvatarUrl,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final ApiServiceChat _apiService = ApiServiceChat();
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  late Future<List<dynamic>> _chatHistoryFuture;
  bool _isSending = false;
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  void _fetchHistory() {
    setState(() {
      _chatHistoryFuture = _apiService.getChatHistory(widget.otherUserId);
    });
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 50);
    if (pickedFile != null) {
      setState(() => _selectedImage = File(pickedFile.path));
      // إرسال الصورة فورًا أو عرضها للمعاينة قبل الإرسال
      _sendMessage();
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.isEmpty && _selectedImage == null) return;

    setState(() => _isSending = true);

    try {
      await _apiService.sendMessage(
        receiverId: widget.otherUserId,
        message: _messageController.text,
        image: _selectedImage,
      );
      _messageController.clear();
      _selectedImage = null;
      _fetchHistory(); // تحديث المحادثة
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString()), backgroundColor: Colors.red));
    } finally {
      setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(widget.otherUserName, style: const TextStyle(color: Colors.white)),
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: _chatHistoryFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                if (snapshot.hasError) return Center(child: Text('خطأ: ${snapshot.error}'));
                if (!snapshot.hasData || snapshot.data!.isEmpty) return const Center(child: Text('ابدأ المحادثة الآن.'));

                final messages = snapshot.data!;
                return ListView.builder(
                  controller: _scrollController,
                  reverse: true, // لعرض أحدث الرسائل في الأسفل
                  padding: const EdgeInsets.all(10.0),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    return _MessageBubble(message: messages[index]);
                  },
                );
              },
            ),
          ),
          _buildMessageComposer(),
        ],
      ),
    );
  }

  Widget _buildMessageComposer() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      height: 70.0,
      color: Colors.white,
      child: Row(
        children: <Widget>[
          IconButton(
            icon: const Icon(Icons.photo),
            iconSize: 25.0,
            color: Colors.teal,
            onPressed: _pickImage,
          ),
          Expanded(
            child: TextField(
              controller: _messageController,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration.collapsed(hintText: 'أرسل رسالة...'),
            ),
          ),
          _isSending
              ? const Padding(padding: EdgeInsets.all(8.0), child: CircularProgressIndicator())
              : IconButton(
            icon: const Icon(Icons.send),
            iconSize: 25.0,
            color: Colors.teal,
            onPressed: _sendMessage,
          ),
        ],
      ),
    );
  }
}


// ويدجت لعرض كل رسالة بشكل منفصل
class _MessageBubble extends StatelessWidget {
  final Map<String, dynamic> message;
  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final bool isMe = message['isme'] ?? false;
    final String baseUrl = ApiServiceChat().dio.options.baseUrl;
    final imagePath = message['image'] as String?;
    final imageUrl = (imagePath != null && imagePath.isNotEmpty) ? '$baseUrl/$imagePath' : null;

    final bubble = Container(
      margin: isMe
          ? const EdgeInsets.only(top: 8.0, bottom: 8.0, left: 80.0)
          : const EdgeInsets.only(top: 8.0, bottom: 8.0, right: 80.0),
      padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 10.0),
      decoration: BoxDecoration(
        color: isMe ? Colors.teal[100] : Colors.grey[200],
        borderRadius: isMe
            ? const BorderRadius.only(topLeft: Radius.circular(15.0), bottomLeft: Radius.circular(15.0), topRight: Radius.circular(15.0))
            : const BorderRadius.only(topLeft: Radius.circular(15.0), bottomRight: Radius.circular(15.0), topRight: Radius.circular(15.0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if(imageUrl != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.network(imageUrl, height: 150, width: double.infinity, fit: BoxFit.cover, errorBuilder: (c,e,s) => const Icon(Icons.broken_image)),
            ),
          if(message['message'] != null && message['message'].isNotEmpty)
            Padding(
              padding: EdgeInsets.only(top: imageUrl != null ? 8.0 : 0),
              child: Text(message['message']),
            ),
        ],
      ),
    );
    return bubble;
  }
}