import 'package:firetwitter/Constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:firetwitter/Services/database_services.dart';

class ChatMessage {
  final String senderId;
  final String receiverId;
  final String message;
  final String createdAt;
  final bool seen;

  ChatMessage({
    required this.senderId,
    required this.receiverId,
    required this.message,
    required this.createdAt,
    required this.seen,
  });

  factory ChatMessage.fromMap(Map<String, dynamic> data) {
    return ChatMessage(
      senderId: data['senderId'],
      receiverId: data['receiverId'],
      message: data['message'],
      createdAt: data['createdAt'],
      seen: data['seen'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'receiverId': receiverId,
      'message': message,
      'createdAt': createdAt,
      'seen': seen,
    };
  }
}

class ChatScreen extends StatefulWidget {
  final String currentUserId;
  final String visitedUserId;
  final String chatRoomId;

  const ChatScreen({
    Key? key,
    required this.currentUserId,
    required this.visitedUserId,
    required this.chatRoomId,
  }) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  String getChatRoomId(String userId1, String userId2) {
    return userId1.compareTo(userId2) <= 0
        ? '$userId1\_$userId2'
        : '$userId2\_$userId1';
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final newMessage = ChatMessage(
      senderId: widget.currentUserId,
      receiverId: widget.visitedUserId,
      message: _messageController.text.trim(),
      createdAt: DateTime.now().toIso8601String(),
      seen: false,
    );

    String chatRoomId =
        getChatRoomId(widget.currentUserId, widget.visitedUserId);

    await DatabaseServices.sendMessage(
      chatRoomId,
      newMessage.toMap(),
    );

    _messageController.clear();
  }

  Widget _buildMessage(ChatMessage message, bool isMine) {
    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isMine ? Colors.blue : Colors.grey[300],
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          message.message,
          style: TextStyle(
            color: isMine ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _buildMessageList() {
    String chatRoomId =
        getChatRoomId(widget.currentUserId, widget.visitedUserId);

    return StreamBuilder<List<ChatMessage>>(
      stream: DatabaseServices.getMessages(chatRoomId).map(
        (snapshot) =>
            snapshot.map((data) => ChatMessage.fromMap(data)).toList(),
      ),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(child: Text('No messages yet.'));
        }
        final messages = snapshot.data!;
        return ListView.builder(
          reverse: true,
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final message = messages[index];
            final isMine = message.senderId == widget.currentUserId;
            return _buildMessage(message, isMine);
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Chat',
          style: TextStyle(
            fontSize: 20,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: kTweeterColor,
      ),
      body: Column(
        children: [
          Expanded(child: _buildMessageList()),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Type your message...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send, color: Colors.blue),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
