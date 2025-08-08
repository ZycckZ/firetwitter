import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:firetwitter/Constants/constants.dart';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';


class StorageService {

  static Future<String> uploadProfilePicture(String url, File imageFile) async {
    String uniquePhotoId = Uuid().v4(); // Để là String, không cần nullable
    XFile? image = await compressImage(uniquePhotoId, imageFile);

    if (url.isNotEmpty) {
      RegExp exp = RegExp(r"userProfile_(.*).jpg");
      final match = exp.firstMatch(url);
      if (match != null && match.groupCount > 0) {
        uniquePhotoId = match.group(1)!; // Dùng ! để chỉ định rằng nó không null
      }
    }

    UploadTask uploadTask = storageRef
        .child('images/users/userProfile_$uniquePhotoId.jpg')
        .putFile(image as File);
    TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);
    String downloadUrl = await taskSnapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  static Future<String> uploadCoverPicture(String url, File imageFile) async {
    String uniquePhotoId = Uuid().v4(); // Để là String, không cần nullable
    XFile? image = await compressImage(uniquePhotoId, imageFile);

    if (url.isNotEmpty) {
      RegExp exp = RegExp(r"userCover_(.*).jpg");
      final match = exp.firstMatch(url);
      if (match != null && match.groupCount > 0) {
        uniquePhotoId = match.group(1)!; // Dùng ! để chỉ định rằng nó không null
      }
    }

    UploadTask uploadTask = storageRef
        .child('images/users/userCover_$uniquePhotoId.jpg')
        .putFile(image as File);
    TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);
    String downloadUrl = await taskSnapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  static Future<String> uploadTweetPicture(File imageFile) async {
    String uniquePhotoId = Uuid().v4();
    XFile? image = await compressImage(uniquePhotoId, imageFile); // Nếu cần nén ảnh

    UploadTask uploadTask = storageRef
        .child('images/tweets/tweet_$uniquePhotoId.jpg')
        .putFile(image as File); // Tải lên ảnh

    TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);
    String downloadUrl = await taskSnapshot.ref.getDownloadURL(); // Lấy URL ảnh
    return downloadUrl;
  }

  static Future<XFile?> compressImage(String photoId, File image) async {
    final tempDirection = await getTemporaryDirectory();
    final path = tempDirection.path;
    XFile? compressedImage = await FlutterImageCompress.compressAndGetFile(
      image.absolute.path,
      '$path/img_$photoId.jpg',
      quality: 70,
    );
    return compressedImage;
  }
}
