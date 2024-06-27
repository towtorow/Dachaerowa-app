import 'dart:collection';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dachaerowa/config/Config.dart';
import 'package:dachaerowa/page/MainPage.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:remedi_kopo/remedi_kopo.dart';

class GatheringUpdatePage extends StatefulWidget {
  final int gatheringId;
  const GatheringUpdatePage({Key? key, required this.gatheringId}) : super(key: key);

  @override
  _GatheringUpdatePageState createState() => _GatheringUpdatePageState();
}

class _GatheringUpdatePageState extends State<GatheringUpdatePage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;
  TimeOfDay? _selectedStartTime;
  TimeOfDay? _selectedEndTime;
  String? _location;
  bool _isLoading = false;
  final _dio = Dio();
  var gatheringData = null;
  var gatheringDetailsData = [];
  var addImages = [];
  List<String> deleteImageIds = [];
  @override
  void initState() {
    super.initState();
    getData(widget.gatheringId);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }




  void _delete() async{




      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('jwt');

      final response = await http.post(

        Uri.parse('http://${Config.apiBaseUrl}/api/gatherings/delete'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(<String, String>{
          'gatheringId': widget.gatheringId.toString(),

        }),
      );


    if (response.statusCode == 200) {


        ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("삭제 성공")),
        );

        Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => MainPage()), (Route<dynamic> route) => false,
        );

      } else{

      var decoded = utf8.decode(response.bodyBytes);
      var body = jsonDecode(decoded);
      ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(body["message"])),
      );
    }

  }

  getData(int gatheringId) async {
    final prefs = await SharedPreferences.getInstance();

    String? token = prefs.getString('jwt');
    final response = await _dio.get(
      'http://${Config.apiBaseUrl}/api/gatheringDetails/get', queryParameters: {
      'gatheringId': gatheringId.toString(),
    },
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ),);

    setState(() {
      gatheringData = response.data["gathering"];
      gatheringDetailsData = response.data["gatheringDetails"];

      _titleController.text = gatheringData["title"];
      _descriptionController.text  = gatheringData["description"];
    });
  }


  void _showConfirmationDialog(BuildContext context, var param, var type) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('이미지 삭제'),
          content: Text('이미지를 삭제하시겠습니까?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('취소'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  if(type == 'SAVED_IMAGE'){

                    gatheringDetailsData = gatheringDetailsData.where((item) => item['id'] != param).toList();
                    deleteImageIds.add(param.toString());
                  }else if(type == 'ADDED_IMAGE'){
                    addImages.remove(param);
                  }

                });
              },
              child: Text('확인'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _submit() async {

    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      String title = _titleController.text;
      String description = _descriptionController.text;


      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('jwt');





      Dio dio = Dio();
      dio.options.headers['Authorization'] = 'Bearer $token';

      List<MultipartFile> imageFiles = [];
      for (var image in addImages) {
        imageFiles.add(await MultipartFile.fromFile(image.path, filename: image.path.split('/').last));
      }

      FormData formData = FormData.fromMap({
        'gatheringId': widget.gatheringId.toString(),
        'title': title,
        'description': description,
        'deleteImageIds': deleteImageIds,
        'images': imageFiles
      });


        var response = await dio.post(
          'http://${Config.apiBaseUrl}/api/gatherings/update',
          data: formData,
        );



      setState(() {
        _isLoading = false;
      });
      if (response.statusCode == 200) {



        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("저장 성공")),
        );

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => MainPage()), (Route<dynamic> route) => false,
        );

      } else if(response.statusCode == 413){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("데이터 용량이 너무 큽니다 (100MB 초과).")),
        );
      } else{

        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response.data["message"]))
        );
      }
    }

  }
  String convertListToJsonArrayString(List<String> list) {
    String jsonArrayString = '[';
    for (int i = 0; i < list.length; i++) {
      jsonArrayString += "'${list[i]}'";
      if (i < list.length - 1) {
        jsonArrayString += ',';
      }
    }
    jsonArrayString += ']';
    return jsonArrayString;
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        addImages.add(File(pickedFile.path));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('모임 수정하기'),
        actions: [
          if (_isLoading)
              SpinKitFadingCircle(
              color: Colors.blue,
              size: 50.0,
            )
          else

            TextButton(

              onPressed: _submit,
              child: Text(
                '수정하기',
                style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
              ),
            ),
          TextButton(

            onPressed: _delete,
            child: Text(
              '삭제하기',
              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
            ),
          ),],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 10),
              Container(
                width: double.infinity,
                alignment: Alignment.center,
                child:
                gatheringDetailsData.isNotEmpty
                      ? Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children:
                    gatheringDetailsData.map((detail) {
                      return GestureDetector(
                          onTap: () {
                            _showConfirmationDialog(context, detail["id"], 'SAVED_IMAGE');

                      },
                      child:ClipRRect(

                          borderRadius: BorderRadius.circular(10.0),
                      child: CachedNetworkImage(
                        placeholder: (context, url) => CircularProgressIndicator(),
                        errorWidget: (context, url, error) => Icon(
                          Icons.photo,
                          size: 100,
                          color: Colors.grey,
                        ),
                        imageUrl : detail['imageUrl'],
                        width: 98,
                        height: 98,
                        fit: BoxFit.cover,
                      )
                      )
                      );
                    }

                    ).followedBy(
                      addImages.isNotEmpty ?
                      addImages.map((image) {
                        return GestureDetector(
                            onTap: () {
                              _showConfirmationDialog(context, image, 'ADDED_IMAGE');

                            },
                            child:ClipRRect(

                                borderRadius: BorderRadius.circular(10.0),
                                child: Image.file(
                                  image,
                                  width: 98,
                                  height: 98,
                                  fit: BoxFit.cover,
                                )
                            )
                        );
                      }

                      ) : [],

                    ).toList()
                ) : Container(),
              ),

              SizedBox(height: 10),
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: double.infinity,
                  height: 80,
                  color: Colors.grey[300],
                  child: Icon(Icons.add_a_photo, size: 50, color: Colors.grey[700]),
                ),
              ),


              SizedBox(height: 16),
              Form(
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        hintText: '제목',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '제목을 입력해주세요.';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: InputDecoration(
                        hintText: '설명',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                      ),
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '설명을 입력해주세요.';
                        }
                        return null;
                      },
                    ),

                  ],

                ),

            ),
          ],
        ),
      ),
    ),
    );
  }










}
