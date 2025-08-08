import 'package:flutter/material.dart';
import 'package:firetwitter/Constants/constants.dart';
import 'package:firetwitter/Services/auth_service.dart';
import 'package:firetwitter/Widgets/rounded_button.dart';

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  String? _email;
  String? _password;
  String? _name;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kTweeterColor,
        centerTitle: true,
        elevation: 0,
        title: Text(
          'Registration',
          style: TextStyle(
            fontSize: 20,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          children: [
            SizedBox(
              height: 40,
            ),
            TextField(
              decoration: InputDecoration(
                hintText: 'Name:',
              ),
              onChanged: (value) {
                _name=value;
              },
            ),
            SizedBox(
              height: 35,
            ),
            TextField(
              decoration: InputDecoration(
                hintText: 'Email:',
              ),
              onChanged: (value) {
                _email=value;
              },
            ),
            SizedBox(
              height: 40,
            ),
            TextField(
              obscureText: true,
              decoration: InputDecoration(
                hintText: 'Password:',
              ),
              onChanged: (value) {
                _password=value;
              },
            ),
            SizedBox(
              height: 40,
            ),
            RoundedButton(
              btnText: 'CREATE ACCOUNT',
              onBtnPressed: () async{
                bool isValid = await AuthService.signUp(_name!, _email!, _password!);
                if(isValid) {
                  Navigator.pop(context);
                }else {
                  print("Something's wrong!");
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
