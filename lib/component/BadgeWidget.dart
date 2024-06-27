

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

class BadgeWidget extends StatelessWidget {
  final String text;
  final Color backgroundColor;
  final Color textColor;

  const BadgeWidget({
    Key? key,
    required this.text,
    this.backgroundColor = Colors.blue,
    this.textColor = Colors.white,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(

      height: 25,
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
          text,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
          ),
        ),

    );
  }
}