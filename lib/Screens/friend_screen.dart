import 'package:flutter/material.dart';
import 'package:firetwitter/Services/database_services.dart';
import 'package:firetwitter/Models/user_model.dart';
import 'package:firetwitter/Screens/profile_screen.dart';

class FriendsScreen extends StatefulWidget {
  final String currentUserId;

  const FriendsScreen({super.key, required this.currentUserId});

  @override
  _FriendsScreenState createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  List<UserModel> friendsList = []; // Danh sách bạn bè

  @override
  void initState() {
    super.initState();
    _loadFriends(); // Tải danh sách bạn bè khi khởi tạo màn hình
  }

  // Hàm tải danh sách bạn bè từ Firestore
  _loadFriends() async {
    List<UserModel> friends = await DatabaseServices.getFriendsList(widget.currentUserId);
    setState(() {
      friendsList = friends; // Cập nhật danh sách bạn bè sau khi tải
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Friends'),
      ),
      body: friendsList.isEmpty
          ? FutureBuilder<List<UserModel>>(
        future: DatabaseServices.getFriendsList(widget.currentUserId),
        builder: (context, snapshot) {
          // Nếu dữ liệu đang tải, hiển thị vòng tròn chờ
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          // Nếu có lỗi trong quá trình tải dữ liệu
          else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          // Nếu danh sách bạn bè rỗng
          else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                'You have no friends yet.',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            );
          }
          // Nếu dữ liệu đã được tải thành công
          else {
            List<UserModel> friends = snapshot.data!;
            return ListView.builder(
              itemCount: friends.length,
              itemBuilder: (context, index) {
                UserModel friend = friends[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundImage: NetworkImage(friend.profilePicture ?? ''),
                  ),
                  title: Text(friend.name ?? 'Unknown'),
                  subtitle: Text(friend.bio ?? 'No bio available'),
                  onTap: () {
                    // Điều hướng đến màn hình Profile của bạn bè
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ProfileScreen(
                          currentUserId: widget.currentUserId,
                          visitedUserId: friend.id!,
                        ),
                      ),
                    );
                  },
                );
              },
            );
          }
        },
      )
          : ListView.builder(
        itemCount: friendsList.length,
        itemBuilder: (context, index) {
          UserModel friend = friendsList[index];
          return ListTile(
            leading: CircleAvatar(
              backgroundImage: NetworkImage(friend.profilePicture ?? ''),
            ),
            title: Text(friend.name ?? 'Unknown'),
            subtitle: Text(friend.bio ?? 'No bio available'),
            onTap: () {
              // Khi người dùng nhấn vào bạn bè, điều hướng tới ProfileScreen của họ
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfileScreen(
                    currentUserId: widget.currentUserId,
                    visitedUserId: friend.id!,
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
