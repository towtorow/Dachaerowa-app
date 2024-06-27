import 'package:dachaerowa/config/Config.dart';
import 'package:dachaerowa/page/GatheringDetailPage.dart';
import 'package:dachaerowa/page/GatheringInputPage.dart';
import 'package:dachaerowa/util/CommonUtil.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../model/gathering.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import '../component/InstagramStyleWidget.dart';




class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<MainPage> createState() => _MyAppState();
}

enum Tab {
  irurowa,
  gudiday,
  onedayclass,
}

class _MyAppState extends State<MainPage> {
  var tab = Tab.irurowa;
  var data = [];
  var cardData = [];
  var loadingBar = 0;
  var userImage;
  final ScrollController _scrollController = ScrollController();
  final ScrollController _cardScrollController = ScrollController();
  int _page = 0;
  int _cardPage = 0;
  final int _size = 10;
  final int _cardSize = 5;
  var _dio = Dio();


  Map<String, dynamic> meeting = {
  'title': '크루 정기 모임',
  'dateTime': DateTime(2024, 6, 7, 19, 30),
  'description': '이요셉',
  };

  getData() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwt');
    final response = await _dio.get('http://${Config.apiBaseUrl}/api/gatherings/get', queryParameters: {
      'page': _page.toString(),
      'size': _size.toString(),
    },
      options: Options(
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    ),);
    setState(() {
      data.addAll(response.data["content"]);
      _page++;
    });


  }

  void getCardData() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwt');
    final response = await _dio.get('http://${Config.apiBaseUrl}/api/gatherings/todo/get', queryParameters: {
      'page': _cardPage.toString(),
      'size': _cardSize.toString(),
    },
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ),);
    setState(() {
      cardData.addAll(response.data["content"]);
      _cardPage++;
    });


  }


  @override
  void initState() {
    super.initState();
    getCardData();
    getData();
    _scrollController.addListener(_scrollListener);
    _cardScrollController.addListener(_cardScrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollListener () async {
    if(_scrollController.position.pixels == _scrollController.position.maxScrollExtent){
      getData();
    }
  }

  void _cardScrollListener () async {
    if(_cardScrollController.position.pixels == _cardScrollController.position.maxScrollExtent){
      getCardData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('다채로와'),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.purple, Colors.pink],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        actions: [IconButton(
          icon: Icon(Icons.search),
          onPressed:  () {
            showAlertDialog(context);
          },
        ),
          IconButton(
            icon: Icon(Icons.notifications_none),
            onPressed:  ()  {
              showAlertDialog(context);
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(50.0),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(

              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Expanded(
                    child: TextButton(
                      onPressed: () {

                        setState(() {
                          tab = [Tab.irurowa, Tab.gudiday, Tab.onedayclass][0];
                        });
                        print('Button 1 Pressed');
                      },
                      child: Text('이루로와'),
                )),

                Expanded(
                  child:
                  TextButton(
                    onPressed: () {

                      setState(() {
                        tab = [Tab.irurowa, Tab.gudiday, Tab.onedayclass][1];
                      });
                      print('Button 2 Pressed');
                    },
                    child: Text('구디데이'),
                )),
                Expanded(
                child:
                  TextButton(
                    onPressed: () {

                      setState(() {
                        tab = [Tab.irurowa, Tab.gudiday, Tab.onedayclass][2];
                      });
                      print('Button 3 Pressed');
                    },
                    child: Text('원데이클래스'),
                  )),
              ],
            ),
          ),
        ),
      ),
      body:
      Column(
          mainAxisAlignment: MainAxisAlignment.start,
        children : <Widget>[
          Container(
            child: [
      Container(
        height: 200, // Adjust the height as needed
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          controller: _cardScrollController,
          itemCount: cardData.length,
          itemBuilder: (context, index) {
            final meeting = cardData[index];
            return GestureDetector(
                onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      GatheringDetailPage(
                          gatheringId: cardData[index]['id']),
                ),
              );
            },
            child:  Card(
              margin: EdgeInsets.all(10.0),
              child: SizedBox(
                width: 500,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center, // 수직 중앙 정렬
                    crossAxisAlignment: CrossAxisAlignment.center, // 수평 중앙 정렬
                    children: <Widget>[
                      Text(
                        meeting['title'],
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      Text(
                        '${CommonUtil.formatIsoTimeString(meeting["startDateTime"])} ~ ${CommonUtil.formatIsoTimeString(meeting["endDateTime"])}',
                        style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                      ),
                      SizedBox(height: 10),
                      Text(
                        meeting['organizer']['username'],
                        style: TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            )
            );
          },
        ),
      )
              , Text(''), Text('')][tab.index]
          ),
          Expanded(child: Center(
            child: [data.isNotEmpty ?

            SingleChildScrollView(
                scrollDirection: Axis.horizontal,

                child:

                SizedBox(
                  width: 1000,
                  child: ListView.builder (

                                padding: const EdgeInsets.all(8.0),
                                controller: _scrollController,
                                itemCount: data.length,
                                itemBuilder: (BuildContext context, int index) {
                                  return GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              GatheringDetailPage(
                                                  gatheringId: data[index]['id']),
                                        ),
                                      );
                                    },
                                    child: InstagramStyleWidget(
                                      id: data[index]['id'],
                                      imageUrl: data[index]['imageUrl'] ?? '',
                                      title: data[index]['title'],
                                      description: data[index]['description'],
                                      category: data[index]['category'],
                                      location: data[index]['location'] ?? '',
                                      startDateTime: DateTime.parse(
                                          data[index]['startDateTime']),
                                      endDateTime: DateTime.parse(
                                          data[index]['endDateTime']),
                                    ),
                                  );
                                }
                )
          )
            )
           : Text('데이터가 없습니다.'), Text('서비스 준비중입니다.'), Text('서비스 준비중입니다')][tab.index],
          ),
          )
        ]

      ),
      bottomNavigationBar: BottomNavigationBar(
        showUnselectedLabels: false,
        showSelectedLabels: false,
        onTap: (i){
        },
        items: [
          BottomNavigationBarItem(
            label: '홈',
            icon: Icon(Icons.home_outlined),
          ),
          BottomNavigationBarItem(
              label: '내모임',
              icon: Icon(Icons.event)
          ),
          BottomNavigationBarItem(
              label: '프로필',
              icon: Icon(Icons.person)
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: '모임 추가',
        onPressed: () async{
    

          Navigator.push(context, MaterialPageRoute(builder: (c) => GatheringInputPage()));
        },
        tooltip: '모임 추가', // 버튼을 길게 눌렀을 때 나타나는 텍스트
        child: Icon(Icons.add), // 버튼 안에 표시될 아이콘
      ),
    );
  }

  void showAlertDialog(BuildContext context) {
    // set up the buttons
    Widget confirmButton = TextButton(
      child: Text("확인"),
      onPressed:  () {
        Navigator.of(context).pop();
      },
    );


    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      title: Text("서비스 준비중입니다."),
      actions: [
        confirmButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

}

