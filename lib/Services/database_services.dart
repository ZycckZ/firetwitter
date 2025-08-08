import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firetwitter/Constants/constants.dart';
import 'package:firetwitter/Models/tweet.dart';
import 'package:firetwitter/Models/user_model.dart';

class DatabaseServices {

  static Future<int> followersNum(String userId) async {
    QuerySnapshot followersSnapshot =
        await followersRef.doc(userId).collection('Followers').get();
    return followersSnapshot.docs.length;
  }

  static Future<int> followingNum(String userId) async {
    QuerySnapshot followingSnapshot =
        await followingRef.doc(userId).collection('Following').get();
    return followingSnapshot.docs.length;
  }

  static Future<void> updateUserData(UserModel user) async {
    usersRef.doc(user.id).update({
      'name': user.name,
      'bio': user.bio,
      'profilePicture': user.profilePicture,
      'coverImage': user.coverImage,
    });
  }

  static Future<QuerySnapshot> searchUsers(String name) async {
    Future<QuerySnapshot> users = usersRef
        .where('name', isGreaterThanOrEqualTo: name)
        .where('name', isLessThan: name + 'z')
        .get();
    return users;
  }

  static void followUser(String currentUserId, String visitedUserId) {
    followingRef
        .doc(currentUserId)
        .collection('Following')
        .doc(visitedUserId)
        .set({});
    followersRef
        .doc(visitedUserId)
        .collection('Followers')
        .doc(currentUserId)
        .set({});
  }

  static void unFollowUser(String currentUserId, String visitedUserId) {
    followingRef
        .doc(currentUserId)
        .collection('Following')
        .doc(visitedUserId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });

    followersRef
        .doc(visitedUserId)
        .collection('Followers')
        .doc(currentUserId)
        .get()
        .then((doc) {
      if (doc.exists) {
        doc.reference.delete();
      }
    });
  }

  static Future<bool> isFollowingUser(
      String currentUserId, String visitedUserId) async {
    DocumentSnapshot followingDoc = await followersRef
        .doc(visitedUserId)
        .collection('Followers')
        .doc(currentUserId)
        .get();
    return followingDoc.exists;
  }

  // 1. Thêm bạn bè
  static void addFriend(String currentUserId, String friendId) {
    usersRef.doc(currentUserId).collection('friends').doc(friendId).set({});
    usersRef.doc(friendId).collection('friends').doc(currentUserId).set({});
  }

  // 2. Xóa bạn bè
  static void removeFriend(String currentUserId, String friendId) {
    usersRef.doc(currentUserId).collection('friends').doc(friendId).delete();
    usersRef.doc(friendId).collection('friends').doc(currentUserId).delete();
  }

  // 3. Kiểm tra xem đã là bạn bè chưa
  static Future<bool> isFriend(String currentUserId, String friendId) async {
    DocumentSnapshot friendDoc = await usersRef
        .doc(currentUserId)
        .collection('friends')
        .doc(friendId)
        .get();
    return friendDoc.exists;
  }

  // 4. Lấy danh sách bạn bè
  static Future<List<UserModel>> getFriendsList(String userId) async {
    // Lấy danh sách những người mà userId đang follow
    QuerySnapshot followingSnapshot =
        await followingRef.doc(userId).collection('Following').get();

    List<String> followingIds =
        followingSnapshot.docs.map((doc) => doc.id).toList();

    // Lấy danh sách những người theo dõi userId
    QuerySnapshot followersSnapshot =
        await followersRef.doc(userId).collection('Followers').get();

    List<String> followerIds =
        followersSnapshot.docs.map((doc) => doc.id).toList();

    // Tìm danh sách bạn bè, là những người mà userId follow và cũng follow lại
    List<String> friendIds =
        followingIds.where((id) => followerIds.contains(id)).toList();

    // Lấy thông tin người dùng từ Firestore
    List<UserModel> friends = [];
    for (String friendId in friendIds) {
      DocumentSnapshot userDoc = await usersRef.doc(friendId).get();
      if (userDoc.exists) {
        friends.add(UserModel.fromDocument(userDoc));
      }
    }

    return friends;
  }

  // 5. Lấy danh sách người theo dõi
  static Future<List<UserModel>> getFollowersList(String userId) async {
    QuerySnapshot followersSnapshot =
        await followersRef.doc(userId).collection('Followers').get();

    List<UserModel> followers = [];
    for (var doc in followersSnapshot.docs) {
      UserModel user = UserModel.fromDocument(doc);
      followers.add(user);
    }

    return followers;
  }

  // 6. Lấy danh sách người đang theo dõi
  static Future<List<UserModel>> getFollowingList(String userId) async {
    QuerySnapshot followingSnapshot =
        await followingRef.doc(userId).collection('Following').get();

    List<UserModel> following = [];
    for (var doc in followingSnapshot.docs) {
      UserModel user = UserModel.fromDocument(doc);
      following.add(user);
    }

    return following;
  }

  static void createTweet(Tweet tweet) {
    // In ra thông tin tweet trước khi thêm vào Firestore
    print('Adding tweet for user: ${tweet.authorId}');
    print('Tweet text: ${tweet.text}');

    // Thêm timestamp vào tài liệu của user trong collection 'tweets'
    tweetsRef.doc(tweet.authorId).set({
      'tweetTime': tweet.timestamp,
    }, SetOptions(merge: true)).then((_) {
      print("Tweet time added successfully!");
    }).catchError((e) {
      print('Error adding tweet time: $e');
    });

    // Thêm tweet vào sub-collection 'userTweets'
    tweetsRef.doc(tweet.authorId).collection('userTweets').add({
      'text': tweet.text,
      'image': tweet.image,
      "authorId": tweet.authorId,
      "timestamp": tweet.timestamp,
      'likes': tweet.likes,
      'retweets': tweet.retweets,
    }).then((docRef) {
      // In ra ID của tweet sau khi thêm thành công
      print('Tweet added with ID: ${docRef.id}');
    }).catchError((e) {
      // In lỗi nếu có sự cố
      print('Error adding tweet: $e');
    });
  }

  static Future<List<Tweet>> getUserTweets(String? userId) async {
    QuerySnapshot userTweetsSnap = await tweetsRef
        .doc(userId)
        .collection('userTweets')
        .orderBy('timestamp', descending: true)
        .get();

    // Chuyển đổi các tài liệu trong QuerySnapshot thành đối tượng Tweet
    List<Tweet> userTweets = userTweetsSnap.docs
        .map((doc) => Tweet.fromDoc(doc)) // Tạo đối tượng Tweet từ doc
        .toList(); // Chuyển đổi thành danh sách

    return userTweets;
  }

  static Future<List> getHomeTweets(String currentUserId) async {
    QuerySnapshot homeTweets = await feedRefs
        .doc(currentUserId)
        .collection('userFeed')
        .orderBy('timestamp', descending: true)
        .get();

    List<Tweet> followingTweets =
        homeTweets.docs.map((doc) => Tweet.fromDoc(doc)).toList();
    return followingTweets;
  }

  // Thêm like vào tweet
  static Future<void> likeTweet(String userId, Tweet tweet) async {
    try {
      await tweetsRef.doc(tweet.authorId).collection('userTweets').doc(tweet.id).update({
        'likes': FieldValue.increment(1),
      });
      await likesRef
          .doc(tweet.id)
          .collection('tweetLikes')
          .doc(userId)
          .set({});
    } catch (e) {
      print("Error liking tweet: $e");
    }
  }


  // Bỏ like khỏi tweet
  static Future<void> unlikeTweet(String userId, Tweet tweet) async {
    try {
      await tweetsRef.doc(tweet.authorId).collection('userTweets').doc(tweet.id).update({
        'likes': FieldValue.increment(-1),
      });
      await likesRef
          .doc(tweet.id)
          .collection('tweetLikes')
          .doc(userId)
          .delete();
    } catch (e) {
      print("Error unliking tweet: $e");
    }
  }


  // Kiểm tra xem người dùng đã like tweet hay chưa
  static Future<bool> isLikeTweet(String userId, Tweet tweet) async {
    try {
      DocumentSnapshot likeDoc = await likesRef
          .doc(tweet.id)
          .collection('tweetLikes')
          .doc(userId)
          .get();
      return likeDoc.exists;
    } catch (e) {
      print("Error checking like status: $e");
      return false;
    }
  }


  // Hàm xử lý retweet
  static Future<void> retweetTweet(String userId, Tweet tweet) async {
    try {
      await tweetsRef.doc(tweet.id).update({
        'retweets': FieldValue.increment(1), // Tăng số lượng retweets
      });
      await tweetsRef.doc('${tweet.id}_$userId').set({
        'userId': userId,
        'tweetId': tweet.id,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("Error retweeting tweet: $e");
    }
  }

  // Hàm xử lý unretweet
  static Future<void> unretweetTweet(String userId, Tweet tweet) async {
    try {
      await tweetsRef.doc(tweet.id).update({
        'retweets': FieldValue.increment(-1), // Giảm số lượng retweets
      });
      await tweetsRef.doc('${tweet.id}_$userId').delete();
    } catch (e) {
      print("Error unretweeting tweet: $e");
    }
  }

  static void addActivity(
      String currentUserId, Tweet tweet, bool follow, String? followedUserId) {
    if (followedUserId != null) {
      activitiesRef.doc(followedUserId).collection('userActivities').add({
        'fromUserId': currentUserId,
        'timestamp': Timestamp.fromDate(DateTime.now()),
        "follow": true,
      });
    } else {
      //like
      activitiesRef.doc(tweet.authorId).collection('userActivities').add({
        'fromUserId': currentUserId,
        'timestamp': Timestamp.fromDate(DateTime.now()),
        "follow": false,
      });
    }
  }

  static Future<String> createChatRoom(String currentUserId, String visitedUserId) async {
    String chatRoomId = getChatRoomId(currentUserId, visitedUserId);

    // Kiểm tra xem chat room đã tồn tại hay chưa
    DocumentSnapshot chatRoom = await FirebaseFirestore.instance.collection('chatRooms').doc(chatRoomId).get();
    if (!chatRoom.exists) {
      await FirebaseFirestore.instance.collection('chatRooms').doc(chatRoomId).set({
        'users': [currentUserId, visitedUserId],
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
    return chatRoomId;
  }

  static String getChatRoomId(String userId1, String userId2) {
    return userId1.compareTo(userId2) <= 0 ? '$userId1\_$userId2' : '$userId2\_$userId1';
  }

  static Stream<List<Map<String, dynamic>>> getMessages(String chatRoomId) {
    return FirebaseFirestore.instance
        .collection('chatRooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList());
  }

  static Future<void> sendMessage(String chatRoomId, Map<String, dynamic> messageData) async {
    await FirebaseFirestore.instance
        .collection('chatRooms')
        .doc(chatRoomId)
        .collection('messages')
        .add(messageData);
  }

}
