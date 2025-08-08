import 'package:flutter/material.dart';
import 'package:firetwitter/Screens/registration_screen.dart';
import 'package:firetwitter/Widgets/rounded_button.dart';
import 'login_screen.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width,
                  ),
                  Image.asset(
                    'assets/logo.png',
                    height: 200,
                    width: 200,
                  ),
                  Text(
                    "See what's happening in the world right now.",
                    style: TextStyle(
                      fontSize: 30.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Column(
                children: [
                  RoundedButton(
                      btnText: 'Log in',
                      onBtnPressed: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => LoginScreen()
                            ));
                      }
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  RoundedButton(btnText: 'Create account',
                    onBtnPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => RegistrationScreen()
                          ));
                    },
                  )
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}