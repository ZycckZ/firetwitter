import 'package:flutter/material.dart';
import 'package:firetwitter/Constants/constants.dart';

class RoundedButton extends StatelessWidget {
  final String btnText;
  final VoidCallback onBtnPressed;

  const RoundedButton({super.key, required this.btnText, required this.onBtnPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 5,
      color: kTweeterColor,
      borderRadius: BorderRadius.circular(30),
      child: MaterialButton(
        onPressed: onBtnPressed,
        minWidth: 250,
        height: 60,
        child: Text(
          btnText,
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
          ),
        ),
      ),
    );
  }
}