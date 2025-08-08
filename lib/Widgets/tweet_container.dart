import 'package:flutter/material.dart';
import 'package:firetwitter/Constants/constants.dart';
import 'package:firetwitter/Models/tweet.dart';
import 'package:firetwitter/Models/user_model.dart';
import 'package:firetwitter/Services/database_services.dart';

class TweetContainer extends StatefulWidget {
  final Tweet tweet;
  final UserModel author;
  final String currentUserId;

  const TweetContainer({
    super.key,
    required this.tweet,
    required this.author,
    required this.currentUserId,
  });

  @override
  _TweetContainerState createState() => _TweetContainerState();
}

class _TweetContainerState extends State<TweetContainer> {
  int _likesCount = 0;
  bool _isLiked = false;
  bool _isRetweeted = false;

  @override
  void initState() {
    super.initState();
    _getTweetData(); // Lấy dữ liệu từ Firestore
  }

  void _getTweetData() async {
    bool isLiked = await DatabaseServices.isLikeTweet(widget.currentUserId, widget.tweet);
    setState(() {
      _isLiked = isLiked;
      _likesCount = widget.tweet.likes!;
    });
  }

  void _handleLike() async {
    if (_isLiked) {
      await DatabaseServices.unlikeTweet(widget.currentUserId, widget.tweet);
      setState(() {
        _isLiked = false;
        _likesCount--;
      });
    } else {
      await DatabaseServices.likeTweet(widget.currentUserId, widget.tweet);
      setState(() {
        _isLiked = true;
        _likesCount++;
      });
    }
  }

  void retweetTweet() async {
    if (_isRetweeted) {
      await DatabaseServices.unretweetTweet(widget.currentUserId, widget.tweet);
      setState(() {
        _isRetweeted = false;
      });
    } else {
      await DatabaseServices.retweetTweet(widget.currentUserId, widget.tweet);
      setState(() {
        _isRetweeted = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20.0,
                backgroundImage: widget.author.profilePicture!.isEmpty
                    ? AssetImage('assets/placeholder.png')
                    : NetworkImage(widget.author.profilePicture!),
              ),
              SizedBox(width: 10.0),
              Text(
                widget.author.name!,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          SizedBox(height: 15),
          Text(
            widget.tweet.text!,
            style: TextStyle(fontSize: 15),
          ),
          widget.tweet.image!.isEmpty
              ? SizedBox.shrink()
              : Column(
            children: [
              SizedBox(height: 15),
              Container(
                height: 250,
                decoration: BoxDecoration(
                  color: kTweeterColor,
                  borderRadius: BorderRadius.circular(10),
                  image: DecorationImage(
                    fit: BoxFit.cover,
                    image: NetworkImage(widget.tweet.image!),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          _isLiked ? Icons.favorite : Icons.favorite_border,
                          color: _isLiked ? Colors.red : null,
                        ),
                        onPressed: _handleLike,
                      ),
                      Text('$_likesCount Likes'),
                    ],
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          Icons.repeat,
                          color: _isRetweeted ? Colors.green : null,
                        ),
                        onPressed: retweetTweet,
                      ),
                      Text('${widget.tweet.retweets} Retweets'),
                    ],
                  ),
                ],
              ),
              Text(
                widget.tweet.timestamp!.toDate().toString().substring(0, 19),
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
          SizedBox(height: 10),
          Divider(),
        ],
      ),
    );
  }
}
