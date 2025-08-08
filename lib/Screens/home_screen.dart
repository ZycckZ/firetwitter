import 'package:flutter/material.dart';
import 'package:firetwitter/Constants/constants.dart';
import 'package:firetwitter/Models/tweet.dart';
import 'package:firetwitter/Models/user_model.dart';
import 'package:firetwitter/Screens/create_tweet_screen.dart';
import 'package:firetwitter/Screens/inbox_screen.dart'; // Import màn hình InboxScreen
import 'package:firetwitter/Services/database_services.dart';
import 'package:firetwitter/Widgets/tweet_container.dart';

class HomeScreen extends StatefulWidget {
  final String currentUserId;

  const HomeScreen({super.key, required this.currentUserId});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List _followingTweets = [];
  bool _loading = false;
  int _selectedIndex = 0; // Để theo dõi chỉ mục của tab hiện tại

  // Hàm điều hướng khi chọn tab trong BottomNavigationBar
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    if (index == 1) {
      // Điều hướng tới InboxScreen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              InboxScreen(currentUserId: widget.currentUserId, name: ''),
        ),
      );
    }
  }

  buildTweets(Tweet tweet, UserModel author) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15),
      child: TweetContainer(
        tweet: tweet,
        author: author,
        currentUserId: widget.currentUserId,
      ),
    );
  }

  showFollowingTweets(String currentUserId) {
    List<Widget> followingTweetsList = [];
    for (Tweet tweet in _followingTweets) {
      followingTweetsList.add(
        FutureBuilder(
            future: usersRef.doc(tweet.authorId).get(),
            builder: (BuildContext context, AsyncSnapshot snapshot) {
              if (snapshot.hasData) {
                UserModel author = UserModel.fromDocument(snapshot.data);
                return buildTweets(tweet, author);
              } else {
                return SizedBox.shrink();
              }
            }),
      );
    }
    return followingTweetsList;
  }

  setupFollowingTweets() async {
    setState(() {
      _loading = true;
    });
    List followingTweets = await DatabaseServices.getHomeTweets(
        widget.currentUserId);
    if (mounted) {
      setState(() {
        _followingTweets = followingTweets;
        _loading = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    setupFollowingTweets();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        child: Image.asset('assets/tweet.png'),
        onPressed: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    CreateTweetScreen(
                      currentUserId: widget.currentUserId,
                    ),
              ));
        },
      ),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: true,
        leading: Container(
          height: 40,
          child: Image.asset('assets/logo.png'),
        ),
        title: Text(
          'Home Screen',
          style: TextStyle(
            color: kTweeterColor,
          ),
        ),
      ),

      body: RefreshIndicator(
        onRefresh: () => setupFollowingTweets(),
        child: ListView(
          physics: BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics(),
          ),
          children: [
            _loading ? LinearProgressIndicator() : SizedBox.shrink(),
            SizedBox(height: 5),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(height: 5),
                Column(
                  children: _followingTweets.isEmpty && _loading == false
                      ? [
                    SizedBox(height: 5),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 25),
                      child: Text(
                        'No new tweets',
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ]
                      : showFollowingTweets(widget.currentUserId),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
