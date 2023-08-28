import 'dart:io';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:snap_poll/global/colors.dart';
import 'package:snap_poll/global/global_variables.dart';
import 'package:snap_poll/global/size_config.dart';
import 'package:snap_poll/routes/app_pages.dart';

import '../global/global_widgets.dart';

class AllSurveys extends StatefulWidget {
  const AllSurveys({Key? key}) : super(key: key);

  @override
  _AllSurveysState createState() => _AllSurveysState();
}

class _AllSurveysState extends State<AllSurveys> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  List<DocumentSnapshot> allSurveys = [];
  List<DocumentSnapshot> filteredSurveys = [];
  GlobalWidgets globalWidgets = GlobalWidgets();
  Map<String, dynamic>? fetchDoc;
  List<dynamic> listOfAllQuestions = [];
  TextEditingController ctl = TextEditingController();
  List<dynamic> listOfAllSections = [];
  String userLocation = '';

  @override
  void initState() {
    // TODO: implement initState
    filteredSurveys = allSurveys;
    super.initState();
    print(GlobalVariables.currentIndex);
    loadAllSurveys();
  }

  void _runFilter(String enteredKeyword) {
    List<DocumentSnapshot> results = [];
    if (enteredKeyword.isEmpty) {
      results = allSurveys;
    } else {
      results = allSurveys
          .where((survey) => survey
              .get("title")
              .toString()
              .toLowerCase()
              .contains(enteredKeyword.toLowerCase()))
          .toList();
    }

    setState(() {
      filteredSurveys = results;
    });
    // .where((survey) => survey.get("title").toString().toLowerCase().contains(enteredKeyword.toLowerCase();))}
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
              title: globalWidgets.myTextRaleway(context, "Created Surveys",
                  ColorsX.white, 0, 0, 0, 0, FontWeight.w400, 20),
              leading: GestureDetector(
                onTap: () {
                  Get.toNamed(Routes.MAIN_PAGE);
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
    return Container(
      height: SizeConfig.screenHeight,
      width: SizeConfig.screenWidth,
      child: Column(
        children: [
          TextField(
              onChanged: (value) => _runFilter(value),
              decoration: InputDecoration(
                  labelText: 'Search', suffixIcon: Icon(Icons.search))),
          Expanded(
            child: ListView.separated(
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onLongPress: () {
                      showModalBottomSheet(
                          context: context,
                          builder: (context) {
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                ListTile(
                                  leading: new Icon(Icons.details),
                                  title: globalWidgets.myTextRaleway(
                                      context,
                                      'View Details'.tr,
                                      ColorsX.black,
                                      0,
                                      0,
                                      0,
                                      0,
                                      FontWeight.w400,
                                      14),
                                  onTap: () async {
                                    var docRef =
                                        filteredSurveys[index].reference;
                                    final QuerySnapshot querySnapshot =
                                        await docRef
                                            .collection('results')
                                            .get();
                                    final List<DocumentSnapshot>
                                        firestoreResponseList =
                                        querySnapshot.docs;
                                    if (firestoreResponseList.isEmpty) {
                                      print('results empty');
                                    } else {
                                      GlobalVariables.surveyDetails.clear();
                                      GlobalVariables.surveyDetails.add(
                                          filteredSurveys[index].get('title'));
                                      GlobalVariables.surveyDetails.add(
                                          filteredSurveys[index]
                                              .get('short_description'));
                                      var created_at = filteredSurveys[index]
                                              .get('created_at') ??
                                          '';
                                      GlobalVariables.surveyDetails
                                          .add(created_at);

                                      GlobalVariables.surveyResult.clear();
                                      for (var x in firestoreResponseList) {
                                        if (x.exists &&
                                            x
                                                .data()
                                                .toString()
                                                .contains("result")) {
                                          print("line 103");
                                          print(x["result"]);
                                          GlobalVariables.surveyResult
                                              .add(x['result']);
                                        }
                                      }

                                      // Questions
                                      GlobalVariables.surveyQuestion.clear();
                                      final DocumentSnapshot snapshot =
                                          await FirebaseFirestore.instance
                                              .collection('surveys')
                                              .doc(filteredSurveys[index]
                                                  .reference
                                                  .id)
                                              .get();
                                      // .doc(GlobalVariables.idOfSurvey).get();
                                      if (snapshot.exists) {
                                        fetchDoc = snapshot.data()
                                            as Map<String, dynamic>?;
                                        listOfAllQuestions =
                                            fetchDoc?['questions'];
                                        print("line 130");
                                        print(listOfAllQuestions);
                                        listOfAllQuestions.forEach((element) {
                                          print(element);
                                          GlobalVariables.surveyQuestion
                                              .add(element);
                                        });
                                      } else {
                                        GlobalWidgets.hideProgressLoader();
                                        errorDialog(
                                            context, "No Questions Found!");
                                      }
                                    }

                                    Get.toNamed(Routes.View_Details);
                                  },
                                ),
                                ListTile(
                                  leading: const Icon(Icons.copy),
                                  title: globalWidgets.myTextRaleway(
                                      context,
                                      'Duplicate this survey'.tr,
                                      ColorsX.black,
                                      0,
                                      0,
                                      0,
                                      0,
                                      FontWeight.w400,
                                      14),
                                  onTap: () {
                                    GlobalVariables.idOfSurvey =
                                        filteredSurveys[index].reference.id;
                                    duplicateSurveyTitleDialog(context, ctl);
                                  },
                                ),
                                ListTile(
                                  leading: new Icon(Icons.save),
                                  title: globalWidgets.myTextRaleway(
                                      context,
                                      'Save results as CSV file'.tr,
                                      ColorsX.black,
                                      0,
                                      0,
                                      0,
                                      0,
                                      FontWeight.w400,
                                      14),
                                  onTap: () async {
                                    bool isPermissionGranted =
                                        await isStoragePermissionGranted();
                                    if (isPermissionGranted) {
                                      createCSV(index);
                                    } else {
                                      await requestStoragePermission();
                                      isPermissionGranted =
                                          await isStoragePermissionGranted();
                                      if (isPermissionGranted) {
                                        createCSV(index);
                                      } else {
                                        print(
                                            'Storage permission not granted.');
                                      }
                                    }
                                  },
                                ),
                                ListTile(
                                  leading: const Icon(Icons.delete),
                                  title: globalWidgets.myTextRaleway(
                                      context,
                                      'Delete survey'.tr,
                                      ColorsX.black,
                                      0,
                                      0,
                                      0,
                                      0,
                                      FontWeight.w400,
                                      14),
                                  onTap: () {
                                    var docRef =
                                        filteredSurveys[index].reference;
                                    docRef.delete().then((value) {
                                      // Delete successful
                                      setState(() {
                                        // filteredSurveys.removeAt(index);
                                        allSurveys.removeAt(index);
                                        // allSurveys = filteredSurveys;
                                        filteredSurveys = allSurveys;
                                      });
                                      Navigator.pop(
                                          context); // Close the bottom sheet
                                    }).catchError((error) {
                                      // Delete failed
                                      print("Failed to delete survey: $error");
                                    });
                                  },
                                ),
                              ],
                            );
                          });
                    },
                    onTap: () {
                      GlobalVariables.idOfSurvey =
                          "${filteredSurveys[index].reference.id}";
                      Get.toNamed(Routes.CARD_FORM_LAYOUT);
                    },
                    child: ListTile(
                      title: globalWidgets.myTextCustomOneLine(
                          context,
                          "${filteredSurveys[index].get('title')}",
                          ColorsX.black,
                          0,
                          0,
                          10,
                          10,
                          FontWeight.w500,
                          17),
                      subtitle: globalWidgets.myTextCustomOneLine(
                          context,
                          "${filteredSurveys[index].get('short_description')}",
                          ColorsX.black.withOpacity(0.7),
                          0,
                          0,
                          10,
                          0,
                          FontWeight.w400,
                          14),
                      // trailing: GestureDetector(
                      //   onTap: (){},
                      //   child: Icon(Icons.share_rounded, color: ColorsX.appBarColor,),
                      // ),
                    ),
                  );
                },
                separatorBuilder: (context, index) {
                  return const Divider(
                    height: 5,
                    thickness: 0.5,
                    indent: 5,
                    endIndent: 5,
                    color: ColorsX.greytext,
                  );
                },
                itemCount: filteredSurveys.length),
          ),
        ],
      ),
    );
  }

  loadAllSurveys() async {
    GlobalWidgets.showProgressLoader("Please wait".tr);

    final QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection('surveys').get();
    final List<DocumentSnapshot> firestoreResponseList = querySnapshot.docs;
    if (firestoreResponseList.isEmpty) {
      print("No results");
      errorDialog(context, 'No survey available so far');
    } else {
      List<DocumentSnapshot> temp = firestoreResponseList;
      firestoreResponseList.removeWhere(
          (element) => (element.get('user_id') != GlobalVariables.userId));
      // if(temp.isNotEmpty){
      // for (var element in temp) {
      //   if (element.get('user_id') != GlobalVariables.userId) {
      //     temp.remove(element);
      //   }
      //
      // }
      // }
      if (firestoreResponseList.isEmpty) {
        errorDialog(context, 'You have not created any survey yet.');
      } else {
        setState(() {
          allSurveys = firestoreResponseList;
          filteredSurveys = firestoreResponseList;
        });
      }
    }
    GlobalWidgets.hideProgressLoader();
  }

  Future<void> createCSV(int index) async {
    var docRef = filteredSurveys[index].reference;
    final QuerySnapshot querySnapshot =
        await docRef.collection('results').get();
    final List<DocumentSnapshot> firestoreResponseList = querySnapshot.docs;
    if (firestoreResponseList.isEmpty) {
      print('results empty');
    } else {
      List<List<dynamic>> data = [];
      for (var x in firestoreResponseList) {
        if (x.exists) {
          print(x.data());
        }
      }
      var questionDoc =
          firestoreResponseList.firstWhere((doc) => doc.id == 'questionsID');
      List<dynamic> questions = questionDoc['questions'];
      print('Liste: $questions');
      List<dynamic> questionCSV = [];
      questionCSV.add("answer_date");
      questionCSV.add("survey_rating");
      questionCSV.add("suggestion");
      questionCSV.add('duration');
      for (Map t in questions) {
        print("line 280");
        print(t['question']);
        questionCSV.add(t['question']);
        questionCSV.add("location");
      }
      print(questionCSV);
      data.add(questionCSV);
      firestoreResponseList.remove(questionDoc);
      print("NACH DER LÖSCHUNG");
      for (var x in firestoreResponseList) {
        if (x.exists) {
          List<dynamic> result = x['result'];
          print('line 291');
          print(x['result']);
          List<dynamic> resultCSV = [];
          resultCSV.add(x['answer_date']);
          resultCSV.add(x['survey_rating']);
          resultCSV.add(x['suggestion']);
          resultCSV.add(x['time']);
          for (var element in result) {
            print("line 296");
            print(element['answer']);
            resultCSV.add(element['answer'].toString());
            resultCSV.add(x['location']);
          }
          data.add(resultCSV);
        }
      }
      print(data);
      saveCSVToDownloads(index, data);
    }
  }

  Future<void> saveCSVToDownloads(
      int index, List<List<dynamic>> csvData) async {
    // Generate the CSV string
    String csvString = const ListToCsvConverter().convert(csvData);

    // Get the document directory using path_provider package
    Directory directory = Directory("");
    if (Platform.isAndroid) {
      // Redirects it to download folder in android
      directory = Directory("/storage/emulated/0/Download");
    } else {
      directory = await getApplicationDocumentsDirectory();
    }

    // Create the CSV file path
    String filePath =
        '${directory.path}/${filteredSurveys[index].reference.id}.csv';

    // Write the CSV string to the file
    File file = File(filePath);
    await file.writeAsString(csvString);

    print('CSV file saved to: $filePath');
    saveDialog(context);
  }

  // Request storage permission
  Future<void> requestStoragePermission() async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }
  }

// Check if storage permission is granted
  Future<bool> isStoragePermissionGranted() async {
    var status = await Permission.storage.status;
    return status.isGranted;
  }

  saveDialog(BuildContext context) {
    return AwesomeDialog(
        context: context,
        dialogType: DialogType.success,
        animType: AnimType.rightSlide,
        headerAnimationLoop: false,
        title: "Saved CSV file to device".tr,
        desc: 'Check your downloads folder'.tr,
        btnOkOnPress: () {
          Get.back();
        },
        btnOkIcon: Icons.check_circle,
        btnOkColor: Colors.blueAccent)
      ..show();
  }

  errorDialog(BuildContext context, String description) {
    return AwesomeDialog(
        context: context,
        dialogType: DialogType.ERROR,
        animType: AnimType.RIGHSLIDE,
        headerAnimationLoop: true,
        body: Column(
          children: [
            globalWidgets.myTextRaleway(context, "No Survey Found",
                ColorsX.black, 10, 0, 0, 0, FontWeight.w600, 18),
            globalWidgets.myTextRaleway(context, description, ColorsX.subBlack,
                10, 0, 0, 20, FontWeight.w400, 12),
          ],
        ), // \n Save or remember ID to Log In' ,

        btnOkOnPress: () {
          Get.back();
        },
        btnOkIcon: Icons.cancel,
        btnOkColor: Colors.red)
      ..show();
  }

  // Riham // 06-08-23
  duplicateSurveyTitleDialog(
    BuildContext context,
    TextEditingController ctl,
  ) {
    ctl.clear();
    return AwesomeDialog(
        context: context,
        animType: AnimType.LEFTSLIDE,
        headerAnimationLoop: false,
        dialogType: DialogType.question,
        dismissOnTouchOutside: false,
        dismissOnBackKeyPress: false,
        closeIcon: Container(),
        // closeIcon: IconButton(icon : Icon(Icons.close, color: ColorsX.light_orange,),onPressed: () {
        //   Get.back();
        //   // Get.toNamed(Routes.LOGIN_SCREEN);
        // },),
        showCloseIcon: true,
        // title: ,
        // desc: 'This will help people to find your survey.',//
        body: Column(
          children: [
            globalWidgets.myTextRaleway(context, "Add Title of Survey".tr,
                ColorsX.black, 10, 0, 0, 0, FontWeight.w600, 18),
            globalWidgets.myTextRaleway(
                context,
                "This will help people to find your survey.".tr,
                ColorsX.subBlack,
                10,
                0,
                0,
                20,
                FontWeight.w400,
                12),
            globalWidgets.myTextField(
                TextInputType.text, ctl, false, 'Write title here'.tr)
          ],
        ), // \n Save or remember ID to Log In' ,
        btnCancelOnPress: () {},
        btnCancelColor: ColorsX.subBlack,
        btnOkText: 'Done'.tr,
        buttonsTextStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
        btnCancelText: 'Cancel'.tr,
        btnOkColor: ColorsX.appBarColor,
        btnOkOnPress: () async {
          debugPrint('OnClcik');
          GlobalWidgets.hideKeyboard(context);

          if (ctl.text.isEmpty) {
            GlobalWidgets.showToast('Please give a title to your survey'.tr);
          } else {
            // GlobalVariables.TITLE_OF_SURVEY = ctl.text;
            GlobalWidgets.showProgressLoader('');

            // get the current survey details.
            final DocumentSnapshot snapshot = await FirebaseFirestore.instance
                .collection('surveys')
                .doc(GlobalVariables.idOfSurvey)
                .get();

            if (snapshot.exists) {
              fetchDoc = snapshot.data() as Map<String, dynamic>?;

              GlobalWidgets.hideProgressLoader();
              listOfAllQuestions = fetchDoc?['questions'];
              listOfAllSections = fetchDoc?['sections'];
              if (listOfAllQuestions[0] == "Select Section") {
                listOfAllSections.removeAt(0);
              }
            } else {
              GlobalWidgets.hideProgressLoader();
              errorDialog(context, "Survey Couldn't Found!");
            }

            var collection = FirebaseFirestore.instance.collection('surveys');
            Map<String, dynamic> map = {
              'title': ctl.text,
              'short_description': fetchDoc?['short_description'],
              'questions': listOfAllQuestions,
              'sections': listOfAllSections,
              'user_id': fetchDoc?['user_id'],
              'created_at': fetchDoc?['created_at']
            };
            print("line 518");
            print(map);
            var docRef = await collection.add(map);
            var documentId = docRef.id;

            GlobalWidgets.hideProgressLoader();
            if (documentId.toString().isEmpty) {
              GlobalWidgets.showToast('Survey not saved. Try again'.tr);
            } else {
              var resultsCollectionRef = FirebaseFirestore.instance
                  .collection('surveys/$documentId/results');
              await resultsCollectionRef
                  .doc('questionsID')
                  .set({'questions': listOfAllQuestions});
              GlobalVariables.idOfSurvey = documentId;
              GlobalVariables.TITLE_OF_SURVEY = "";
              GlobalWidgets.pwdWidgets.clear;
              // shortDescriptionCtl.clear();
              GlobalVariables.SECTIONS_LIST.clear();
              GlobalVariables.LIST_OF_ALL_QUESTIONS.clear();
              Get.toNamed(Routes.QRCODE_SCREEN);
            }
          }
        },
        onDismissCallback: (type) {
          debugPrint('Dialog Dismiss from callback $type');
        })
      ..show();
  }
}
