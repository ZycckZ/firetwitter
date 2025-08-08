import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firetwitter/Constants/constants.dart';
import 'package:firetwitter/Models/user_model.dart';
import 'package:firetwitter/Services/database_services.dart';
import 'package:firetwitter/Services/storage_service.dart';
import 'package:image_picker/image_picker.dart';

class EditProfileScreen extends StatefulWidget {
  final UserModel user;

  const EditProfileScreen({super.key, required this.user});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {

  String? _name;
  String? _bio;
  File? _profileImage;
  File? _coverImage;
  String? _imagePickedType;
  final _formKey=GlobalKey<FormState>();
  bool _isLoading=false;

  displayCoverImage() {
    if (_coverImage == null) {
      if (widget.user.coverImage.isNotEmpty) {
        return NetworkImage(widget.user.coverImage);
      }
    } else {
      return FileImage(_coverImage!);
    }
    return AssetImage('assets/placeholder.png'); // Ảnh mặc định nếu không có ảnh
  }

  displayProfileImage() {
    if (_profileImage == null) {
      if (widget.user.profilePicture.isNotEmpty) {
        return NetworkImage(widget.user.profilePicture);
      }
    } else {
      return FileImage(_profileImage!);
    }
    return AssetImage('assets/placeholder.png'); // Ảnh mặc định nếu không có ảnh
  }


  saveProfile() async {
    _formKey.currentState?.save();
    if (_formKey.currentState!.validate() && !_isLoading) {
      setState(() {
        _isLoading = true;
      });

      String profilePictureUrl = '';
      String coverPictureUrl = '';

      if (_profileImage == null) {
        profilePictureUrl = widget.user.profilePicture;
      } else {
        profilePictureUrl = await StorageService.uploadProfilePicture(
          widget.user.profilePicture,
          _profileImage!,
        );
      }

      if (_coverImage == null) {
        coverPictureUrl = widget.user.coverImage;
      } else {
        coverPictureUrl = await StorageService.uploadCoverPicture(
          widget.user.coverImage,
          _coverImage!,
        );
      }

      UserModel user = UserModel(
        id: widget.user.id,
        name: _name ?? widget.user.name, // Dùng tên mặc định nếu không nhập
        profilePicture: profilePictureUrl,
        bio: _bio ?? widget.user.bio, // Dùng bio mặc định nếu không nhập
        coverImage: coverPictureUrl,
        email: widget.user.email, // Giữ nguyên email
      );

      await DatabaseServices.updateUserData(user);
      Navigator.pop(context);
    }
  }


  Future<void> handleImageFromGallery() async {
    try {
      final ImagePicker picker = ImagePicker(); // Tạo thể hiện của ImagePicker
      final XFile? imageFile = await picker.pickImage(source: ImageSource.gallery); // Sử dụng pickImage

      if (imageFile != null) {
        if (_imagePickedType == 'profile') {
          setState(() {
            _profileImage = File(imageFile.path); // Chuyển đổi XFile sang File
          });
        } else if (_imagePickedType == 'cover') {
          setState(() {
            _coverImage = File(imageFile.path); // Chuyển đổi XFile sang File
          });
        }
      }
    } catch (e) {
      print(e); // In ra lỗi nếu có
    }
  }

  @override
  void initState() {
    super.initState();
    _name = widget.user.name;
    _bio = widget.user.bio;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics()
        ),
        children: [
          GestureDetector(
            onTap: () {
              _imagePickedType = 'cover';
              handleImageFromGallery();
            },
            child: Stack(
              children: [
                Container(
                  height: 150,
                  decoration: BoxDecoration(
                    color: kTweeterColor,
                    image: (_coverImage == null && (widget.user.coverImage.isEmpty || widget.user.coverImage == null))
                        ? null
                        : DecorationImage(
                      fit: BoxFit.cover,
                      image: displayCoverImage(),
                    ),
                  ),
                ),
                Container(
                  height: 150.0,
                  color: Colors.black54,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.camera_alt,
                        size: 70,
                        color: Colors.white,
                      ),
                      Text(
                        'Change Cover Photo',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Container(
            transform: Matrix4.translationValues(0.0, -40.0, 0),
            padding: EdgeInsets.symmetric(horizontal: 20.0,),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    GestureDetector(
                      onTap: () {
                        _imagePickedType='profile';
                        handleImageFromGallery();
                      },
                      child: Stack(
                        children: [
                          CircleAvatar(
                            radius: 45.0,
                            backgroundImage: displayProfileImage(),
                          ),
                          CircleAvatar(
                            radius: 45.0,
                            backgroundColor: Colors.black54,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Icon(
                                  Icons.camera_alt,
                                  size: 30,
                                  color: Colors.white,
                                ),
                                Text(
                                  'Change Profile Photo',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: saveProfile,
                      child: Container(
                        width: 100.0,
                        height: 35.0,
                        padding: EdgeInsets.symmetric(horizontal: 10.0,),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: kTweeterColor,
                        ),
                        child: Center(
                          child: Text(
                            'Save',
                            style: TextStyle(
                              fontSize: 18.0,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      SizedBox(height: 30.0,),
                      TextFormField(
                        initialValue: _name,
                        decoration: InputDecoration(
                          labelText: 'Name',
                          labelStyle: TextStyle(color: kTweeterColor),
                        ),
                        validator: (input)=>input!.trim().length<2?
                        'please enter valid name'
                            :null,
                        onSaved: (value) {
                          _name=value;
                        },
                      ),
                      SizedBox(height: 30.0,),
                      TextFormField(
                        initialValue: _bio,
                        decoration: InputDecoration(
                          labelText: 'Bio',
                          labelStyle: TextStyle(color: kTweeterColor),
                        ),
                        onSaved: (value) {
                          _bio=value;
                        },
                      ),
                      SizedBox(height: 30.0,),
                      _isLoading?
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(kTweeterColor),
                      )
                          :SizedBox.shrink(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
