import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firetwitter/Models/user_model.dart';
import 'package:firetwitter/Services/database_services.dart';
import 'package:firetwitter/Screens/chat_screen.dart';

class SearchUserScreen extends StatefulWidget {
  final String currentUserId;

  const SearchUserScreen({super.key, required this.currentUserId});

  @override
  State<SearchUserScreen> createState() => _SearchUserScreenState();
}

class _SearchUserScreenState extends State<SearchUserScreen> {
  late Future<List<UserModel>> _userList;

  Future<List<UserModel>> getUsers() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('users').get();
    return snapshot.docs.map((doc) => UserModel.fromDocument(doc)).toList();
  }

  @override
  void initState() {
    super.initState();
    _userList = getUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Tìm kiếm người dùng"),
      ),
      body: FutureBuilder<List<UserModel>>(
        future: _userList,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Đã xảy ra lỗi!'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Không có người dùng nào.'));
          }

          List<UserModel> users = snapshot.data!;

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              UserModel user = users[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(user.profilePicture),
                ),
                title: Text(user.name),
                subtitle: Text(user.email),
                onTap: () async {
                  // Tạo chat room giữa user hiện tại và người dùng đang chọn
                  String chatRoomId = await DatabaseServices.createChatRoom(widget.currentUserId, user.id);
                  print("Chat Room ID: $chatRoomId");  // In chatRoomId để kiểm tra

                  Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => ChatScreen(
                      currentUserId: widget.currentUserId,
                      visitedUserId: user.id,
                      chatRoomId: chatRoomId,
                    ),
                  ));
                },
              );
            },
          );
        },
      ),
    );
  }
}
