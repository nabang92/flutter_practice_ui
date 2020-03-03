import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_practice_ui/model/userprac.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;
import 'package:page_indicator/page_indicator.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class PreviewPage extends StatefulWidget {
  Map<String, dynamic> userPrac;
  PreviewPage({this.userPrac});

  @override
  _PreviewPageState createState() => _PreviewPageState();
}

class _PreviewPageState extends State<PreviewPage> {
  int currentPage = 0;
  PageController pageController;
  Future<PreviewExam> futurePreviewExam;

  FlutterTts _flutterTts;
  bool isPlaying = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    pageController = PageController();
    futurePreviewExam = getPreviewExam();
    initializeTts();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    pageController.dispose();
    _flutterTts.stop();
    super.dispose();
  }

  initializeTts() {
    _flutterTts = FlutterTts();

    _flutterTts.setStartHandler(() {
      setState(() {
        isPlaying = true;
      });
    });

    _flutterTts.setCompletionHandler(() {
      setState(() {
        isPlaying = false;
      });
    });

    _flutterTts.setErrorHandler((err) {
      setState(() {
        print("error occurred: " + err);
        isPlaying = false;
      });
    });
  }

  void setTtsLanguage() async {
    await _flutterTts.setLanguage("en-US");
  }

  Future _speak(String text) async {
    if (text != null && text.isNotEmpty) {
      setTtsLanguage();
      var result = await _flutterTts.speak(text);
      if (result == 1)
        setState(() {
          isPlaying = true;
        });
    }
  }

  Future _stop() async {
    var result = await _flutterTts.stop();
    if (result == 1)
      setState(() {
        isPlaying = false;
      });
  }

  Future<PreviewExam> getPreviewExam() async {
    print('http://easytalk.co.kr/api/flutter/practice_prc.asp?Kind=BookInfo&sbook_id=${userPrac.spBookCd}&idx=${userPrac.spPracIdx}');

    final response = await http.get(
        'http://easytalk.co.kr/api/flutter/practice_prc.asp?Kind=BookInfo&sbook_id=127&idx=151');
    print(response.body);
    if (response.statusCode == 200) {
      return PreviewExam.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Text('Preview Practice',
                style: TextStyle(
                    fontSize: 22.0,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF112653))),
          ),
          Divider(),
          Expanded(
            child: FutureBuilder(
              future: futurePreviewExam,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return PageIndicatorContainer(
                    length: 5,
                    padding: const EdgeInsets.only(bottom: 20),
                    indicatorColor: Theme.of(context).secondaryHeaderColor,
                    indicatorSelectorColor: Theme.of(context).primaryColor,
                    shape: IndicatorShape.roundRectangleShape(
                        size: Size.square(12), cornerSize: Size.square(3)),
                    child: PageView(
                      controller: pageController,
                      children: <Widget>[
                        itemPage(1, snapshot.data.days, snapshot.data.bookName,
                            snapshot.data.pv1Ko, snapshot.data.pv1En),
                        itemPage(2, snapshot.data.days, snapshot.data.bookName,
                            snapshot.data.pv2Ko, snapshot.data.pv2En),
                        itemPage(3, snapshot.data.days, snapshot.data.bookName,
                            snapshot.data.pv3Ko, snapshot.data.pv3En),
                        itemPage(4, snapshot.data.days, snapshot.data.bookName,
                            snapshot.data.pv4Ko, snapshot.data.pv4En),
                        itemPage(5, snapshot.data.days, snapshot.data.bookName,
                            snapshot.data.pv5Ko, snapshot.data.pv5En),
                      ],
                    ),
                  );
                } else {
                  return Center(child: CircularProgressIndicator());
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  itemPage(int i, int days, String bookName, String pvKo, String pvEn) {
    return Container(
        child: Column(
          children: <Widget>[
            SizedBox(
              height: 20,
            ),
            Text(
              bookName,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              '${days.toString()}-${i.toString()}',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF22dcd5),
              ),
            ),
            Text(
              'Sentence',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFFa5a5b5),
              ),
            ),
            SizedBox(
              height: 20,
            ),
            Container(
              width: MediaQuery.of(context).size.width * 0.9,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  border: Border.all(width: 0, color: Colors.grey)),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Flexible(
                          child: Text(
                            pvEn ?? '', //값이 있을때만
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF112653)),
                          ),
                        ),
                        pvEn != null //값이 있을때만
                            ? IconButton(
                          onPressed: () {
                            if (isPlaying) {
                              _stop();
                            } else {
                              _speak(pvEn);
                            }
                          },
                          color: Theme.of(context).primaryColor,
                          icon: (isPlaying)
                              ? Icon(Icons.pause_circle_outline)
                              : Icon(Icons.play_circle_outline),
                        )
                            : Container(),
                      ],
                    ),
                    Divider(thickness: 1),
                    Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 8),
                      child: Text(
                        pvKo ?? '', //값이 있을때만
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF112653)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: Container(
                  width: 80.0,
                  height: 80.0,
                  child: FloatingActionButton(
                    onPressed: () {
                      showAlertDialog(pvEn);
                    },
                    child: Icon(Icons.mic, size: 60.0,),
                    backgroundColor: Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ),
          ],
        ));
  }

  void showAlertDialog(String pvEn) async {
    String result = await showDialog(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0)), //this right here
          child: SingleChildScrollView(
            child: Container(
              padding: EdgeInsets.all(10),
              height: 450,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.all(5.0),
                        child: Row(
                          children: <Widget>[
                            Text(
                              'Try agin',
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF112653)),
                            ),
                            Text(
                              '25',
                              style: Theme.of(context).textTheme.caption,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.all(5.0),
                        child: Row(
                          children: <Widget>[
                            Text(
                              pvEn,
                              style: Theme.of(context).textTheme.bodyText2,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.9,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            border:
                            Border.all(width: 0, color: Colors.grey)),
                        child: Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: <Widget>[
                                  Flexible(
                                    child: Text(
                                      'You Said ------',
                                      style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF112653)),
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () {},
                                    color: Theme.of(context).primaryColor,
                                    icon: Icon(Icons.play_circle_outline),
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(0, 15, 0, 15),
                        child: new LinearPercentIndicator(
                          animation: true,
                          animationDuration: 1000,
                          lineHeight: 30.0,
                          percent: 0.2,
                          center: Text("28.0%"),
                          linearStrokeCap: LinearStrokeCap.butt,
                          progressColor: Color(0xFFB388FF),
                        ),
                      ),
                      Container(
                        width: MediaQuery.of(context).size.width * 0.9,
                        // Container에 박스를 그려주는 코드
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            border:
                            Border.all(width: 0, color: Colors.grey)),
                        // linear_percent_indicator 를 이용하여 '퍼센테이지 바'를 그려주는 태그
                        child: Column(
                          children: <Widget>[
                            Padding(
                              padding: EdgeInsets.fromLTRB(10, 8, 10, 8),
                              child: new LinearPercentIndicator(
                                animation: true,
                                animationDuration: 1000,
                                lineHeight: 20.0,
                                percent: 0.18,
                                leading: new Text("발음 평가"),
                                center: Text("18.0%"),
                                linearStrokeCap: LinearStrokeCap.butt,
                                progressColor: Color(0xFFE57373),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.fromLTRB(10, 8, 10, 8),
                              child: new LinearPercentIndicator(
                                animation: true,
                                animationDuration: 1000,
                                lineHeight: 20.0,
                                percent: 0.36,
                                leading: new Text("속도 평가"),
                                center: Text("36.0%"),
                                linearStrokeCap: LinearStrokeCap.butt,
                                progressColor: Color(0xFFFF8A65),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.fromLTRB(10, 8, 10, 8),
                              child: new LinearPercentIndicator(
                                animation: true,
                                animationDuration: 1000,
                                lineHeight: 20.0,
                                percent: 0.28,
                                leading: new Text("리듬 평가"),
                                center: Text("28.0%"),
                                linearStrokeCap: LinearStrokeCap.butt,
                                progressColor: Color(0xFFFBC02D),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.fromLTRB(10, 8, 10, 8),
                              child: new LinearPercentIndicator(
                                animation: true,
                                animationDuration: 1000,
                                lineHeight: 20.0,
                                percent: 0.30,
                                leading: new Text("억양 평가"),
                                center: Text("30.0%"),
                                linearStrokeCap: LinearStrokeCap.butt,
                                progressColor: Color(0xFF80DEEA),
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.fromLTRB(10, 8, 10, 8),
                              child: new LinearPercentIndicator(
                                animation: true,
                                animationDuration: 1000,
                                lineHeight: 20.0,
                                percent: 0.24,
                                leading: new Text("음절 평가"),
                                center: Text("24.0%"),
                                linearStrokeCap: LinearStrokeCap.butt,
                                progressColor: Color(0xFF2962FF),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      Expanded(
                        flex: 1,
                        child: RaisedButton(
                          onPressed: () => Navigator.pop(context),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text('Retry', style: TextStyle(color: Theme.of(context).primaryColor),),
                              Icon(Icons.replay, color: Theme.of(context).primaryColor,),
                            ],
                          ),
                          color: Colors.white,
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: RaisedButton(
                          onPressed: () {
                            pageController.animateToPage(pageController.page.toInt() + 1,duration: Duration(milliseconds: 500),curve: Curves.easeIn);
                            print(pageController.page.toInt());
                            print(pageController.page.round());
                            Navigator.pop(context, "OK");
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Text('Next', style: TextStyle(color: Colors.white),),
                              Icon(Icons.navigate_next,color: Colors.white,),
                            ],
                          ),
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class PreviewExam {
  String bookName;
  int idx;
  int pracIdx;
  int sbookId;
  int days;
  String unitTitle;
  String pagesTitle;
  String topicTitle;
  String functionTitle;
  String grammarTitle;
  String pv1Ko;
  String pv1En;
  String pv2Ko;
  String pv2En;
  String pv3Ko;
  String pv3En;
  String pv4Ko;
  String pv4En;
  String pv5Ko;
  String pv5En;
  String rv1Ko;
  String rv1En;
  String rv2Ko;
  String rv2En;
  String rv3Ko;
  String rv3En;

  PreviewExam({
    this.bookName,
    this.idx,
    this.pracIdx,
    this.sbookId,
    this.days,
    this.unitTitle,
    this.pagesTitle,
    this.topicTitle,
    this.functionTitle,
    this.grammarTitle,
    this.pv1Ko,
    this.pv1En,
    this.pv2Ko,
    this.pv2En,
    this.pv3Ko,
    this.pv3En,
    this.pv4Ko,
    this.pv4En,
    this.pv5Ko,
    this.pv5En,
    this.rv1Ko,
    this.rv1En,
    this.rv2Ko,
    this.rv2En,
    this.rv3Ko,
    this.rv3En,
  });

  factory PreviewExam.fromJson(Map<String, dynamic> json) => PreviewExam(
    bookName: json["book_name"],
    idx: json["idx"],
    pracIdx: json["prac_idx"],
    sbookId: json["sbook_id"],
    days: json["Days"],
    unitTitle: json["Unit_Title"],
    pagesTitle: json["Pages_Title"],
    topicTitle: json["Topic_Title"],
    functionTitle: json["Function_Title"],
    grammarTitle: json["Grammar_Title"],
    pv1Ko: json["Pv1_ko"],
    pv1En: json["Pv1_en"],
    pv2Ko: json["Pv2_ko"],
    pv2En: json["Pv2_en"],
    pv3Ko: json["Pv3_ko"],
    pv3En: json["Pv3_en"],
    pv4Ko: json["Pv4_ko"],
    pv4En: json["Pv4_en"],
    pv5Ko: json["Pv5_ko"],
    pv5En: json["Pv5_en"],
    rv1Ko: json["Rv1_ko"],
    rv1En: json["Rv1_en"],
    rv2Ko: json["Rv2_ko"],
    rv2En: json["Rv2_en"],
    rv3Ko: json["Rv3_ko"],
    rv3En: json["Rv3_en"],
  );

  Map<String, dynamic> toJson() => {
    "book_name": bookName,
    "idx": idx,
    "prac_idx": pracIdx,
    "sbook_id": sbookId,
    "days": days,
    "Unit_Title": unitTitle,
    "Pages_Title": pagesTitle,
    "Topic_Title": topicTitle,
    "Function_Title": functionTitle,
    "Grammar_Title": grammarTitle,
    "Pv1_ko": pv1Ko,
    "Pv1_en": pv1En,
    "Pv2_ko": pv2Ko,
    "Pv2_en": pv2En,
    "Pv3_ko": pv3Ko,
    "Pv3_en": pv3En,
    "Pv4_ko": pv4Ko,
    "Pv4_en": pv4En,
    "Pv5_ko": pv5Ko,
    "Pv5_en": pv5En,
    "Rv1_ko": rv1Ko,
    "Rv1_en": rv1En,
    "Rv2_ko": rv2Ko,
    "Rv2_en": rv2En,
    "Rv3_ko": rv3Ko,
    "Rv3_en": rv3En,
  };
}
