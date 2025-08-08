import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firetwitter/Screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:firetwitter/Constants/constants.dart';
import 'package:firetwitter/Models/user_model.dart';
import 'package:firetwitter/Services/database_services.dart';

class SearchScreen extends StatefulWidget {
  final String? currentUserId;

  const SearchScreen({super.key, required this.currentUserId});
  @override
  State <SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  Future<QuerySnapshot>? _users;
  final TextEditingController _searchController = TextEditingController();

  clearSearch() {
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _searchController.clear());
    setState(() {
      _users = null;
    });
  }


  buildUserTile(UserModel user) {
    return ListTile(
      leading: CircleAvatar(
        radius: 20,
        backgroundImage: user.profilePicture!.isEmpty
            ? AssetImage('assets/placeholder.png')
            : NetworkImage(user.profilePicture ?? ''),
      ),
      title: Text(user.name ?? ''),
      onTap: () {
        Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => ProfileScreen(
              currentUserId: widget.currentUserId,
              visitedUserId: user.id,    // thêm userID: ''
            )));
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 0.5,
        title: TextField(
          controller: _searchController,
          style: TextStyle(
            color: Colors.white,
          ),
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(vertical: 15),
            hintText: 'Search...',
            hintStyle: TextStyle(color: Colors.white),
            fillColor: kTweeterColor,
            border: InputBorder.none,
            prefixIcon: Icon(Icons.search, color: Colors.white),
            suffixIcon: IconButton(
              icon: Icon(
                Icons.clear,
                color: Colors.white,
              ),
              onPressed: () {
                clearSearch();
              },
            ),
            filled: true,
          ),
          onChanged: (input) {
            if (input.isNotEmpty) {
              setState(() {
                _users = DatabaseServices.searchUsers(input);
              });
            }
          },
        ),
      ),
      body: _users == null
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, size: 200),
            Text(
              'Searching Twitter...',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w400),
            )
          ],
        ),
      )
          : FutureBuilder(
          future: _users,
          builder: (BuildContext context, AsyncSnapshot snapshot) {
            if (!snapshot.hasData) {
              return Center(
                child: CircularProgressIndicator(),
              );
            }
            if (snapshot.data.docs.length == 0) {
              return Center(
                child: Text(
                  'No users found!',
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              );
            }
            return ListView.builder(
                itemCount: snapshot.data.docs.length,
                itemBuilder: (BuildContext context, int index) {
                  UserModel user =
                  UserModel.fromDocument(snapshot.data.docs[index]);
                  return buildUserTile(user);
                });
          }),
    );
  }
}
