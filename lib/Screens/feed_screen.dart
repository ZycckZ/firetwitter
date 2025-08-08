import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firetwitter/Constants/constants.dart';
import 'package:firetwitter/Screens/home_screen.dart';
import 'package:firetwitter/Screens/profile_screen.dart';
import 'package:firetwitter/Screens/search_screen.dart';
import 'package:firetwitter/Screens/friend_screen.dart';

import 'inbox_screen.dart';

class FeedScreen extends StatefulWidget {
  final String currentUserId;
  const FeedScreen({super.key, required this.currentUserId});

  @override
  State<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: [
        HomeScreen(
          currentUserId: widget.currentUserId,
        ),
        SearchScreen(
          currentUserId: widget.currentUserId,
        ),
        ProfileScreen(
          currentUserId: widget.currentUserId,
          visitedUserId: widget.currentUserId,
        ),
        FriendsScreen(
          currentUserId: widget.currentUserId,
        ),
        InboxScreen(
          currentUserId: widget.currentUserId, name: '',
        ),
      ].elementAt(_selectedTab),
      bottomNavigationBar: CupertinoTabBar(
        onTap: (index) {
          setState(() {
            _selectedTab = index;
          });
        },
        activeColor: kTweeterColor,
        currentIndex: _selectedTab,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home)),
          BottomNavigationBarItem(icon: Icon(Icons.search)),
          BottomNavigationBarItem(icon: Icon(Icons.person)),
          BottomNavigationBarItem(icon: Icon(Icons.group)),
          BottomNavigationBarItem(icon: Icon(Icons.message_sharp)),
        ],
      ),
    );
  }
}