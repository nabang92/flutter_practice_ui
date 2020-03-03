import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_practice_ui/widget/flutter_tts.dart';
import 'package:flutter_practice_ui/widget/mic_stream.dart';
import 'package:flutter_practice_ui/widget/preview_page.dart';
import 'package:uni_links/uni_links.dart';

import 'package:flutter/services.dart' show PlatformException;
import 'package:http/http.dart' as http;
import 'model/userprac.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI 영어듣기/말하기연습',
      theme: ThemeData(
        primaryColor: Color(0xff7a63ba),
      ),
      home: PracticePage(),
    );
  }
}

class PracticePage extends StatefulWidget {
  @override
  _PracticePageState createState() => _PracticePageState();
}

class _PracticePageState extends State<PracticePage> {
  int _selectedIndex = 0;
  Uri initialUri;
  String page, memID, conCD, spBookCD, spPracIDX;

  @override
  void initState() {
    super.initState();
    initUniUri();
  }

  Future initUniUri() async {
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      initialUri = await getInitialUri();
      // Parse the link and warn the user, if it is not correct,
      // but keep in mind it could be `null`.
      print('initial uri: $initialUri');
      if (initialUri != null) {
        //deep link 로 넘어온 값을 저장
        //userPrac = UserPrac();
        //userPrac = UserPrac(page: page, memId: memID, conCd: conCD);
        //userPracToJson(userPrac);
        setState(() {
          userPrac.page = initialUri.queryParameters['page'];
          userPrac.memId = initialUri.queryParameters['mem_id'];
          userPrac.conCd = initialUri.queryParameters['con_cd'];
          // 학생의 진도찾기
          getPreviewExam();
        });
      }
    } on PlatformException {
      // Handle exception by warning the user their action did not succeed
      // return?
    }
  }

  Future getPreviewExam() async {
    final response = await http.get(
        'http://easytalk.co.kr/api/flutter/practice_prc.asp?Kind=Practice&page=${userPrac.page}&mem_id=${userPrac.memId}&con_cd=${userPrac.conCd}');
    //print(response.body);
    if (response.statusCode == 200) {
      setState(() {
        // preview_page 에 넘겨야함????
        userPrac.spBookCd = jsonDecode(response.body)['spBookCD'];
        userPrac.spPracIdx = jsonDecode(response.body)['spPracIDX'];
        //userPrac = UserPrac(page: userPrac.page, memId: userPrac.memId, conCd: userPrac.conCd, spBookCd: spBookCD, spPracIdx: spPracIDX);
        userPrac.getspBookCd = jsonDecode(response.body)['spBookCD'];
        print(userPrac.page);
        print(userPrac.memId);
        print(userPrac.conCd);
        print(userPrac.spBookCd);
        print(userPrac.spPracIdx);
        print(userPrac.toJson());
      });
    } else {
      throw Exception('Failed to load data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("AI 영어듣기/말하기연습"),
      ),
      body: Center(
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.remove_red_eye),
            title: Text('Preview'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.replay),
            title: Text('Review'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.record_voice_over),
            title: Text('STT'),
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  List<Widget> _widgetOptions = <Widget>[
    PreviewPage(userPrac: userPrac.toJson(),),
    FlutterTtsPage(),
    MicStreamPage(),
  ];
}