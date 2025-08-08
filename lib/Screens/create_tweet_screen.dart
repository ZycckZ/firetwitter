import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firetwitter/Constants/constants.dart';
import 'package:firetwitter/Models/tweet.dart';
import 'package:firetwitter/Services/database_services.dart';
import 'package:firetwitter/Services/storage_service.dart';
import 'package:firetwitter/Widgets/rounded_button.dart';
import 'package:image_picker/image_picker.dart';

class CreateTweetScreen extends StatefulWidget {
  final String? currentUserId; // Thử thêm ?

  const CreateTweetScreen({super.key, required this.currentUserId});

  @override
  State<CreateTweetScreen> createState() => _CreateTweetScreenState();
}

class _CreateTweetScreenState extends State<CreateTweetScreen> {
  String? _tweetText;
  File? _pickedImage;
  bool _loading=false;

  handleImageFromGallery() async{
    try{
      XFile? imageFile = await ImagePicker().pickImage(source: ImageSource.gallery);
      if(imageFile != null) {
        setState(() {
          _pickedImage = File(imageFile.path);
        });
      }
    }catch(e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: kTweeterColor,
        centerTitle: true,
        title: Text(
          'Tweet',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20.0,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0,),
        child: Column(
          children: [
            SizedBox(height: 20.0,),
            TextField(
              maxLength: 280,
              maxLines: 7,
              decoration: InputDecoration(
                hintText: 'Enter your Tweet',
              ),
              onChanged: (value) {
                _tweetText = value;
              },
            ),
            SizedBox(height: 10.0,),
            _pickedImage == null
                ? SizedBox.shrink()
                : Column(
              children: [
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: kTweeterColor,
                    image: DecorationImage(
                        fit: BoxFit.cover,
                        image: FileImage(_pickedImage!)),
                  ),
                ),
                SizedBox(height: 20.0,),
              ],
            ),
            GestureDetector(
              onTap: handleImageFromGallery,
              child: Container(
                height: 70,
                width: 70,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
                  border: Border.all(
                    color: kTweeterColor,
                    width: 2.0,
                  ),
                ),
                child: Icon(
                  Icons.camera_alt,
                  size: 50,
                  color: kTweeterColor,
                ),
              ),
            ),
            SizedBox(height: 20.0,),
            RoundedButton(
              btnText: 'Tweet',
              onBtnPressed: () async{
                setState(() {
                  _loading = true;
                });
                if(_tweetText !=null && _tweetText!.isNotEmpty) {
                  String? image;
                  if(_pickedImage == null) {
                    image = '';
                  } else {
                    image = await StorageService.uploadTweetPicture(_pickedImage!);
                  }
                  // Thêm Tweet vào Firestore
                  Tweet tweet = Tweet(
                    text: _tweetText,
                    image: image,
                    authorId: widget.currentUserId,
                    likes: 0,
                    retweets: 0,
                    timestamp: Timestamp.fromDate(
                      DateTime.now(),
                    ),
                  );
                  DatabaseServices.createTweet(tweet);
                  Navigator.pop(context);
                }
                setState(() {
                  _loading = false;
                });
              },
            ),
            SizedBox(height: 20.0,),
            _loading ? CircularProgressIndicator() : SizedBox.shrink()
          ],
        ),
      ),
    );
  }
}
