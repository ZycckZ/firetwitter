import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String name;
  final String profilePicture;
  final String email;
  final String bio;
  final String coverImage;

  UserModel({
    required this.id,
    required this.name,
    this.profilePicture = 'https://example.com/default_profile_image.png',
    required this.email,
    this.bio = '',
    this.coverImage = '',
  });

  factory UserModel.fromDocument(DocumentSnapshot doc) {

    return UserModel(
      id: doc.id,
      name: doc['name'] ?? 'Anonymous',
      profilePicture: doc['profilePicture'] ?? 'https://example.com/default_profile_image.png',
      bio: doc['bio'] ?? '',
      coverImage: doc['coverImage'] ?? '',
      email: doc['email'] ?? 'No email provided',
    );
  }
}