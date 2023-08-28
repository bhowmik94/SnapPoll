import 'dart:collection';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:get/get.dart';
import 'package:snap_poll/global/global_variables.dart';
import 'package:snap_poll/global/global_widgets.dart';
import 'package:snap_poll/routes/app_pages.dart';

import '../global/colors.dart';
import '../global/size_config.dart';

class EditQuestionScreen extends StatefulWidget {
  const EditQuestionScreen({Key? key}) : super(key: key);
  @override
  _EditQuestionScreenState createState() => _EditQuestionScreenState();
}

class _EditQuestionScreenState extends State<EditQuestionScreen> {
  GlobalWidgets globalWidgets = GlobalWidgets();
  TextEditingController questionCtl = TextEditingController();
  TextEditingController optionOneCtl = TextEditingController();
  TextEditingController optionTwoCtl = TextEditingController();
  TextEditingController optionThreeCtl = TextEditingController();

  // static String sectionValue = "Select Section";
  String _groupValue = 'Any';
  RxString questionText = GlobalVariables.QUESTION_TYPE == "Single Choice"
      ? 'Add your question here'.tr.obs
      : GlobalVariables.QUESTION_TYPE == "Yes No"
          ? 'Add your question here'.tr.obs
          : GlobalVariables.QUESTION_TYPE == "Open Text"
              ? 'Add your question here'.tr.obs
              : GlobalVariables.QUESTION_TYPE == "Range"
                  ? 'Add your question here'.tr.obs
                  : GlobalVariables.QUESTION_TYPE == "Rating"
                      ? 'Add your question here'.tr.obs
                      : GlobalVariables.QUESTION_TYPE == "Linear Scale"
                          ? 'Add your question here'.tr.obs
                          : "Add your question here".tr.obs;
  RxString optionOneText = "This is option ".obs;
  RxString optionTwoText = "This is option ".obs;
  RxString optionThreeText = "This is option ".obs;
  List<String> listOfOptions = [];
  List<RadioListTileModel> radioListTiles = []; // List to hold checkbox models
  List<CheckboxListTileModel> checkboxListTiles = [];
  int counter = 0; // Counter for unique checkbox IDs
  String start_age = '';
  String end_age = '';
  RangeValues _currentRangeValues = RangeValues(1, 100);
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          Get.toNamed(Routes.CREATE_SURVEY_QUESTION);
          return false;
        },
        child: Container(
          child: Stack(
            children: [
              Container(
                height: SizeConfig.screenHeight * .15,
                decoration: BoxDecoration(color: ColorsX.appBarColor),
              ),
              Container(
                margin: EdgeInsets.only(top: SizeConfig.screenHeight * .16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    question(context),
                    globalWidgets.myTextRaleway(
                        context,
                        'Select your section to categorise the question'.tr,
                        ColorsX.black,
                        20,
                        20,
                        20,
                        10,
                        FontWeight.w500,
                        14),
                    sectionDropdown(),
                    saveQuestionButton(context)
                  ],
                ),
              ),
              Visibility(
                visible: GlobalVariables.QUESTION_TYPE == 'Single Choice' ||
                    GlobalVariables.QUESTION_TYPE == 'Multiple Choice',
                child: Container(
                  padding: EdgeInsets.all(20),
                  child: Align(
                    alignment: Alignment.bottomRight,
                    child: FloatingActionButton.extended(
                      backgroundColor: ColorsX.appBarColor,
                      heroTag: 'bottom_sheet',
                      onPressed: () {
                        if (GlobalVariables.QUESTION_TYPE == 'Single Choice') {
                          setState(() {
                            radioListTiles.add(RadioListTileModel(
                              // Create a new RadioListTile model and add it to the list
                              id: counter.obs,
                              title: "Edit option".tr.obs,
                            ));
                            counter++;
                          });
                        } else if (GlobalVariables.QUESTION_TYPE ==
                            'Multiple Choice') {
                          setState(() {
                            checkboxListTiles.add(CheckboxListTileModel(
                              // Create a new checkbox model and add it to the list
                              id: counter.obs,
                              title: "Edit option".tr.obs,
                              isChecked: false,
                            ));
                            counter++;
                          });
                        }
                      },
                      icon: Icon(Icons.add),
                      label: globalWidgets.myTextRaleway(
                          context,
                          'Add Options'.tr,
                          ColorsX.white,
                          0,
                          0,
                          0,
                          0,
                          FontWeight.w500,
                          14),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ));
  }

  sectionDropdown() {
    return Container(
      width: SizeConfig.screenWidth,
      height: 50,
      margin: const EdgeInsets.only(top: 5, right: 20, left: 20),
      decoration: BoxDecoration(
        border: Border.all(color: ColorsX.black),
        borderRadius: const BorderRadius.all(Radius.circular(20)),
      ),
      child: DropdownButton<String>(
        isExpanded: true,
        hint: Text(GlobalVariables.sectionValue),
        underline: SizedBox(),
        value: GlobalVariables.sectionValue,
        //elevation: 5,
        style: const TextStyle(color: Colors.black, fontSize: 14),
        icon: Container(
          margin: const EdgeInsets.only(right: 10),
          child: const Icon(
            Icons.arrow_drop_down,
            color: ColorsX.black,
          ),
        ),
        items: GlobalVariables.SECTIONS_LIST
            .map<DropdownMenuItem<String>>((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Padding(
              padding: EdgeInsets.only(right: SizeConfig.marginVerticalXXsmall),
              child: globalWidgets.myTextRaleway(context, value, ColorsX.black,
                  0, 10, 0, 0, FontWeight.w400, 15),
            ),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            GlobalVariables.sectionValue = value!;
            print(GlobalVariables.sectionValue);
          });
        },
      ),
    );
  }

  Widget question(BuildContext context) {
    return GlobalVariables.QUESTION_TYPE == "Single Choice"
        ? Column(
            children: [
              Visibility(
                visible: true,
                child: Align(
                    alignment: Alignment.centerLeft,
                    child: globalWidgets.myTextRaleway(context, GlobalVariables.sectionValue,
                        ColorsX.black, 10, 10, 10, 0, FontWeight.w400, 12)),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Obx(() => Container(
                      width: SizeConfig.screenWidth * .90,
                      child: globalWidgets.myTextRaleway(
                          context,
                          questionText.value,
                          Colors.black,
                          10,
                          10,
                          10,
                          10,
                          FontWeight.w500,
                          17))),
                  Expanded(child: Container()),
                  GestureDetector(
                    onTap: () {
                      openEditQuestionDilog(context, questionCtl,
                          'Edit question', 'Add a question you want to ask');
                    },
                    child: Container(
                      margin: const EdgeInsets.only(top: 10),
                      child: const Icon(
                        Icons.edit,
                        color: ColorsX.appBarColor,
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                ],
              ),
              ListView.builder(
                shrinkWrap: true,
                itemCount: radioListTiles.length,
                itemBuilder: (context, index) {
                  return RadioListTile<String>(
                    controlAffinity: ListTileControlAffinity.leading,
                    value: radioListTiles[index].title.value,
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
                              radioListTiles[index].title.value,
                              ColorsX.black,
                              0,
                              0,
                              0,
                              0,
                              FontWeight.w400,
                              16),
                        ),
                        Expanded(child: Container()),
                        GestureDetector(
                          onTap: () {
                            openEditOptionDilog(
                                context,
                                radioListTiles[index].textCtl,
                                'Edit option'.tr,
                                'Edit your first option',
                                index);
                          },
                          child: Container(
                            margin: const EdgeInsets.only(top: 10),
                            child: const Icon(
                              Icons.edit,
                              //   color: ColorsX.appBarColor,
                            ),
                          ),
                        ),
                        Container(
                          width: 10,
                        ),
                        GestureDetector(
                          onTap: () {
                            openDeleteDilog(context, index);
                          },
                          child: Container(
                            margin: const EdgeInsets.only(top: 10),
                            child: const Icon(
                              Icons.delete,
                              // color: ColorsX.appBarColor,
                            ),
                          ),
                        ),
                        Expanded(child: Container()),
                      ],
                    ),
                    onChanged: (newValue) =>
                        setState(() => _groupValue = newValue!),
                  );
                },
              ),
            ],
          )
        : GlobalVariables.QUESTION_TYPE == "Yes No"
            ? Column(
                children: [
                  Visibility(
                    visible: true,
                    child: Align(
                        alignment: Alignment.centerLeft,
                        child: globalWidgets.myTextRaleway(
                            context,
                            GlobalVariables.sectionValue,
                            ColorsX.black,
                            10,
                            10,
                            10,
                            0,
                            FontWeight.w400,
                            12)),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Obx(() => Container(
                          width: SizeConfig.screenWidth * .90,
                          child: globalWidgets.myTextRaleway(
                              context,
                              questionText.value,
                              Colors.black,
                              10,
                              10,
                              10,
                              10,
                              FontWeight.w500,
                              17))),
                      Expanded(child: Container()),
                      GestureDetector(
                        onTap: () {
                          openEditQuestionDilog(
                              context,
                              questionCtl,
                              'Edit question',
                              'Add a question you want to ask');
                        },
                        child: Container(
                          margin: const EdgeInsets.only(top: 10),
                          child: const Icon(
                            Icons.edit,
                            color: ColorsX.appBarColor,
                          ),
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                    ],
                  ),
                  RadioListTile<String>(
                    value: 'Yes',
                    groupValue: _groupValue,
                    title: globalWidgets.myTextRaleway(context, 'Yes'.tr,
                        Colors.black, 0, 0, 0, 0, FontWeight.w400, 17),
                    onChanged: (newValue) =>
                        setState(() => _groupValue = newValue!),
                    activeColor: ColorsX.appBarColor,
                    selected: false,
                  ),
                  RadioListTile<String>(
                    value: 'No',
                    groupValue: _groupValue,
                    title: globalWidgets.myTextRaleway(context, 'No'.tr,
                        Colors.black, 0, 0, 0, 0, FontWeight.w400, 17),
                    onChanged: (newValue) =>
                        setState(() => _groupValue = newValue!),
                    activeColor: ColorsX.appBarColor,
                    selected: false,
                  ),
                ],
              )
            : GlobalVariables.QUESTION_TYPE == "Open Text"
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Visibility(
                        visible: true,
                        child: Align(
                            alignment: Alignment.centerLeft,
                            child: globalWidgets.myTextRaleway(
                                context,
                                GlobalVariables.sectionValue,
                                ColorsX.black,
                                10,
                                10,
                                10,
                                0,
                                FontWeight.w400,
                                12)),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Obx(() => Container(
                              width: SizeConfig.screenWidth * .90,
                              child: globalWidgets.myTextRaleway(
                                  context,
                                  questionText.value,
                                  Colors.black,
                                  10,
                                  10,
                                  10,
                                  10,
                                  FontWeight.w500,
                                  17))),
                          Expanded(child: Container()),
                          GestureDetector(
                            onTap: () {
                              openEditQuestionDilog(
                                  context,
                                  questionCtl,
                                  'Edit question',
                                  'Add a question you want to ask');
                            },
                            child: Container(
                              margin: const EdgeInsets.only(top: 10),
                              child: const Icon(
                                Icons.edit,
                                color: ColorsX.appBarColor,
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                        ],
                      ),
                      const TextField(
                        decoration: InputDecoration(
                          hintText: "",
                          hintStyle: TextStyle(color: Colors.black54),
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(vertical: 40),
                        ),
                      ),
                    ],
                  )
                : GlobalVariables.QUESTION_TYPE == "Range"
                    ? Column(
                        children: [
                          Visibility(
                            visible: true,
                            child: Align(
                                alignment: Alignment.centerLeft,
                                child: globalWidgets.myTextRaleway(
                                    context,
                                    GlobalVariables.sectionValue,
                                    ColorsX.black,
                                    10,
                                    10,
                                    10,
                                    0,
                                    FontWeight.w400,
                                    12)),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Obx(() => Container(
                                  width: SizeConfig.screenWidth * .90,
                                  child: globalWidgets.myTextRaleway(
                                      context,
                                      questionText.value,
                                      Colors.black,
                                      10,
                                      10,
                                      10,
                                      10,
                                      FontWeight.w500,
                                      17))),
                              Expanded(child: Container()),
                              GestureDetector(
                                onTap: () {
                                  openEditQuestionDilog(
                                      context,
                                      questionCtl,
                                      'Edit question',
                                      'Add a question you want to ask');
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(top: 10),
                                  child: const Icon(
                                    Icons.edit,
                                    color: ColorsX.appBarColor,
                                  ),
                                ),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                            ],
                          ),
                          ageLimit(context),
                        ],
                      )
                    : GlobalVariables.QUESTION_TYPE == "Rating"
                        ? Column(
                            children: [
                              Visibility(
                                visible: true,
                                child: Align(
                                    alignment: Alignment.centerLeft,
                                    child: globalWidgets.myTextRaleway(
                                        context,
                                        GlobalVariables.sectionValue,
                                        ColorsX.black,
                                        10,
                                        10,
                                        10,
                                        0,
                                        FontWeight.w400,
                                        12)),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Obx(() => Container(
                                      width: SizeConfig.screenWidth * .90,
                                      child: globalWidgets.myTextRaleway(
                                          context,
                                          questionText.value,
                                          Colors.black,
                                          10,
                                          10,
                                          10,
                                          10,
                                          FontWeight.w500,
                                          17))),
                                  Expanded(child: Container()),
                                  GestureDetector(
                                    onTap: () {
                                      openEditQuestionDilog(
                                          context,
                                          questionCtl,
                                          'Edit question',
                                          'Add a question you want to ask');
                                    },
                                    child: Container(
                                      margin: const EdgeInsets.only(top: 10),
                                      child: const Icon(
                                        Icons.edit,
                                        color: ColorsX.appBarColor,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                ],
                              ),
                              ratingBar(context),
                            ],
                          )
                        : GlobalVariables.QUESTION_TYPE == "Linear Scale"
                            ? Column(
                                children: [
                                  Visibility(
                                    visible: true,
                                    child: Align(
                                        alignment: Alignment.centerLeft,
                                        child: globalWidgets.myTextRaleway(
                                            context,
                                            GlobalVariables.sectionValue,
                                            ColorsX.black,
                                            10,
                                            10,
                                            10,
                                            0,
                                            FontWeight.w400,
                                            12)),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Obx(() => Container(
                                          width: SizeConfig.screenWidth * .90,
                                          child: globalWidgets.myTextRaleway(
                                              context,
                                              questionText.value,
                                              Colors.black,
                                              10,
                                              10,
                                              10,
                                              10,
                                              FontWeight.w500,
                                              17))),
                                      Expanded(child: Container()),
                                      GestureDetector(
                                        onTap: () {
                                          openEditQuestionDilog(
                                              context,
                                              questionCtl,
                                              'Edit question',
                                              'Add a question you want to ask');
                                        },
                                        child: Container(
                                          margin:
                                              const EdgeInsets.only(top: 10),
                                          child: const Icon(
                                            Icons.edit,
                                            color: ColorsX.appBarColor,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                    ],
                                  ),
                                  scaleRating(context),
                                ],
                              )
                            : GlobalVariables.QUESTION_TYPE == "Multiple Choice"
                                ? Column(
                                    children: [
                                      Visibility(
                                        visible: true,
                                        child: Align(
                                            alignment: Alignment.centerLeft,
                                            child: globalWidgets.myTextRaleway(
                                                context,
                                                GlobalVariables.sectionValue,
                                                ColorsX.black,
                                                10,
                                                10,
                                                10,
                                                0,
                                                FontWeight.w400,
                                                12)),
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Obx(() => Container(
                                              width:
                                                  SizeConfig.screenWidth * .90,
                                              child:
                                                  globalWidgets.myTextRaleway(
                                                      context,
                                                      questionText.value,
                                                      Colors.black,
                                                      10,
                                                      10,
                                                      10,
                                                      10,
                                                      FontWeight.w500,
                                                      17))),
                                          Expanded(child: Container()),
                                          GestureDetector(
                                            onTap: () {
                                              openEditQuestionDilog(
                                                  context,
                                                  questionCtl,
                                                  'Edit question',
                                                  'Add a question you want to ask');
                                            },
                                            child: Container(
                                              margin: const EdgeInsets.only(
                                                  top: 10),
                                              child: const Icon(
                                                Icons.edit,
                                                color: ColorsX.appBarColor,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                        ],
                                      ),
                                      ListView.builder(
                                        shrinkWrap: true,
                                        itemCount: checkboxListTiles.length,
                                        itemBuilder: (context, index) {
                                          return CheckboxListTile(
                                            controlAffinity:
                                                ListTileControlAffinity.leading,
                                            value: checkboxListTiles[index]
                                                .isChecked,
                                            title: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Text(checkboxListTiles[index]
                                                    .title
                                                    .value),
                                                Expanded(child: Container()),
                                                GestureDetector(
                                                  onTap: () {
                                                    openEditOptionDilog(
                                                        context,
                                                        checkboxListTiles[index]
                                                            .textCtl,
                                                        'Edit option'.tr,
                                                        'Edit your first option',
                                                        index);
                                                  },
                                                  child: Container(
                                                    margin:
                                                        const EdgeInsets.only(
                                                            top: 10),
                                                    child: const Icon(
                                                      Icons.edit,
                                                      color:
                                                          ColorsX.appBarColor,
                                                    ),
                                                  ),
                                                ),
                                                Container(
                                                  width: 30,
                                                ),
                                                GestureDetector(
                                                  onTap: () {
                                                    openDeleteDilog(
                                                        context, index);
                                                  },
                                                  child: Container(
                                                    margin:
                                                        const EdgeInsets.only(
                                                            top: 10),
                                                    child: const Icon(
                                                      Icons.delete,
                                                      color:
                                                          ColorsX.appBarColor,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            onChanged: (bool? value) {
                                              setState(() {
                                                checkboxListTiles[index]
                                                    .isChecked = value!;
                                              });
                                            },
                                          );
                                        },
                                      ),
                                      // CheckboxListTile(
                                      //   title: Obx(()=>globalWidgets.myTextRaleway(context, optionOneText.value, Colors.black,
                                      //       0, 0, 0, 0, FontWeight.w400, 17),),
                                      //   activeColor: Colors.grey,
                                      //   value: false,
                                      //   contentPadding: EdgeInsets.zero,
                                      //   onChanged: (value) {
                                      //     setState(() {
                                      //       value = value!;
                                      //     });
                                      //   },
                                      //   controlAffinity: ListTileControlAffinity.leading,
                                      // ),
                                    ],
                                  )
                                : Container();
  }

  openEditQuestionDilog(BuildContext context, TextEditingController ctl,
      String title, String description) {
    return AwesomeDialog(
        context: context,
        animType: AnimType.LEFTSLIDE,
        headerAnimationLoop: false,
        dialogType: DialogType.SUCCES,
        dismissOnTouchOutside: false,
        dismissOnBackKeyPress: false,
        closeIcon: Container(),
        // closeIcon: IconButton(icon : Icon(Icons.close, color: ColorsX.light_orange,),onPressed: () {
        //   Get.back();
        //   // Get.toNamed(Routes.LOGIN_SCREEN);
        // },),
        showCloseIcon: true,
        title: title,
        desc: description, //
        body: globalWidgets.myTextField(TextInputType.text, ctl, false,
            'Edit here'.tr), // \n Save or remember ID to Log In' ,
        btnCancelOnPress: () {},
        btnCancelColor: ColorsX.subBlack,
        btnOkText: 'Edit'.tr,
        buttonsTextStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
        btnCancelText: 'Cancel'.tr,
        btnOkOnPress: () {
          debugPrint('OnClcik');
          GlobalWidgets.hideKeyboard(context);
          if (GlobalVariables.QUESTION_TYPE == "Single Choice") {
            questionText.value = questionCtl.text.isEmpty
                ? questionText.value
                : questionCtl.text;
            // optionOneText.value =
            // optionOneCtl.text.isEmpty ? optionOneText.value : optionOneCtl.text;
            // optionTwoText.value =
            // optionTwoCtl.text.isEmpty ? optionTwoText.value : optionTwoCtl.text;
            // optionThreeText.value =
            // optionThreeCtl.text.isEmpty ? optionThreeText.value : optionThreeCtl
            //     .text;
          } else if (GlobalVariables.QUESTION_TYPE == "Yes No") {
            questionText.value = questionCtl.text.isEmpty
                ? questionText.value
                : questionCtl.text;
          } else if (GlobalVariables.QUESTION_TYPE == "Multiple Choice") {
            questionText.value = questionCtl.text.isEmpty
                ? questionText.value
                : questionCtl.text;
            // optionOneText.value =
            // optionOneCtl.text.isEmpty ? optionOneText.value : optionOneCtl.text;
            // optionTwoText.value =
            // optionTwoCtl.text.isEmpty ? optionTwoText.value : optionTwoCtl.text;
            // optionThreeText.value =
            // optionThreeCtl.text.isEmpty ? optionThreeText.value : optionThreeCtl
            //     .text;
          } else if (GlobalVariables.QUESTION_TYPE == "Range") {
            questionText.value = questionCtl.text.isEmpty
                ? questionText.value
                : questionCtl.text;
          } else if (GlobalVariables.QUESTION_TYPE == "Rating") {
            questionText.value = questionCtl.text.isEmpty
                ? questionText.value
                : questionCtl.text;
          } else if (GlobalVariables.QUESTION_TYPE == "Linear Scale") {
            questionText.value = questionCtl.text.isEmpty
                ? questionText.value
                : questionCtl.text;
          } else if (GlobalVariables.QUESTION_TYPE == "Open Text") {
            questionText.value = questionCtl.text.isEmpty
                ? questionText.value
                : questionCtl.text;
          }
        },
        onDismissCallback: (type) {
          debugPrint('Dialog Dismiss from callback $type');
        })
      ..show();
  }

  openDeleteDilog(BuildContext context, int index) {
    return AwesomeDialog(
        context: context,
        animType: AnimType.LEFTSLIDE,
        headerAnimationLoop: false,
        dialogType: DialogType.SUCCES,
        dismissOnTouchOutside: false,
        dismissOnBackKeyPress: false,
        closeIcon: Container(),
        // closeIcon: IconButton(icon : Icon(Icons.close, color: ColorsX.light_orange,),onPressed: () {
        //   Get.back();
        //   // Get.toNamed(Routes.LOGIN_SCREEN);
        // },),
        showCloseIcon: true,
        title: "Delete".tr,
        desc: "Delete this option", //
        body: globalWidgets.myTextRaleway(
            context,
            'Delete this option?'.tr,
            Colors.black,
            0,
            0,
            0,
            0,
            FontWeight.w400,
            17), // \n Save or remember ID to Log In' ,
        btnCancelOnPress: () {},
        btnCancelColor: ColorsX.subBlack,
        btnOkText: 'Delete'.tr,
        buttonsTextStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
        btnCancelText: 'Cancel'.tr,
        btnOkOnPress: () {
          debugPrint('OnClcik');
          setState(() {
            if (GlobalVariables.QUESTION_TYPE == 'Single Choice') {
              radioListTiles.removeAt(index);
              counter--;
              for (RadioListTileModel c in radioListTiles) {
                c.id = radioListTiles.indexOf(c).obs;
              }
            } else {
              checkboxListTiles.removeAt(index);
              counter--;
              for (CheckboxListTileModel c in checkboxListTiles) {
                c.id = checkboxListTiles.indexOf(c).obs;
              }
            }
          });
        },
        onDismissCallback: (type) {
          debugPrint('Dialog Dismiss from callback $type');
        })
      ..show();
  }

  openEditOptionDilog(BuildContext context, TextEditingController ctl,
      String title, String description, int index) {
    return AwesomeDialog(
        context: context,
        animType: AnimType.LEFTSLIDE,
        headerAnimationLoop: false,
        dialogType: DialogType.SUCCES,
        dismissOnTouchOutside: false,
        dismissOnBackKeyPress: false,
        closeIcon: Container(),
        // closeIcon: IconButton(icon : Icon(Icons.close, color: ColorsX.light_orange,),onPressed: () {
        //   Get.back();
        //   // Get.toNamed(Routes.LOGIN_SCREEN);
        // },),
        showCloseIcon: true,
        title: title,
        desc: description, //
        body: globalWidgets.myTextField(TextInputType.text, ctl, false,
            'Edit here'.tr), // \n Save or remember ID to Log In' ,
        btnCancelOnPress: () {},
        btnCancelColor: ColorsX.subBlack,
        btnOkText: 'Edit'.tr,
        buttonsTextStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
        btnCancelText: 'Cancel'.tr,
        btnOkOnPress: () {
          debugPrint('OnClcik');
          GlobalWidgets.hideKeyboard(context);
          if (GlobalVariables.QUESTION_TYPE == 'Single Choice') {
            setState(() {
              radioListTiles[index].title.value =
                  radioListTiles[index].textCtl.text;
            });
          } else if (GlobalVariables.QUESTION_TYPE == 'Multiple Choice') {
            setState(() {
              checkboxListTiles[index].title.value =
                  checkboxListTiles[index].textCtl.text;
            });
          }
        },
        onDismissCallback: (type) {
          debugPrint('Dialog Dismiss from callback $type');
        })
      ..show();
  }

  saveQuestionButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (GlobalVariables.sectionValue == "Select Section") {
          GlobalWidgets.showToast("Please select section".tr);
        } else {
          if (GlobalVariables.QUESTION_TYPE == "Single Choice") {
            singleChoiceQuestionSave(context);
          } else if (GlobalVariables.QUESTION_TYPE == "Multiple Choice") {
            multipleChoiceQuestionSave(context);
          } else if (GlobalVariables.QUESTION_TYPE == "Yes No") {
            yesNoQuestionSave(context);
          } else if (GlobalVariables.QUESTION_TYPE == "Range") {
            rangeQuestionSave(context);
          } else if (GlobalVariables.QUESTION_TYPE == "Rating") {
            ratingQuestionSave(context);
          } else if (GlobalVariables.QUESTION_TYPE == "Linear Scale") {
            scaleRatingQuestionSave(context);
          } else if (GlobalVariables.QUESTION_TYPE == "Open Text") {
            openTextQuestionSave(context);
          }
        }
      },
      child: Container(
        width: SizeConfig.screenWidth,
        margin: const EdgeInsets.only(left: 20, right: 20, top: 30),
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
          color: ColorsX.appBarColor,
        ),
        child: Align(
          alignment: Alignment.center,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 15.0),
            child: globalWidgets.myTextRaleway(context, "SAVE QUESTION".tr,
                ColorsX.white, 0, 0, 0, 0, FontWeight.w600, 17),
          ),
        ),
      ),
    );
  }

  singleChoiceQuestionSave(BuildContext context) {
    if (questionText.value == 'Add your question here' ||
        optionOneText.value == 'This is option one' ||
        optionTwoText.value == 'This is option two' ||
        optionThreeText.value == 'This is option three') {
      GlobalWidgets.showToast('Please fill all the information');
    } else {
      for (RadioListTileModel c in radioListTiles) {
        listOfOptions.add(c.title.value);
        // ids have to be separated for counter sometimes later
      }
      Map<String, dynamic> map = {
        'question_type': GlobalVariables.QUESTION_TYPE,
        'question': questionText.value,
        'options': listOfOptions,
        'section': GlobalVariables.sectionValue
      };

      GlobalVariables.LIST_OF_ALL_QUESTIONS.add(map);
      debugPrint(GlobalVariables.LIST_OF_ALL_QUESTIONS.toString());
      setState(() {
        GlobalWidgets.pwdWidgets.add(question(context));
      });
      Get.toNamed(Routes.CREATE_SURVEY_QUESTION);
    }
  }

  multipleChoiceQuestionSave(BuildContext context) {
    if (questionText.value == 'Add your question here' ||
        optionOneText.value == 'This is option one' ||
        optionTwoText.value == 'This is option two' ||
        optionThreeText.value == 'This is option three') {
      GlobalWidgets.showToast('Please fill all the information');
    } else {
      for (CheckboxListTileModel c in checkboxListTiles) {
        listOfOptions.add(c.title.value);
      }
      Map<String, dynamic> map = {
        'question_type': GlobalVariables.QUESTION_TYPE,
        'question': questionText.value,
        'options': listOfOptions,
        'section': GlobalVariables.sectionValue
      };

      GlobalVariables.LIST_OF_ALL_QUESTIONS.add(map);
      debugPrint(GlobalVariables.LIST_OF_ALL_QUESTIONS.toString());
      setState(() {
        GlobalWidgets.pwdWidgets.add(question(context));
      });
      Get.toNamed(Routes.CREATE_SURVEY_QUESTION);
    }
  }

  openTextQuestionSave(BuildContext context) {
    if (questionText.value == 'Add your question here'.tr) {
      GlobalWidgets.showToast('Please fill all the information'.tr);
    } else {
      Map<String, dynamic> map = {
        'question_type': 'Open Text',
        'question': questionText.value,
        'section': GlobalVariables.sectionValue
      };

      GlobalVariables.LIST_OF_ALL_QUESTIONS.add(map);
      debugPrint(GlobalVariables.LIST_OF_ALL_QUESTIONS.toString());
      setState(() {
        GlobalWidgets.pwdWidgets.add(question(context));
      });
      Get.toNamed(Routes.CREATE_SURVEY_QUESTION);
    }
  }

  yesNoQuestionSave(BuildContext context) {
    if (questionText.value == 'Add your question here'.tr) {
      GlobalWidgets.showToast('Please fill all the information'.tr);
    } else {
      listOfOptions.add('Yes');
      listOfOptions.add('No');
      Map<String, dynamic> map = {
        'question_type': GlobalVariables.QUESTION_TYPE,
        'question': questionText.value,
        'options': listOfOptions,
        'section': GlobalVariables.sectionValue
      };

      GlobalVariables.LIST_OF_ALL_QUESTIONS.add(map);
      debugPrint(GlobalVariables.LIST_OF_ALL_QUESTIONS.toString());
      setState(() {
        GlobalWidgets.pwdWidgets.add(question(context));
      });
      Get.toNamed(Routes.CREATE_SURVEY_QUESTION);
    }
  }

  rangeQuestionSave(BuildContext context) {
    if (questionText.value == 'Add your question here'.tr) {
      GlobalWidgets.showToast('Please fill all the information'.tr);
    } else {
      Map<String, dynamic> map = {
        'question_type': GlobalVariables.QUESTION_TYPE,
        'question': questionText.value,
        'range_starting': start_age,
        'range_ending': end_age,
        'options': [],
        'section': GlobalVariables.sectionValue
      };

      GlobalVariables.LIST_OF_ALL_QUESTIONS.add(map);
      debugPrint(GlobalVariables.LIST_OF_ALL_QUESTIONS.toString());
      setState(() {
        GlobalWidgets.pwdWidgets.add(question(context));
      });
      Get.toNamed(Routes.CREATE_SURVEY_QUESTION);
    }
  }

  ratingQuestionSave(BuildContext context) {
    if (questionText.value == 'Add your question here'.tr) {
      GlobalWidgets.showToast('Please fill all the information'.tr);
    } else {
      Map<String, dynamic> map = {
        'question_type': GlobalVariables.QUESTION_TYPE,
        'question': questionText.value,
        'options': [],
        'section': GlobalVariables.sectionValue
      };

      GlobalVariables.LIST_OF_ALL_QUESTIONS.add(map);
      debugPrint(GlobalVariables.LIST_OF_ALL_QUESTIONS.toString());
      setState(() {
        GlobalWidgets.pwdWidgets.add(question(context));
      });
      Get.toNamed(Routes.CREATE_SURVEY_QUESTION);
    }
  }

  scaleRatingQuestionSave(BuildContext context) {
    if (questionText.value == 'Add your question here'.tr) {
      GlobalWidgets.showToast('Please fill all the information'.tr);
    } else {
      Map<String, dynamic> map = {
        'question_type': GlobalVariables.QUESTION_TYPE,
        'question': questionText.value,
        'options': [],
        'max_value': GlobalVariables.dynamicScaleValue.toString(),
        'section': GlobalVariables.sectionValue
      };

      GlobalVariables.LIST_OF_ALL_QUESTIONS.add(map);
      debugPrint(GlobalVariables.LIST_OF_ALL_QUESTIONS.toString());
      setState(() {
        GlobalWidgets.pwdWidgets.add(question(context));
      });
      Get.toNamed(Routes.CREATE_SURVEY_QUESTION);
    }
  }

  ageLimit(BuildContext context) {
    return RangeSlider(
      values: _currentRangeValues,
      min: 1,
      max: 100,
      divisions: 100,
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
        });
      },
    );
  }

  ratingBar(BuildContext context) {
    return RatingBar.builder(
      initialRating: 3,
      minRating: 1,
      direction: Axis.horizontal,
      allowHalfRating: true,
      ignoreGestures: true,
      itemCount: 5,
      itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
      itemBuilder: (context, _) => const Icon(
        Icons.star,
        color: Colors.amber,
      ),
      onRatingUpdate: (rating) {
        print(rating);
      },
    );
  }

  scaleRating(BuildContext context) {
    return Container(
      width: SizeConfig.screenWidth,
      child: Wrap(
        spacing: 8,
        // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          for (int index = 0; index < GlobalVariables.dynamicScaleValue; index++)
            scaleRatingItem(context, index, (index + 1).toString()),
        ],
      ),
    );
  }

  scaleRatingItem(BuildContext context, int index, String value) {
    return Container(
      height: 50,
      width: 30,
      decoration:
          const BoxDecoration(color: ColorsX.subBlack, shape: BoxShape.circle),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(6.0),
          child: globalWidgets.myTextRaleway(
              context, value, ColorsX.white, 0, 0, 0, 0, FontWeight.w400, 11),
        ),
      ),
    );
  }

  ageValuesRange(double start, double end) {
    debugPrint(start.toStringAsFixed(0));
    debugPrint(end.toStringAsFixed(0));
  }
}

class RadioListTileModel {
  RxInt id;
  RxString title;
  TextEditingController textCtl = TextEditingController();

  RadioListTileModel({required this.id, required this.title});
}

class CheckboxListTileModel {
  RxInt id;
  RxString title;
  bool isChecked;
  TextEditingController textCtl = TextEditingController();

  CheckboxListTileModel(
      {required this.id, required this.title, required this.isChecked});
}
