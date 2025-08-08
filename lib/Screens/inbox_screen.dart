import 'package:flutter/material.dart';
import 'package:firetwitter/Screens/search_user_screen.dart';
import 'package:firetwitter/Constants/constants.dart';

class InboxScreen extends StatelessWidget {
  final String currentUserId;
  final String name;

  const InboxScreen({super.key, required this.currentUserId, required this.name});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Inbox'),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        child: Icon(Icons.search, color: kTweeterColor),
        onPressed: () {
          // Điều hướng đến màn hình tìm kiếm người dùng
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SearchUserScreen(currentUserId: currentUserId),
            ),
          );
        },
      ),
      body: Center(
        child: Text(
          'Danh sách tin nhắn',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
