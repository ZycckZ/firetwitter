import 'package:cloud_firestore/cloud_firestore.dart';

class Tweet {
  String? id;
  String? authorId;
  String? text;
  String? image;
  Timestamp? timestamp;
  int? likes;
  int? retweets;
  final bool isLikedByCurrentUser; // Thêm thuộc tính
  final bool isRetweetedByCurrentUser; // Thêm thuộc tính

  Tweet(
      {this.id,
        this.authorId,
        this.text,
        this.image,
        this.timestamp,
        this.likes,
        this.retweets,
        this.isLikedByCurrentUser = false, // Giá trị mặc định
        this.isRetweetedByCurrentUser = false, // Giá trị mặc định
      });


  factory Tweet.fromDoc(DocumentSnapshot doc) {
    return Tweet(
      id: doc.id,
      authorId: doc['authorId'],
      text: doc['text'],
      image: doc['image'],
      timestamp: doc['timestamp'],
      likes: doc['likes'],
      retweets: doc['retweets'],
      isLikedByCurrentUser: false, // Có thể lấy giá trị từ Firestore nếu cần
      isRetweetedByCurrentUser: false, // Có thể lấy giá trị từ Firestore nếu cần
    );
  }

}