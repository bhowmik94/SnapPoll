import 'dart:async';

import 'package:avatar_glow/avatar_glow.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:intro_slider/intro_slider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:snap_poll/global/colors.dart';
import 'package:snap_poll/global/global_variables.dart';
import 'package:snap_poll/global/global_widgets.dart';
import 'package:snap_poll/global/size_config.dart';
import 'package:snap_poll/routes/app_pages.dart';
import 'package:snap_poll/screens/timeout_screen.dart';
import 'package:snap_poll/widget/mc_question_widget.dart';
import 'package:speech_to_text/speech_to_text.dart';

class CardFormLayout extends StatefulWidget {
  const CardFormLayout({Key? key}) : super(key: key);

  @override
  _CardFormLayoutState createState() => _CardFormLayoutState();
}

class _CardFormLayoutState extends State<CardFormLayout> {
  GlobalWidgets globalWidgets = GlobalWidgets();
  DocumentSnapshot? documentSnapshot;
  Map<String, dynamic>? fetchDoc;
  List<dynamic> listOfAllQuestions = [];
  List<dynamic> listOfAllSections = [];
  List<ContentConfig> listContentConfig = [];
  List<CheckboxListTileModel> checkboxListTiles = [];
  TextEditingController ctl = TextEditingController();
  TextEditingController otctl = TextEditingController();
  CarouselController carouselController = CarouselController();
  String _groupValue = 'Any';
  String start_age = '';
  String end_age = '';
  double initialRating = 0;
  double feedbackInitialRating = 0;
  String userLocation = '';
  int dynamicLinearScaleValue = 0;
  String selectedLinearScaleValue = '';
  RangeValues _currentRangeValues = RangeValues(1, 100);
  late DateTime questionStartTime;
  late DateTime questionEndTime;
  SpeechToText speechToText = SpeechToText();
  bool isQuestionVisible = true;
  bool isFeedbackVisible = false;

  String _lastWords = '';
  String _currentWords = '';
  bool isListening = false;
  bool speachSessionActive = false;

  @override
  void initState() {
    super.initState();

    loadSurvey();
    Future.delayed(Duration(seconds: 2), () {
      checkLocation();
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return await showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: GlobalWidgets().myTextRaleway(
                    context,
                    "Leave Survey?".tr,
                    ColorsX.appBarColor,
                    0,
                    0,
                    0,
                    0,
                    FontWeight.w700,
                    24),
                content: GlobalWidgets().myTextRaleway(
                    context,
                    "Are you sure you want to quit the survey?".tr,
                    ColorsX.appBarColor,
                    0,
                    0,
                    0,
                    0,
                    FontWeight.w500,
                    18),
                actionsAlignment: MainAxisAlignment.spaceAround,
                actions: <Widget>[
                  TextButton(
                    child: GlobalWidgets().myTextRaleway(context, "Stay".tr,
                        ColorsX.appBarColor, 0, 0, 0, 0, FontWeight.w600, 18),
                    onPressed: () {
                      Navigator.of(context)
                          .pop(false); // Stay on the current screen
                    },
                  ),
                  TextButton(
                    child: GlobalWidgets().myTextRaleway(context, "Quit".tr,
                        ColorsX.appBarColor, 0, 0, 0, 0, FontWeight.w600, 18),
                    onPressed: () {
                      GlobalVariables.currentIndex = 0;
                      if (FirebaseAuth.instance.currentUser == null) {
                        Get.toNamed(Routes.INITIAL_SCREEN);
                      } else {
                        Get.toNamed(Routes.MAIN_PAGE);
                      }
                      // Navigate to the named route
                    },
                  )
                ],
              );
            });
      },
      child: Scaffold(
        body: body(context),
        appBar: AppBar(
            backgroundColor: ColorsX.appBarColor,
            centerTitle: true,
            leading: GestureDetector(
              onTap: () {
                cancelDialog();
              },
              child: const Icon(
                Icons.arrow_back_ios,
                color: ColorsX.white,
                size: 18,
              ),
            )),
      ),
    );
  }

  body(BuildContext context) {
    return listOfAllQuestions.isEmpty
        ? Container()
        : Container(
            width: SizeConfig.screenWidth,
            height: SizeConfig.screenHeight,
            decoration: const BoxDecoration(color: ColorsX.white),
            child: Center(
              child: ListView(
                children: [
                  GestureDetector(
                    onTap: () {
                      timeoutScreenKey.currentState
                          ?.resetTimerFromOtherScreen();
                      print('Tapped on the question card!: $timeoutScreenKey');
                    },
                    child: cardOfQuestion(context),
                  ),
                ],
              ),
            ),
          );
  }

  Future<void> checkLocation() async {
    // Check and request location permission
    var status = await Permission.locationWhenInUse.status;
    print('Storage permission status: $status');
    if (!status.isGranted) {
      await Permission.locationWhenInUse.request();
    } else {
      getLocation();
    }
  }

  getLocation() async {
    Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    // Get the approximate address
    List<Placemark> placemarks = await placemarkFromCoordinates(
      position.latitude,
      position.longitude,
    );

    // Extract the address from the placemark
    String streetName = placemarks[0].street.toString();
    String city = placemarks[0].locality.toString();
    String state = placemarks[0].administrativeArea.toString();
    String country = placemarks[0].country.toString();

    userLocation = '$streetName, $city, $state, $country';
  }

  void cancelDialog() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: GlobalWidgets().myTextRaleway(context, "Leave Survey?".tr,
                ColorsX.appBarColor, 0, 0, 0, 0, FontWeight.w700, 24),
            content: GlobalWidgets().myTextRaleway(
                context,
                "Are you sure you want to quit the survey?".tr,
                ColorsX.appBarColor,
                0,
                0,
                0,
                0,
                FontWeight.w500,
                18),
            actionsAlignment: MainAxisAlignment.spaceAround,
            actions: <Widget>[
              TextButton(
                child: GlobalWidgets().myTextRaleway(context, "Stay".tr,
                    ColorsX.appBarColor, 0, 0, 0, 0, FontWeight.w600, 18),
                onPressed: () {
                  Navigator.of(context)
                      .pop(false); // Stay on the current screen
                },
              ),
              TextButton(
                child: GlobalWidgets().myTextRaleway(context, "Quit".tr,
                    ColorsX.appBarColor, 0, 0, 0, 0, FontWeight.w600, 18),
                onPressed: () {
                  GlobalVariables.currentIndex = 0;
                  Get.toNamed(Routes
                      .ALL_SURVEYS); // Navigate to the desired named route
                },
              )
            ],
          );
        });
  }

  void loadSurvey() async {
    GlobalWidgets.showProgressLoader("Please wait".tr);

    final DocumentSnapshot snapshot = await FirebaseFirestore.instance
        .collection('surveys')
        .doc(GlobalVariables.idOfSurvey)
        .get();
    // .doc(GlobalVariables.idOfSurvey).get();
    if (snapshot.exists) {
      questionStartTime = DateTime.now();
      fetchDoc = snapshot.data() as Map<String, dynamic>?;

      GlobalWidgets.hideProgressLoader();
      listOfAllQuestions = fetchDoc?['questions'];
      listOfAllSections = fetchDoc?['sections'];
      listOfAllSections.removeAt(0);
      setState(() {
        documentSnapshot = snapshot;
      });
    } else {
      GlobalWidgets.hideProgressLoader();
      errorDialog(context);
    }
    print("line 216");
    debugPrint(listOfAllQuestions.length.toString());
    debugPrint(listOfAllQuestions.toString());
  }

  errorDialog(BuildContext context) {
    return AwesomeDialog(
        context: context,
        dialogType: DialogType.ERROR,
        animType: AnimType.RIGHSLIDE,
        headerAnimationLoop: true,
        title: "No Survey Found".tr,
        desc: 'Please try again'.tr,
        btnOkOnPress: () {
          Get.back();
        },
        btnOkIcon: Icons.cancel,
        btnOkColor: Colors.red)
      ..show();
  }

  Future _stopListening() async {
    setState(() {
      otctl.value = TextEditingValue(text: _lastWords);
      speachSessionActive = false;
    });
    await speechToText.stop();
  }

  cardOfQuestion(BuildContext context) {
    return CarouselSlider(
      disableGesture: false,
      carouselController: carouselController,
      options: CarouselOptions(
          height: SizeConfig.screenHeight,
          enableInfiniteScroll: false,
          scrollPhysics: NeverScrollableScrollPhysics(),
          initialPage: 0,
          autoPlay: false,
          viewportFraction: 1),
      items: listOfAllQuestions.map((i) {
        return Builder(
          builder: (BuildContext context) {
            return Container(
              width: MediaQuery.of(context).size.width,
              margin: EdgeInsets.symmetric(horizontal: 5.0),
              decoration: BoxDecoration(color: ColorsX.white),
              child: Column(
                children: [
                  Visibility(
                    visible: isQuestionVisible,
                    child: Column(
                      children: [
                        globalWidgets.progressBarForSurveyQuestions(
                            listOfAllQuestions.length.toString(),
                            GlobalVariables.currentIndex.toString()),
                        globalWidgets.myTextRaleway(context, i['question'],
                            ColorsX.black, 20, 10, 10, 0, FontWeight.w500, 18),
                        i['question_type'] == 'Yes No'
                            ? yesNoWidget(context)
                            : i['question_type'] == 'Single Choice'
                                ? singleChoiceWidget(context)
                                : i['question_type'] == 'Multiple Choice'
                                    ? multipleChoiceWidget(context)
                                    : i['question_type'] == 'Rating'
                                        ? ratingWidget(context)
                                        : i['question_type'] == 'Open Text'
                                            ? openTextWidget(context)
                                            : i['question_type'] == 'Range'
                                                ? rangeWidget(context)
                                                : i['question_type'] ==
                                                        'Linear Scale'
                                                    ? scaleRating(context)
                                                    : Container(),
                        nextQuestion(context),
                      ],
                    ),
                  ),
                  Visibility(
                    visible: isFeedbackVisible,
                    child: Column(
                      children: [
                        // Inside your widget tree
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Column(
                            children: [
                              SizedBox(height: 5),
                              // Added text widget
                              globalWidgets.myTextRaleway(
                                  context,
                                  'Please provide your feedback about this survey'
                                      .tr,
                                  Colors.black,
                                  0,
                                  0,
                                  0,
                                  0,
                                  FontWeight.w600,
                                  16),
                              SizedBox(height: 10), // Add some spacing

                              RatingBar.builder(
                                initialRating: feedbackInitialRating,
                                minRating: 1,
                                direction: Axis.horizontal,
                                allowHalfRating: false,
                                itemCount: 5,
                                itemBuilder: (context, _) => const Icon(
                                  Icons.star,
                                  color: Colors.amber,
                                ),
                                onRatingUpdate: (rating) {
                                  feedbackInitialRating = rating;
                                  print(
                                      "Feedback Rating: $feedbackInitialRating");
                                },
                              ),
                              SizedBox(height: 10),
                              Container(
                                margin: EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 10),
                                height: SizeConfig.screenHeight * 0.3,
                                child: globalWidgets.myTextFieldMultipleLines(
                                  TextInputType.multiline,
                                  ctl,
                                  false,
                                  'Add your thoughts'.tr,
                                ),
                              ),
                            ],
                          ),
                        ),
                        nextQuestion(
                            context), // Adjust the position of this function call as needed
                      ],
                    ),
                  )
                ],
              ),
            );
          },
        );
      }).toList(),
    );

    // for(int index = 0; index < listOfAllQuestions.length; index++){
    //   GlobalVariables.currentIndex = index;
    //   if(listOfAllSections.contains(listOfAllQuestions[index]['section'])) {
    //     return Container(
    //         child: Column(
    //           children: [
    //             globalWidgets.myTextRaleway(
    //                 context,
    //                 listOfAllSections[index],
    //                 ColorsX.black,
    //                 10,
    //                 10,
    //                 10,
    //                 0,
    //                 FontWeight.w500,
    //                 23),
    //             Align(
    //               alignment: Alignment.centerLeft,
    //               child: globalWidgets.myTextRaleway(
    //                   context,
    //                   listOfAllQuestions[index]['question'],
    //                   ColorsX.black,
    //                   20,
    //                   10,
    //                   10,
    //                   0,
    //                   FontWeight.w500,
    //                   18),
    //             ),
    //             listOfAllQuestions[index]['question_type'] == 'Yes No' ? yesNoWidget(context) : Container(),
    //             nextQuestion(context),
    //           ],
    //         )
    //     );
    //   }
    //   else {
    //     return globalWidgets.myTextRaleway(context, 'Not for this section', ColorsX.black,
    //         10, 10, 10, 0, FontWeight.w500, 15);
    //   }
    // }
  }

  yesNoWidget(BuildContext context) {
    return Container(
        margin: EdgeInsets.only(top: 30),
        child: Column(
          children: [
            RadioListTile<String>(
              value: 'Yes',
              groupValue: _groupValue,
              title: globalWidgets.myTextRaleway(context, 'Yes'.tr,
                  Colors.black, 0, 0, 0, 0, FontWeight.w400, 17),
              onChanged: (newValue) => setState(() => _groupValue = newValue!),
              activeColor: Colors.red,
              selected: false,
            ),
            RadioListTile<String>(
              value: 'No',
              groupValue: _groupValue,
              title: globalWidgets.myTextRaleway(context, 'No'.tr, Colors.black,
                  0, 0, 0, 0, FontWeight.w400, 17),
              onChanged: (newValue) => setState(() => _groupValue = newValue!),
              activeColor: Colors.red,
              selected: false,
            ),
          ],
        ));
  }

  openTextWidget(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 30),
      child: Column(children: [
        Container(
          width: SizeConfig.screenWidth,
          margin: EdgeInsets.only(left: 10, right: 10, top: 5),
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(20.0)),
              border: Border.all(color: ColorsX.blackWithOpacity, width: 1.25)),
          child: TextFormField(
            keyboardType: TextInputType.text,
            controller: otctl,
            minLines: 8,
            maxLines: 8,
            obscureText: false,
            style: TextStyle(color: ColorsX.black),
            decoration: const InputDecoration(
                border: InputBorder.none,
                focusedBorder: InputBorder.none,
                enabledBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                disabledBorder: InputBorder.none,
                contentPadding:
                    EdgeInsets.only(left: 15, bottom: 11, top: 11, right: 15),
                hintText: 'Please provide your answer here',
                hintStyle: TextStyle(color: ColorsX.subBlack)),
          ),
        ),
        const SizedBox(height: 20),
        Center(
          child: globalWidgets.myTextRaleway(
              context,
              _lastWords.isNotEmpty
                  ? 'Release the microphone to stop recording!'
                  : 'Tap the microphone to start listening...',
              ColorsX.uBstrongestGrey,
              0,
              0,
              0,
              0,
              FontWeight.w400,
              18),
        ),
        const SizedBox(height: 1),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Container(
              height: 40,
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    _lastWords = "";
                    _currentWords = "";
                    otctl.text = "";
                  });
                  print("clear tapped");

                  print(_lastWords);
                },
                child: globalWidgets.myTextRaleway(context, "Clear".tr,
                    Colors.white, 0, 0, 0, 0, FontWeight.w300, 16),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorsX.appBarColor,
                  shape: const StadiumBorder(),
                ),
              ),
            ),
            AvatarGlow(
              endRadius: 75,
              animate: speachSessionActive,
              duration: const Duration(milliseconds: 2000),
              glowColor: Colors.grey,
              repeat: true,
              repeatPauseDuration: const Duration(milliseconds: 100),
              showTwoGlows: true,
              child: GestureDetector(
                onTapDown: (details) async {
                  print("object");
                  if (!speachSessionActive) {
                    setState(() {
                      speachSessionActive = true;
                    });
                    if (!isListening) {
                      Timer timer = Timer.periodic(Duration(milliseconds: 50),
                          (timer) async {
                        if (!speachSessionActive) {
                          timer.cancel();
                        }
                        if (!speechToText.isListening) {
                          bool available = await speechToText.initialize();
                          if (!available) {
                            speechToText.stop();
                            speechToText = SpeechToText();
                            available = await speechToText.initialize();
                          }
                        }
                        speechToText.listen(
                          listenMode: ListenMode.dictation,
                          cancelOnError: false,
                          partialResults: false,
                          onResult: (result) {
                            setState(() {
                              _currentWords = result.recognizedWords;
                              _lastWords += " $_currentWords";
                              otctl.value = TextEditingValue(text: _lastWords);

                              print(_lastWords);
                              print(_currentWords);
                            });
                          },
                        );
                        _currentWords = "";
                      });
                    }
                  }
                },
                onTapUp: (details) {
                  setState(() {
                    isListening = false;
                    speachSessionActive = false;
                  });
                  print("tapup");
                  print(speachSessionActive);
                  _stopListening();
                },
                onTapCancel: () {
                  setState(() {
                    // isListening = false;
                    speachSessionActive = false;
                  });
                  print("tapcancel");
                  print(speachSessionActive);
                  _stopListening();
                },
                child: CircleAvatar(
                  backgroundColor: ColorsX.appBarColor,
                  radius: 35,
                  child: Icon(
                    speachSessionActive ? Icons.mic : Icons.mic_none,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        )
      ]),
    );
  }

  singleChoiceWidget(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 30),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount:
            listOfAllQuestions[GlobalVariables.currentIndex]['options'].length,
        itemBuilder: (context, index) {
          return RadioListTile<String>(
            controlAffinity: ListTileControlAffinity.leading,
            value: listOfAllQuestions[GlobalVariables.currentIndex]['options']
                [index],
            groupValue: _groupValue,
            activeColor: ColorsX.appBarColor,
            selected: false,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Container(
                  width: SizeConfig.screenWidth * .50,
                  child: globalWidgets.myTextRaleway(
                      context,
                      listOfAllQuestions[GlobalVariables.currentIndex]
                          ['options'][index],
                      ColorsX.black,
                      0,
                      0,
                      0,
                      0,
                      FontWeight.w400,
                      16),
                ),
              ],
            ),
            onChanged: (newValue) => setState(() => _groupValue = newValue!),
          );
        },
      ),
    );
  }

  multipleChoiceWidget(BuildContext context) {
    List options = listOfAllQuestions[GlobalVariables.currentIndex]['options'];
    return MultipleChoiceQuestionWidget(options: options);
  }

  ratingWidget(BuildContext context) {
    return RatingBar.builder(
      initialRating: initialRating,
      minRating: 1,
      direction: Axis.horizontal,
      allowHalfRating: true,
      ignoreGestures: false,
      itemCount: 5,
      itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
      itemBuilder: (context, _) => Icon(
        Icons.star,
        color: Colors.amber,
      ),
      onRatingUpdate: (rating) {
        initialRating = rating;
        print(rating);
      },
    );
  }

  rangeWidget(BuildContext context) {
    _currentRangeValues = RangeValues(
        double.parse(
            listOfAllQuestions[GlobalVariables.currentIndex]['range_starting']),
        double.parse(
            listOfAllQuestions[GlobalVariables.currentIndex]['range_ending']));
    // _currentRangeValues = RangeValues(1,70);
    return RangeSlider(
      values: _currentRangeValues,
      min: double.parse(
          listOfAllQuestions[GlobalVariables.currentIndex]['range_starting']),
      max: double.parse(
          listOfAllQuestions[GlobalVariables.currentIndex]['range_ending']),
      divisions: 100,
      // int.parse(listOfAllQuestions[GlobalVariables.currentIndex]['range_ending']),
      inactiveColor: ColorsX.yellowColor,
      activeColor: ColorsX.appBarColor,
      semanticFormatterCallback:
          ageValuesRange(_currentRangeValues.start, _currentRangeValues.end),
      labels: RangeLabels(
        _currentRangeValues.start.round().toString(),
        _currentRangeValues.end.round().toString(),
      ),
      onChanged: (RangeValues values) {
        setState(() {
          _currentRangeValues = values;
          start_age = _currentRangeValues.start.toStringAsFixed(0);
          end_age = _currentRangeValues.end.toStringAsFixed(0);
          debugPrint(values.toString());
          debugPrint(start_age.toString());
          debugPrint(end_age.toString());
        });
      },
    );
  }

  scaleRating(BuildContext context) {
    String value =
        "${listOfAllQuestions[GlobalVariables.currentIndex]['max_value']}" ==
                "null"
            ? "0"
            : "${listOfAllQuestions[GlobalVariables.currentIndex]['max_value']}";
    dynamicLinearScaleValue = int.parse(value);
    debugPrint("$value");
    return Container(
      width: SizeConfig.screenWidth,
      child: Wrap(
        spacing: 8,
        // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          for (int index = 0; index < dynamicLinearScaleValue; index++)
            scaleRatingItem(context, index, (index + 1).toString()),
        ],
      ),
    );
  }

  scaleRatingItem(BuildContext context, int index, String value) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedLinearScaleValue = value;
        });
      },
      child: Container(
        height: 50,
        width: 30,
        decoration: BoxDecoration(
            color: selectedLinearScaleValue == value
                ? ColorsX.appBarColor
                : ColorsX.subBlack,
            shape: BoxShape.circle),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(6.0),
            child: globalWidgets.myTextRaleway(
                context, value, ColorsX.white, 0, 0, 0, 0, FontWeight.w400, 11),
          ),
        ),
      ),
    );
  }

  ageValuesRange(double start, double end) {
    debugPrint(start.toStringAsFixed(0));
    debugPrint(end.toStringAsFixed(0));
  }

  nextQuestion(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (listOfAllQuestions[GlobalVariables.currentIndex]['question_type'] ==
            'Yes No') {
          debugPrint(_groupValue);
          print(ctl.text);
          if (_groupValue == 'Any' &&
              (listOfAllQuestions.length - GlobalVariables.currentIndex != 1)) {
            GlobalWidgets.showToast('Please answer the question'.tr);
          } else {
            questionEndTime = DateTime.now();
            Duration engagementTime =
                questionEndTime.difference(questionStartTime);
            Map<String, dynamic> map = {
              'answer': _groupValue,
              // 'suggestion': ctl.text.isEmpty ? "" : ctl.text,
              'time': engagementTime.toString()
            };
            GlobalVariables.LIST_OF_ALL_ANSWERS.add(map);
            debugPrint(GlobalVariables.LIST_OF_ALL_ANSWERS.toString());
            _groupValue = 'Any';
            questionStartTime = DateTime.now();
            checkLastQuestion();
          }
        } else if (listOfAllQuestions[GlobalVariables.currentIndex]
                ['question_type'] ==
            'Single Choice') {
          debugPrint(_groupValue);
          if (_groupValue == 'Any') {
            GlobalWidgets.showToast('Please answer the question'.tr);
          } else {
            questionEndTime = DateTime.now();
            Duration engagementTime =
                questionEndTime.difference(questionStartTime);
            Map<String, dynamic> map = {
              'answer': _groupValue,
              // 'suggestion': ctl.text.isEmpty ? "" : ctl.text,
              'time': engagementTime.toString()
            };
            GlobalVariables.LIST_OF_ALL_ANSWERS.add(map);
            debugPrint(GlobalVariables.LIST_OF_ALL_ANSWERS.toString());
            _groupValue = 'Any';
            questionStartTime = DateTime.now();
            checkLastQuestion();
          }
        } else if (listOfAllQuestions[GlobalVariables.currentIndex]
                ['question_type'] ==
            'Multiple Choice') {
          debugPrint(GlobalVariables.LIST_OF_MC_RESULTS.toString());
          if (GlobalVariables.LIST_OF_MC_RESULTS.isEmpty) {
            GlobalWidgets.showToast('Please answer the question'.tr);
          } else {
            questionEndTime = DateTime.now();
            Duration engagementTime =
                questionEndTime.difference(questionStartTime);
            Map<String, dynamic> map = {
              'answer': GlobalVariables.LIST_OF_MC_RESULTS,
              // 'suggestion': ctl.text.isEmpty ? "" : ctl.text,
              'time': engagementTime.toString()
            };
            GlobalVariables.LIST_OF_ALL_ANSWERS.add(map);
            debugPrint(GlobalVariables.LIST_OF_ALL_ANSWERS.toString());
            GlobalVariables.LIST_OF_MC_RESULTS = [];
            questionStartTime = DateTime.now();
            checkLastQuestion();
          }
        } else if (listOfAllQuestions[GlobalVariables.currentIndex]
                ['question_type'] ==
            'Rating') {
          if (initialRating == 0) {
            GlobalWidgets.showToast('Please answer the question'.tr);
          } else {
            questionEndTime = DateTime.now();
            Duration engagementTime =
                questionEndTime.difference(questionStartTime);
            Map<String, dynamic> map = {
              'answer': initialRating,
              // 'suggestion': ctl.text.isEmpty ? "" : ctl.text,
              'time': engagementTime.toString()
            };
            GlobalVariables.LIST_OF_ALL_ANSWERS.add(map);
            debugPrint(GlobalVariables.LIST_OF_ALL_ANSWERS.toString());
            questionStartTime = DateTime.now();
            checkLastQuestion();
          }
        } else if (listOfAllQuestions[GlobalVariables.currentIndex]
                ['question_type'] ==
            'Linear Scale') {
          if (selectedLinearScaleValue == '') {
            GlobalWidgets.showToast('Please answer the question'.tr);
          } else {
            questionEndTime = DateTime.now();
            Duration engagementTime =
                questionEndTime.difference(questionStartTime);
            Map<String, dynamic> map = {
              'answer': selectedLinearScaleValue,
              // 'suggestion': ctl.text.isEmpty ? "" : ctl.text,
              'time': engagementTime.toString()
            };
            GlobalVariables.LIST_OF_ALL_ANSWERS.add(map);
            debugPrint(GlobalVariables.LIST_OF_ALL_ANSWERS.toString());
            questionStartTime = DateTime.now();
            checkLastQuestion();
          }
        } else if (listOfAllQuestions[GlobalVariables.currentIndex]
                ['question_type'] ==
            'Open Text') {
          debugPrint(GlobalVariables.LIST_OF_MC_RESULTS.toString());
          if (otctl.text.isEmpty) {
            GlobalWidgets.showToast('Please answer the question'.tr);
          } else {
            questionEndTime = DateTime.now();
            Duration engagementTime =
                questionEndTime.difference(questionStartTime);
            Map<String, dynamic> map = {
              'answer': otctl.text,
              // 'suggestion': ctl.text.isEmpty ? "" : ctl.text,
              'time': engagementTime.toString()
            };
            GlobalVariables.LIST_OF_ALL_ANSWERS.add(map);
            debugPrint(GlobalVariables.LIST_OF_ALL_ANSWERS.toString());
            _stopListening();
            _lastWords = "";
            _currentWords = "";
            otctl.clear();
            questionStartTime = DateTime.now();
            checkLastQuestion();
          }
        }
      },
      child: Container(
        width: SizeConfig.screenWidth,
        margin: EdgeInsets.only(left: 20, right: 20, top: 30),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
          color: listOfAllQuestions.length - GlobalVariables.currentIndex == 1
              ? ColorsX.appBarColor
              : ColorsX.appBarColor,
        ),
        child: Align(
          alignment: Alignment.center,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 15.0),
            child: globalWidgets.myTextRaleway(
                context,
                listOfAllQuestions.length - GlobalVariables.currentIndex == 1
                    ? "Submit Survey".tr
                    : "Next QUESTION".tr,
                ColorsX.white,
                0,
                0,
                0,
                0,
                FontWeight.w600,
                17),
          ),
        ),
      ),
    );
  }

  void checkLastQuestion() async {
    print(listOfAllQuestions.length - GlobalVariables.currentIndex);
    if (listOfAllQuestions.length - GlobalVariables.currentIndex == 1) {
      // GlobalWidgets.showToast('finish');
      if (isQuestionVisible == true) {
        setState(() {
          isQuestionVisible = false;
          isFeedbackVisible = true;
        });
      } else {
        saveAnswerWithFeedback();
        print(isQuestionVisible);
      }
      print(isQuestionVisible);
    } else {
      setState(() {
        GlobalVariables.currentIndex = GlobalVariables.currentIndex + 1;
      });
      ctl.clear();

      carouselController.jumpToPage(GlobalVariables.currentIndex);
      // clearSpeechRecognition();
    }
  }

  void saveAnswerWithFeedback() async {
    print("Survey is done!!!!!!!");
    var parentDocRef = FirebaseFirestore.instance
        .collection('surveys')
        .doc(GlobalVariables.idOfSurvey);
    DateTime date = DateTime.now();
    String d = DateFormat('dd.MM.yyyy – HH:mm').format(date);
    print(d);
    Map<String, dynamic> data = {
      'result': GlobalVariables.LIST_OF_ALL_ANSWERS,
      'answer_date': d,
      'survey_rating': feedbackInitialRating,
      'suggestion': ctl.text.isEmpty ? "" : ctl.text,
      'location': userLocation
    };
    print(data);
    addMapToSubcollection(parentDocRef, 'results', data);
    setState(() {
      GlobalVariables.currentIndex = 0;
      GlobalVariables.LIST_OF_ALL_ANSWERS = [];
    });
    submitDialog(context);
  }

  submitDialog(BuildContext context) {
    return AwesomeDialog(
        context: context,
        dialogType: DialogType.success,
        animType: AnimType.rightSlide,
        headerAnimationLoop: false,
        body: Column(
          children: [
            globalWidgets.myTextRaleway(context, "Survey Finished",
                ColorsX.black, 10, 0, 0, 0, FontWeight.w600, 18),
            globalWidgets.myTextRaleway(
                context,
                'Thank you for sharing your thoughts',
                ColorsX.subBlack,
                10,
                0,
                0,
                20,
                FontWeight.w400,
                12),
            GestureDetector(
              onTap: () {
                Get.toNamed(Routes.QRCODE_SCREEN);
              },
              child: Container(
                width: SizeConfig.screenWidth,
                margin: EdgeInsets.only(left: 20, right: 20, top: 30),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  color: listOfAllQuestions.length -
                              GlobalVariables.currentIndex ==
                          1
                      ? ColorsX.appBarColor
                      : ColorsX.buttonBackground,
                ),
                child: Align(
                  alignment: Alignment.center,
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 15.0),
                    child: globalWidgets.myTextRaleway(context, "Share QR ",
                        ColorsX.white, 0, 0, 0, 0, FontWeight.w600, 17),
                  ),
                ),
              ),
            ),
          ],
        ), //
        btnOkOnPress: () async {
          if (FirebaseAuth.instance.currentUser == null) {
            Get.toNamed(Routes.INITIAL_SCREEN);
          } else {
            Get.toNamed(Routes.ALL_SURVEYS);
          }
        },
        btnOkIcon: Icons.check_circle,
        btnOkColor: ColorsX.appBarColor)
      ..show();
  }

  void addMapToSubcollection(DocumentReference parentDocRef,
      String subcollectionName, Map<String, dynamic> data) {
    CollectionReference subcollectionRef =
        parentDocRef.collection(subcollectionName);
    subcollectionRef.add(data);
  }
}

class CheckboxListTileModel {
  int id;
  String title;
  bool isChecked;
  TextEditingController textCtl = TextEditingController();

  CheckboxListTileModel(
      {required this.id, required this.title, required this.isChecked});
}
