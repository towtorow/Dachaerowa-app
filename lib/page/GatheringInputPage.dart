import 'dart:convert';

import 'package:dachaerowa/config/Config.dart';
import 'package:dachaerowa/page/MainPage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:remedi_kopo/remedi_kopo.dart';

class GatheringInputPage extends StatefulWidget {
  const GatheringInputPage({Key? key}) : super(key: key);

  @override
  _GatheringInputPageState createState() => _GatheringInputPageState();
}

class _GatheringInputPageState extends State<GatheringInputPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _locationDetailController = TextEditingController();
  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();
  final TextEditingController _startDateController = TextEditingController();
  final TextEditingController _endDateController = TextEditingController();
  List<File> _images = [];
  DateTime? _selectedStartDate;
  DateTime? _selectedEndDate;
  TimeOfDay? _selectedStartTime;
  TimeOfDay? _selectedEndTime;
  String? _location;
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _locationDetailController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  void _showConfirmationDialog(BuildContext context, File image) {
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
                  _images.remove(image);
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
      String location = "${_locationController.text} ${_locationDetailController.text}";
      DateTime? startDate = _selectedStartDate;
      DateTime? endDate = _selectedEndDate;
      TimeOfDay? startTime = _selectedStartTime;
      TimeOfDay? endTime = _selectedEndTime;
      DateTime _selectedStartDateTime = DateTime(
        startDate!.year,
        startDate.month,
        startDate.day,
        startTime!.hour,
        startTime.minute
      );

      DateTime _selectedEndDateTime = DateTime(
          endDate!.year,
          endDate.month,
          endDate.day,
          endTime!.hour,
          endTime.minute
      );

      final prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('jwt');

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('http://${Config.apiBaseUrl}/api/gatherings/create'),
      );
      print(token);
      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Content-Type': 'multipart/form-data; charset=UTF-8',
      });

      request.fields['title'] = title;
      request.fields['description'] = description;
      request.fields['location'] = location;
      request.fields['startDateTime'] = _selectedStartDateTime.toIso8601String();
      request.fields['endDateTime'] = _selectedEndDateTime.toIso8601String();

      for (var image in _images) {
        request.files.add(
          await http.MultipartFile.fromPath('images', image.path),
        );
      }

      var response = await request.send();
      final bodyBytes = await response.stream.toBytes();
      final bodyString = utf8.decode(bodyBytes);
      setState(() {
        _isLoading = false;
      });
      if (response.statusCode == 201) {



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
          SnackBar(content: Text("서버 장애")),
        );
      }

    }

  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _images.add(File(pickedFile.path));
      });
    }
  }

  Future<void> _selectTime(BuildContext context, bool isStart) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _selectedStartTime = picked;
          _startTimeController.text = picked.format(context);
        } else {
          _selectedEndTime = picked;
          _endTimeController.text = picked.format(context);
        }
      });
    }
  }

  Future<void> _selectDate(BuildContext context, bool isStart) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),

    );
    if (picked != null) {
      setState(() {
        if (isStart) {
          _selectedStartDate = picked;
          _startDateController.text = "${picked.toLocal()}".split(' ')[0];
        } else {
          _selectedEndDate = picked;
          _endDateController.text = "${picked.toLocal()}".split(' ')[0];
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('모임 만들기'),
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
                '만들기',
                style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
              ),
            ),
        ],
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
                _images.isNotEmpty
                      ? Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: _images.map((image) {
                      return GestureDetector(
                          onTap: () {
                            _showConfirmationDialog(context, image);

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
                    }).toList(),
                  )
                    : Container(),
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

              GestureDetector(
                onTap: () async {

                  KopoModel? model = await Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (context) => RemediKopo(),
                    ),
                  );
                  if (model != null) {


                    _locationController.text = '[${model.zonecode}] ${model.address} ${model.buildingName}';



                  }

                },
                child: Row(
                  children: [
                    Icon(Icons.location_on, color: Colors.grey[700]),
                    SizedBox(width: 8),
                    Text(
                      '모임 장소 입력',
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                  ],
                ),
              ),
              // 위치 추가 섹션

              SizedBox(height: 8),

              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(
                  hintText: '주소',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '모임 장소를 입력해주세요.';
                  }
                  return null;
                },
                readOnly: true,
              ),

              SizedBox(height: 8),

              TextFormField(
                controller: _locationDetailController,
                decoration: InputDecoration(
                  hintText: '주소 상세',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
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

                    SizedBox(height: 16),
                    TextFormField(
                      controller: _startDateController,
                      decoration: InputDecoration(
                        icon: Icon(Icons.calendar_today),
                        labelText: "시작 날짜",
                      ),
                      readOnly: true,
                      onTap: () => _selectDate(context, true),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '시작 날짜를 입력해주세요.';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _startTimeController,
                      decoration: InputDecoration(
                        icon: Icon(Icons.access_time),
                        labelText: "시작 시간",
                      ),
                      readOnly: true,
                      onTap: () => _selectTime(context, true),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '시작 시간을 입력해주세요.';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _endDateController,
                      decoration: InputDecoration(
                        icon: Icon(Icons.calendar_today),
                        labelText: "끝나는 날짜",
                      ),
                      readOnly: true,
                      onTap: () => _selectDate(context, false),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '끝나는 날짜를 입력해주세요.';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: _endTimeController,
                      decoration: InputDecoration(
                        icon: Icon(Icons.access_time),
                        labelText: "끝나는 시간",
                      ),
                      readOnly: true,
                      onTap: () => _selectTime(context, false),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return '끝나는 시간을 입력해주세요.';
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
