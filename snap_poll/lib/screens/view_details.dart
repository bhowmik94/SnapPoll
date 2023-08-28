import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:snap_poll/global/colors.dart';
import 'package:snap_poll/global/global_variables.dart';
import 'package:snap_poll/global/size_config.dart';
import 'package:snap_poll/routes/app_pages.dart';

import '../global/global_widgets.dart';

class ViewDetails extends StatefulWidget {
  const ViewDetails({Key? key}) : super(key: key);

  @override
  _ViewDetailsState createState() => _ViewDetailsState();
}

class _ViewDetailsState extends State<ViewDetails> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  List<DocumentSnapshot> allSurveys = [];
  GlobalWidgets globalWidgets = GlobalWidgets();
  List<String> surveyAllQuestion = [];
  Map<String, double> optionsAnswer = {};
  Map<int, Map<String, double>> allOptionsAnswer = {};
  List<Map<String, double>> allAll = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    print(GlobalVariables.currentIndex);
    loadViewDetails();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          Get.toNamed(Routes.MAIN_PAGE);
          return false;
        },
        child: Scaffold(
          body: body(context),
          appBar: AppBar(
              backgroundColor: ColorsX.appBarColor,
              centerTitle: true,
              title: globalWidgets.myTextRaleway(context, "Survey Details",
                  ColorsX.white, 0, 0, 0, 0, FontWeight.w400, 20),
              leading: GestureDetector(
                onTap: () {
                  Get.toNamed(Routes.ALL_SURVEYS);
                },
                child: Icon(
                  Icons.arrow_back_ios,
                  color: ColorsX.white,
                  size: 18,
                ),
              )),
        ));
  }

  body(BuildContext context) {
    return SingleChildScrollView(
        child: Container(
      height: SizeConfig.screenHeight,
      width: SizeConfig.screenWidth,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10.0, 15.0, 10.0, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Title:",
              style: TextStyle(
                color: Colors.grey,
                letterSpacing: 1.0,
              ),
            ),
            SizedBox(height: 2.0),
            Text(
              "${GlobalVariables.surveyDetails[0]}",
              style: TextStyle(
                color: Colors.blueAccent[200],
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 5.0),
            Text(
              "Short Description:",
              style: TextStyle(
                color: Colors.grey,
                letterSpacing: 1.0,
              ),
            ),
            SizedBox(height: 2.0),
            Text(
              "${GlobalVariables.surveyDetails[1]}",
              style: TextStyle(
                color: Colors.blueAccent[200],
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 5.0),
            Text(
              "Created:",
              style: TextStyle(
                color: Colors.grey,
                letterSpacing: 1.0,
              ),
            ),
            SizedBox(height: 2.0),
            Text(
              "${GlobalVariables.surveyDetails[2]}",
              style: TextStyle(
                color: Colors.blueAccent[200],
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 5.0),
            Text(
              "Total Submission:",
              style: TextStyle(
                color: Colors.grey,
                letterSpacing: 1.0,
              ),
            ),
            SizedBox(height: 2.0),
            Text(
              "${GlobalVariables.surveyResult.length}",
              style: TextStyle(
                color: Colors.blueAccent[200],
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            Divider(
              height: 20.0,
              color: Colors.blueAccent,
            ),
            // PieChart(dataMap: <String, double>{"a": 5, "b": 6}),
            allOptionsAnswer.isEmpty
                ? Text("Pie Chart will show here:")
                : Expanded(
                    child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: allOptionsAnswer.isEmpty
                            ? 0
                            : GlobalVariables.surveyQuestion.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding:
                                const EdgeInsets.fromLTRB(0.0, 25.0, 0.0, 0.0),
                            child: Card(
                              child: PieChart(
                                dataMap: allOptionsAnswer[index]
                                    as Map<String, double>,
                                centerText: GlobalVariables
                                    .surveyQuestion[index]['question'],
                                chartRadius: 150,
                                chartValuesOptions: ChartValuesOptions(
                                    showChartValuesOutside: true,
                                    showChartValuesInPercentage: true),
                              ),
                            ),
                          );
                        }))
          ],
        ),
      ),
    ));
  }

  loadViewDetails() {
    // print("line 93");
    // print(GlobalVariables.surveyResult.length);
    // print(GlobalVariables.surveyResult);
    // print(GlobalVariables.surveyResult[0]);
    // print(GlobalVariables.surveyResult[0][0]);
    // print(GlobalVariables.surveyQuestion.length);
    // // GlobalVariables.surveyQuestion.forEach((element) {
    // GlobalVariables.surveyResult.forEach((element) {
    //   // for (var i = 0; i < element['options'].length; i++) {}\
    //   print(element);
    // });

    allOptionsAnswer.clear();
    for (var q = 0; q < GlobalVariables.surveyQuestion.length; q++) {
      optionsAnswer = {};
      print("line 191");
      print(allOptionsAnswer);
      print(GlobalVariables.surveyQuestion[q]['question_type']);

      for (var ans = 0; ans < GlobalVariables.surveyResult.length; ans++) {
        print(GlobalVariables.surveyResult[ans][q]);
        print(GlobalVariables.surveyResult[ans][q]['answer'].runtimeType);
        if (GlobalVariables.surveyQuestion[q]['question_type'] ==
            "Multiple Choice") {
          for (var mc = 0;
              mc < GlobalVariables.surveyResult[ans][q]['answer'].length;
              mc++) {
            try {
              optionsAnswer.update(
                  GlobalVariables.surveyResult[ans][q]['answer'][mc],
                  (value) => ++value,
                  ifAbsent: () => 1);
            } catch (e) {
              print(e);
            }
          }
        } else if (GlobalVariables.surveyQuestion[q]['question_type'] ==
            "Rating") {
          try {
            optionsAnswer.update(
                GlobalVariables.surveyResult[ans][q]['answer'].toString(),
                (value) => ++value,
                ifAbsent: () => 1);
          } catch (e) {
            print(e);
          }
        } else {
          try {
            optionsAnswer.update(GlobalVariables.surveyResult[ans][q]['answer'],
                (value) => ++value,
                ifAbsent: () => 1);
          } catch (e) {
            print(e);
          }
        }
        // if(optionsAnswer.containsKey(GlobalVariables.surveyResult[ans][q]['answer'])) {
        //   optionsAnswer![GlobalVariables.surveyResult[ans][q]['answer']]++;
        // }
      }
      print("line 198");
      print(optionsAnswer);
      if (optionsAnswer.isNotEmpty) {
        allOptionsAnswer[q] = optionsAnswer;
        allAll.add(optionsAnswer);
      }
      print(allOptionsAnswer);
      print(allAll);
    }

    // optionsAnswer.forEach((key, value) {
    //   print(key);
    //   print(value);
    // });
  }
}
