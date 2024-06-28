import 'dart:convert';


import 'package:dachaerowa/component/BadgeWidget.dart';
import 'package:dachaerowa/page/GatheringUpdatePage.dart';
import 'package:flutter/material.dart';
import 'package:dachaerowa/config/Config.dart';
import 'package:dachaerowa/page/PhotoDetailPage.dart';
import 'package:dachaerowa/util/CommonUtil.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';



class GatheringDetailPage extends StatefulWidget {
  final int gatheringId;
  GatheringDetailPage({Key? key, required this.gatheringId}) : super(key: key);

  @override
  _GatheringDetailPageState createState() => _GatheringDetailPageState();
}



class _GatheringDetailPageState extends State<GatheringDetailPage> {


  final _dio = Dio();
  var gatheringData = null;
  var gatheringDetailsData = null;
  var participantsData = [];
  int _counter = 0;
  String? username = '';

  @override
  void initState() {
    super.initState();
    getData(widget.gatheringId);
    getParticipants(widget.gatheringId);
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
      username = prefs.getString('username');
    });
  }
  getParticipants(int gatheringId) async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwt');
    final response = await _dio.get('http://${Config.apiBaseUrl}/api/gatheringDetails/participants/get', queryParameters: {
      'gatheringId': gatheringId.toString(),
    },
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ),);

    setState(() {
      participantsData = response.data;
    });

  }

  _join() async{
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwt');
    try {
      final response = await _dio.get(
        'http://${Config.apiBaseUrl}/api/gatheringDetails/participant/save', queryParameters: {
        'gatheringId': widget.gatheringId.toString(),
      },
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json',
          },
        ),);
      if(response.statusCode == 201){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("참여 성공")),
        );
        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation1, animation2) => GatheringDetailPage(gatheringId:widget.gatheringId),
            transitionDuration: Duration.zero,
            reverseTransitionDuration: Duration.zero,
          ),
        );
      }

    }on DioError catch (e) {
      if (e.response != null) {
        if(e.response!.statusCode == 409){
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("이미 참여했습니다.")),
          );
        }else{
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("서버 장애")),
          );
        }
      }else{
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("서버 장애")),
        );
      }

    }



  }
  @override
  Widget build(BuildContext context) {
    if (gatheringData == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Loading...'),
        ),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: Text(gatheringData["title"]),
      ),
      body: SingleChildScrollView(
        child: Column(

          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(8),
              color: Colors.white,
              height: 300, // 원하는 높이로 설정
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 4.0,
                  mainAxisSpacing: 4.0,
                ),
                itemCount: gatheringDetailsData.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PhotoDetailPage(
                            imageUrls: gatheringDetailsData,
                            initialIndex: index,
                          ),
                        ),
                      );
                    },
                      child:ClipRRect(

                  borderRadius: BorderRadius.circular(10.0),
                  child: CachedNetworkImage(
                      imageUrl: gatheringDetailsData[index]['imageUrl'],
                      placeholder: (context, url) => CircularProgressIndicator(),
                      errorWidget: (context, url, error) => Icon(
                        Icons.photo,
                        size: 250,
                        color: Colors.grey,
                      ),
                      width: double.infinity,
                      height: 300,
                      fit: BoxFit.cover,
                    ),
                  ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    gatheringData["title"],
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),

                  Text(
                    gatheringData["description"],
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 20),
                  Row(
                    children: [
                      Icon(Icons.schedule),
                      SizedBox(width: 5),
                      Text(
                        '${CommonUtil.formatIsoTimeString(gatheringData["startDateTime"])} ~ ${CommonUtil.formatIsoTimeString(gatheringData["endDateTime"])}',
                        style: TextStyle(fontSize: 14, color: Colors.grey),
                      ),
                    ],
                  ),

                  SizedBox(height: 20),
                  Row(
                    children: [
                      Icon(Icons.location_on),
                      SizedBox(width: 5),
                      Text(
                        gatheringData["location"],
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  Column(
                    children: [
                      Row(
                      children: [
                        Icon(Icons.person),
                        SizedBox(width: 5),
                        Text(
                          '호스트: ${gatheringData["organizer"] != null ? gatheringData["organizer"]["username"] : ''}',
                          style: TextStyle(fontSize: 14),
                        ),

                        ],
                      ),


                      SizedBox(height: 20),
                      Row(
                        children: [
                          Icon(Icons.person),
                          SizedBox(width: 5),
                          Text(
                            '참여자',
                            style: TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                      SingleChildScrollView(
                        padding: EdgeInsets.only(top: 10),
                        child: Column(
                          children: [
                            Container(
                              padding: EdgeInsets.only(left: 20.0),
                              height: 25,
                              child: participantsData.isNotEmpty? ListView.builder(
                                scrollDirection: Axis.horizontal,

                            itemBuilder: (context, index){
                              return Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 2.0), // 각 BadgeWidget에 수평 패딩 추가
                                child: BadgeWidget(text: participantsData[index] ?? ''),
                              );
                        },
                        itemCount: participantsData.length,

                              ): Text('')
                            )
                        ],
                            )
                      ),
                    ]
                  )
          ]
            ),
              ),

            Column(
                mainAxisAlignment: MainAxisAlignment.end, // Column의 주축 정렬을 하단으로 설정
                children: [
            Padding(
            padding: const EdgeInsets.all(16.0), // Padding을 사용하여 버튼 주위에 여백을 추가
            child:
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child:
                  ElevatedButton(

                    onPressed: participantsData.contains(username) ? null : _join,
                    child: Text('참여하기', style: TextStyle(color: Colors.white),),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      minimumSize: Size(double.maxFinite, 50),

                    ),

                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child:
                  ElevatedButton(

                onPressed:gatheringData["organizer"]==null ? null : gatheringData["organizer"]["username"] != username ? null :  (){

                  Navigator.push(context, MaterialPageRoute(builder: (c) => GatheringUpdatePage(gatheringId:widget.gatheringId)));
                },




                    child: Text('수정하기', style: TextStyle(color: Colors.white),),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.redAccent,
                      minimumSize: Size(double.maxFinite, 50),

                    ),

                  )
                ),
              ],
            ),

            ),
                ],
            )
          ],
        ),

      ),

    );

  }

}
