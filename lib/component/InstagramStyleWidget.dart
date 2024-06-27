import 'package:cached_network_image/cached_network_image.dart';
import 'package:dachaerowa/component/BadgeWidget.dart';
import 'package:flutter/material.dart';
import '../theme/style.dart' as style;
import '../model/gathering.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import 'package:validators/validators.dart' as validators;
class InstagramStyleWidget extends StatelessWidget {
  final int id;
  final String imageUrl;
  final String title;
  final String description;
  final String category;
  final String location;
  final DateTime startDateTime;
  final DateTime endDateTime;

  InstagramStyleWidget({Key? key,
    required this.id,
    required this.imageUrl,
    required this.title,
    required this.description,
    required this.category,
    required this.location,
    required this.startDateTime,
    required this.endDateTime,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isValidUrl = imageUrl != null ? validators.isURL(imageUrl) : false;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: <Widget>[
        ClipRRect(

          borderRadius: BorderRadius.circular(20.0),
          child: isValidUrl? CachedNetworkImage(
            imageUrl : imageUrl,
            placeholder: (context, url) => CircularProgressIndicator(),
            width: 90,
            height: 90,
            fit: BoxFit.cover,
            errorWidget: (context, url, error) =>
             Icon(
                Icons.photo,
                size: 90,
                color: Colors.grey,
              ),

          ) : Icon(
            Icons.photo,
            size: 90,
            color: Colors.grey,
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 8.0, top: 8.0, bottom: 4.0),
              child : Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),


            Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 8.0),
              child: BadgeWidget(text: location,),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 8.0, right: 8.0, bottom: 8.0, top: 4.0),
              child: Text(
                "${startDateTime.toString().substring(0, 16)} ~ ${endDateTime.toString().substring(0, 16)}",
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ),
          ],
        )
        ],
    );
  }
  
}

