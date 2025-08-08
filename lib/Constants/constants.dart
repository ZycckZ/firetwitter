import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';

const Color kTweeterColor = Color(0xff00acee);

final _fireStore = FirebaseFirestore.instance;

final usersRef = _fireStore.collection('users');

final followersRef = _fireStore.collection('followers');

final followingRef = _fireStore.collection('following');

final storageRef = FirebaseStorage.instance.ref();

final tweetsRef = _fireStore.collection('tweets');

final feedRefs = _fireStore.collection('feeds');

final likesRef = _fireStore.collection('likes');

final activitiesRef = _fireStore.collection('activities');

const String likesCollection = 'likes'; // Tên collection trong Firebase Firestore

const String retweetsCollection = 'retweets'; // Tên collection trong Firestore

final FirebaseFirestore _db = FirebaseFirestore.instance;

final chatRoomsRef = FirebaseFirestore.instance.collection('chatRooms');
