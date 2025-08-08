import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firetwitter/Constants/constants.dart';
import 'package:firetwitter/Models/tweet.dart';
import 'package:firetwitter/Models/user_model.dart';
import 'package:firetwitter/Screens/edit_profile_screen.dart';
import 'package:firetwitter/Services/database_services.dart';
import 'package:firetwitter/Widgets/tweet_container.dart';
import 'package:firetwitter/Screens/login_screen.dart';


class ProfileScreen extends StatefulWidget {
  final String? currentUserId;
  final String? visitedUserId;

  const ProfileScreen({super.key, this.currentUserId, this.visitedUserId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _followersCount = 0;
  int _followingCount = 0;
  bool _isFollowing = false;
  int _profileSegmentedValue=0;
  List<Tweet> _allTweets=[];
  List<Tweet> _mediaTweets=[];

  final Map<int, Widget> _profileTabs = <int, Widget> {
    0: Padding(
      padding: EdgeInsets.symmetric(vertical: 10.0),
      child: Text(
        'Tweets',
        style: TextStyle(
          fontSize: 13.0,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    ),
    1: Padding(
      padding: EdgeInsets.symmetric(vertical: 10.0),
      child: Text(
        'Media',
        style: TextStyle(
          fontSize: 13.0,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    ),
    2: Padding(
      padding: EdgeInsets.symmetric(vertical: 10.0),
      child: Text(
        'Likes',
        style: TextStyle(
          fontSize: 13.0,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    ),
  };

  Widget buildProfileWidgets(UserModel author) {
    switch(_profileSegmentedValue) {
      case 0:
        return ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: _allTweets.length,
            itemBuilder: (context, index) {
              return TweetContainer(
                author : author,
                tweet : _allTweets[index], currentUserId: '',
              );
            });
      case 1:
        return ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: _mediaTweets.length,
            itemBuilder: (context, index) {
              return TweetContainer(
                author : author,
                tweet : _mediaTweets[index], currentUserId: '',
              );
            });
      case 2:
        return Center(child: Text('Likes', style: TextStyle(fontSize: 25.0)));
      default:
        return Center(child: Text('Something is wrong!', style: TextStyle(fontSize: 25.0)));
    }
  }

  getFollowersCount() async {
    int followersCount =
    await DatabaseServices.followersNum(widget.visitedUserId!);
    if (mounted) {
      setState(() {
        _followersCount = followersCount;
      });
    }
  }

  getFollowingCount() async {
    int followingCount =
    await DatabaseServices.followingNum(widget.visitedUserId!);
    if (mounted) {
      setState(() {
        _followingCount = followingCount;
      });
    }
  }

  followOrUnFollow() {
    if(_isFollowing) {
      unFollowUser();
    } else {
      followUser();
    }
  }

  unFollowUser() {
    DatabaseServices.unFollowUser(widget.currentUserId!, widget.visitedUserId!);
    setState(() {
      _isFollowing=false;
      _followingCount--;
    });
  }


  followUser() {
    DatabaseServices.followUser(widget.currentUserId!, widget.visitedUserId!);
    setState(() {
      _isFollowing=true;
      _followingCount++;
    });
  }


  setupIsFollowing() async{
    bool isFollowingThisUser = await DatabaseServices.isFollowingUser(widget.currentUserId!, widget.visitedUserId!);
    setState(() {
      _isFollowing = isFollowingThisUser;
    });
  }

  getAllTweets() async{
    List<Tweet> userTweets = await DatabaseServices.getUserTweets(widget.visitedUserId);
    if(mounted) {
      setState(() {
        _allTweets = userTweets;
        _mediaTweets = _allTweets.where((element) => element.image!.isNotEmpty).toList();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getFollowersCount();
    getFollowingCount();
    setupIsFollowing();
    getAllTweets();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: FutureBuilder(
        future: usersRef.doc(widget.visitedUserId).get(),
        builder: (BuildContext context, AsyncSnapshot snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(kTweeterColor),
              ),
            );
          }
          // Kiểm tra nếu tài liệu không tồn tại
          if (!snapshot.data!.exists) {
            return Center(
              child: Text(
                'User not found',
                style: TextStyle(
                  fontSize: 30,
                  color: Colors.black,
                  fontWeight:FontWeight.bold,
                ),
              ),
            );
          }

          UserModel userModel = UserModel.fromDocument(snapshot.data!);
          return ListView(
            physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics()
            ),
            children: [
              Container(
                height: 150,
                decoration: BoxDecoration(
                  color: kTweeterColor,
                  image: userModel.coverImage!.isEmpty
                      ? null
                      : DecorationImage(
                    fit: BoxFit.cover,
                    image: NetworkImage(userModel.coverImage!),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20.0, vertical: 10.0
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox.shrink(),
                      widget.currentUserId==widget.visitedUserId?
                      PopupMenuButton<String>(
                        icon: Icon(
                          Icons.more_horiz,
                          color: Colors.white,
                          size: 30.0,
                        ),
                        itemBuilder: (BuildContext context) {
                          return <PopupMenuItem<String>>[
                            PopupMenuItem(
                              value: 'logout',
                              child: Text('Log out'),
                            ),
                          ];
                        },
                        onSelected: (String selectedItem) async {
                          if (selectedItem == 'logout') {
                            await FirebaseAuth.instance.signOut();
                            Navigator.of(context).pushAndRemoveUntil(
                              MaterialPageRoute(builder: (context) => LoginScreen()), // Đảm bảo LoginPage được định nghĩa đúng
                                  (Route<dynamic> route) => false,
                            );
                          }
                        },
                      ) :SizedBox(),
                    ],
                  ),
                ),
              ),
              Container(
                transform: Matrix4.translationValues(0.0, -40.0, 0.0),
                padding: EdgeInsets.symmetric(horizontal: 20.0,),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        CircleAvatar(
                          radius: 45.0,
                          backgroundImage:(userModel.profilePicture?.isEmpty ?? true)
                              ? AssetImage('assets/placeholder.png')
                              : NetworkImage(userModel.profilePicture !),
                        ),
                        widget.currentUserId == widget.visitedUserId ?
                        GestureDetector(
                          onTap: () async{
                            await Navigator.push(context, MaterialPageRoute(
                              builder: (context)=>EditProfileScreen(
                                user:userModel,
                              ),
                            ),
                            );
                            setState(() {});
                          },
                          child: Container(
                            width: 100.0,
                            height: 35.0,
                            padding: EdgeInsets.symmetric(horizontal: 10.0,),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.white,
                              border: Border.all(color: kTweeterColor),
                            ),
                            child: Center(
                              child: Text(
                                'Edit',
                                style: TextStyle(
                                  fontSize: 20.0,
                                  color: kTweeterColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        )
                            : GestureDetector(
                          onTap: followOrUnFollow,
                          child: Container(
                            width: 100.0,
                            height: 35.0,
                            padding: EdgeInsets.symmetric(horizontal: 10.0,),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: _isFollowing
                                  ? Colors.white
                                  : kTweeterColor,
                              border: Border.all(color: kTweeterColor),
                            ),
                            child: Center(
                              child: Text(
                                _isFollowing? 'Following' : 'Follow',
                                style: TextStyle(
                                  fontSize: 15.0,
                                  color: _isFollowing
                                      ? kTweeterColor
                                      : Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10.0,),
                    Text(
                      userModel.name!,
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10.0,),
                    Text(
                      userModel.bio!,
                      style: TextStyle(
                        fontSize: 15.0,
                      ),
                    ),
                    SizedBox(height: 15.0,),
                    Row(
                      children: [
                        Text(
                          '$_followingCount Following',
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 2.0,
                          ),
                        ),
                        SizedBox(width: 20.0),
                        Text(
                          '$_followersCount Followers',
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 2.0,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 20.0,),
                    SizedBox(
                      width: MediaQuery.of(context).size.width,
                      child: CupertinoSlidingSegmentedControl(
                        groupValue: _profileSegmentedValue,
                        thumbColor: kTweeterColor,
                        backgroundColor: Colors.blueGrey,
                        children: _profileTabs,
                        onValueChanged: (i) {
                          setState(() {
                            _profileSegmentedValue=i!;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
              buildProfileWidgets(userModel),
            ],
          );
        },
      ),
    );
  }
}
