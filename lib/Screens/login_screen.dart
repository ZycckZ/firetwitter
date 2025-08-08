import 'package:flutter/material.dart';
import 'package:firetwitter/Constants/constants.dart';
import 'package:firetwitter/Services/auth_service.dart';
import 'package:firetwitter/Widgets/rounded_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String? _email;
  String? _password;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kTweeterColor,
        centerTitle: true,
        elevation: 0,
        title: Text(
          'Log in',
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
                hintText: 'Enter your email:',
              ),
              onChanged: (value) {
                _email=value;
              },
            ),
            SizedBox(
              height: 35,
            ),
            TextField(
              obscureText: true,
              decoration: InputDecoration(
                hintText: 'Enter your password:',
              ),
              onChanged: (value) {
                _password=value;
              },
            ),
            SizedBox(
              height: 40,
            ),
            RoundedButton(
              btnText: 'LOG IN',
              onBtnPressed: () async{
                bool isValid = await AuthService.logIn(_email!, _password!);
                if(isValid) {
                  Navigator.pop(context);
                }else {
                  print("Log in problem!");
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
