import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:snap_poll/global/global_variables.dart';
import 'package:snap_poll/global/global_widgets.dart';
import 'package:snap_poll/routes/app_pages.dart';
import 'package:snap_poll/widget/drawer_widget.dart';

import '../global/colors.dart';
import '../global/size_config.dart';

class CreateSurveyQuestion extends StatefulWidget {
  const CreateSurveyQuestion({Key? key}) : super(key: key);

  @override
  _CreateSurveyQuestionState createState() => _CreateSurveyQuestionState();
}

class _CreateSurveyQuestionState extends State<CreateSurveyQuestion> {
  GlobalWidgets globalWidgets = GlobalWidgets();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController sectionAddCtl = TextEditingController();
  TextEditingController shortDescriptionCtl = TextEditingController();
  String _groupValue = 'Any';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: body(context),
      floatingActionButton: Container(
        padding: EdgeInsets.only(bottom: 16.0, right: 8, left: 8),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              FloatingActionButton.extended(
                backgroundColor: ColorsX.appBarColor,
                heroTag: 'section',
                onPressed: () => createSectionDialog(context, sectionAddCtl),
                icon: Icon(Icons.safety_divider),
                label: globalWidgets.myTextRaleway(context, 'Add S',
                    ColorsX.white, 0, 0, 0, 0, FontWeight.w500, 14),
              ),
              FloatingActionButton.extended(
                backgroundColor: ColorsX.appBarColor,
                heroTag: 'bottom_sheet',
                onPressed: _modalSheet,
                icon: Icon(Icons.question_answer_outlined),
                label: globalWidgets.myTextRaleway(context, 'Add Q',
                    ColorsX.white, 0, 0, 0, 0, FontWeight.w500, 14),
              ),
              FloatingActionButton.extended(
                backgroundColor: ColorsX.appBarColor,
                heroTag: 'jumping_rules',
                onPressed: () =>
                    createJumpingRulesDialog(context, sectionAddCtl),
                icon: Icon(Icons.assist_walker),
                label: globalWidgets.myTextRaleway(context, 'Add Jumping Rules',
                    ColorsX.white, 0, 0, 0, 0, FontWeight.w500, 14),
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      drawer: DrawerWidget(context),
      key: _scaffoldKey,
      appBar: AppBar(
        backgroundColor: ColorsX.appBarColor,
        centerTitle: true,
        actions: [
          Align(
            alignment: Alignment.center,
            child: submitform(context),
          )
        ],
        leading: IconButton(
          icon: Icon(
            Icons.menu_rounded,
            color: ColorsX.white,
          ),
          onPressed: () => _scaffoldKey.currentState
              ?.openDrawer(), //Scaffold.of(context).openDrawer(),
        ),
      ),
    );
  }

  body(BuildContext context) {
    return Container(
      width: SizeConfig.screenWidth,
      height: SizeConfig.screenHeight,
      decoration: const BoxDecoration(color: ColorsX.white),
      child: ListView.builder(
        itemCount: GlobalWidgets.pwdWidgets.length,
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        itemBuilder: (context, index) => (GlobalWidgets.pwdWidgets[index]),
      ),
    );
  }

  submitform(BuildContext context) {
    return Visibility(
      visible: GlobalWidgets.pwdWidgets.length != 0,
      child: GestureDetector(
        onTap: () async {
          debugPrint('submit tapped');
          shortDescriptionDialog(context, shortDescriptionCtl);
        },
        child: Container(
          height: 40,
          margin: EdgeInsets.only(left: 20, right: 20, top: 0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(20.0)),
            color: ColorsX.buttonBackground,
          ),
          child: Align(
            alignment: Alignment.center,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 20),
              child: globalWidgets.myTextRaleway(context, "Submit",
                  ColorsX.white, 0, 0, 0, 0, FontWeight.w600, 17),
            ),
          ),
        ),
      ),
    );
  }

  shortDescriptionDialog(
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
        body: Column(
          children: [
            globalWidgets.myTextRaleway(context, "Add Short Description",
                ColorsX.black, 10, 0, 0, 0, FontWeight.w600, 18),
            globalWidgets.myTextRaleway(
                context,
                "This will help people to find your survey.",
                ColorsX.subBlack,
                10,
                0,
                0,
                20,
                FontWeight.w400,
                12),
            globalWidgets.myTextField(
                TextInputType.text, ctl, false, 'Write description here'),
          ],
        ),
        btnCancelOnPress: () {},
        btnCancelColor: ColorsX.subBlack,
        btnOkText: 'Done',
        buttonsTextStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
        btnCancelText: 'Cancel',
        btnOkOnPress: () async {
          debugPrint('OnClcik');
          GlobalWidgets.hideKeyboard(context);
          if (ctl.text.isEmpty) {
            GlobalWidgets.showToast('Please give a short description');
          } else {
            GlobalWidgets.showProgressLoader('');
            var collection = FirebaseFirestore.instance.collection('surveys');
            Map<String, dynamic> map = {
              'title': GlobalVariables.TITLE_OF_SURVEY,
              'short_description': shortDescriptionCtl.text,
              'questions': GlobalVariables.LIST_OF_ALL_QUESTIONS,
              'sections': GlobalVariables.SECTIONS_LIST
            };
            var docRef = await collection.add(map);
            var documentId = docRef.id;

            GlobalWidgets.hideProgressLoader();
            if (documentId.toString().isEmpty) {
              GlobalWidgets.showToast('Survey not saved. Try again');
            } else {
              var resultsCollectionRef = FirebaseFirestore.instance
                  .collection('surveys/$documentId/results');
              await resultsCollectionRef
                  .doc('questionsID')
                  .set({'questions': GlobalVariables.LIST_OF_ALL_QUESTIONS});
              GlobalVariables.idOfSurvey = documentId;
              Get.toNamed(Routes.QRCODE_SCREEN);
            }
          }
        },
        onDismissCallback: (type) {
          debugPrint('Dialog Dismiss from callback $type');
        })
      ..show();
  }

  _modalSheet() {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: new Icon(Icons.download_done),
                title: globalWidgets.myTextRaleway(context, 'Yes / No',
                    ColorsX.black, 0, 0, 0, 0, FontWeight.w400, 14),
                onTap: () {
                  Get.back();
                  GlobalVariables.QUESTION_TYPE = "Yes No";
                  Get.toNamed(Routes.EDIT_QUESTION_SCREEN);
                },
              ),
              ListTile(
                leading: new Icon(Icons.radio),
                title: globalWidgets.myTextRaleway(context, 'Single Choice',
                    ColorsX.black, 0, 0, 0, 0, FontWeight.w400, 14),
                onTap: () {
                  Get.back();
                  GlobalVariables.QUESTION_TYPE = "Single Choice";
                  Get.toNamed(Routes.EDIT_QUESTION_SCREEN);
                  // GlobalWidgets.pwdWidgets.add(SingleChoice());
                },
              ),
              ListTile(
                leading: new Icon(Icons.check_box),
                title: globalWidgets.myTextRaleway(context, 'Multiple Choice',
                    ColorsX.black, 0, 0, 0, 0, FontWeight.w400, 14),
                onTap: () {
                  Get.back();
                  GlobalVariables.QUESTION_TYPE = "Multiple Choice";
                  Get.toNamed(Routes.EDIT_QUESTION_SCREEN);
                },
              ),
              ListTile(
                leading: new Icon(Icons.trip_origin),
                title: globalWidgets.myTextRaleway(context, 'Range',
                    ColorsX.black, 0, 0, 0, 0, FontWeight.w400, 14),
                onTap: () {
                  Get.back();
                  GlobalVariables.QUESTION_TYPE = "Range";
                  Get.toNamed(Routes.EDIT_QUESTION_SCREEN);
                },
              ),
              ListTile(
                leading: new Icon(Icons.linear_scale),
                title: globalWidgets.myTextRaleway(context, 'Linear Scale',
                    ColorsX.black, 0, 0, 0, 0, FontWeight.w400, 14),
                onTap: () {
                  Get.back();
                  GlobalVariables.QUESTION_TYPE = "Linear Scale";
                  Get.toNamed(Routes.EDIT_QUESTION_SCREEN);
                },
              ),
              ListTile(
                leading: new Icon(Icons.star),
                title: globalWidgets.myTextRaleway(context, 'Rating',
                    ColorsX.black, 0, 0, 0, 0, FontWeight.w400, 14),
                onTap: () {
                  Get.back();
                  GlobalVariables.QUESTION_TYPE = "Rating";
                  Get.toNamed(Routes.EDIT_QUESTION_SCREEN);
                },
              ),
            ],
          );
        });
  }

  createSectionDialog(
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
        body: Column(
          children: [
            globalWidgets.myTextRaleway(context, "Add Section", ColorsX.black,
                10, 0, 0, 0, FontWeight.w600, 18),
            globalWidgets.myTextRaleway(
                context,
                "Create section to categorise the question",
                ColorsX.subBlack,
                10,
                0,
                0,
                20,
                FontWeight.w400,
                12),
            globalWidgets.myTextField(
                TextInputType.text, ctl, false, 'Write section name here'),
          ],
        ),
        btnCancelOnPress: () {},
        btnCancelColor: ColorsX.subBlack,
        btnOkText: 'Create',
        buttonsTextStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
        btnCancelText: 'Cancel',
        btnOkOnPress: () {
          debugPrint('OnClcik');
          GlobalWidgets.hideKeyboard(context);
          _addSectionToList(context);
        },
        onDismissCallback: (type) {
          debugPrint('Dialog Dismiss from callback $type');
        })
      ..show();
  }

  createJumpingRulesDialog(
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
        body: Column(
          children: [
            globalWidgets.myTextRaleway(context, "Add Jumping Rule",
                ColorsX.black, 10, 0, 0, 0, FontWeight.w600, 18),
            globalWidgets.myTextRaleway(context, "Create Jumping Rule",
                ColorsX.subBlack, 10, 0, 0, 20, FontWeight.w400, 12),
            globalWidgets.myTextRaleway(context, "For YES", ColorsX.subBlack,
                10, 0, 0, 0, FontWeight.bold, 12),
            globalWidgets.myTextField(TextInputType.text, ctl, false,
                'Write which section it should jump for YES.'),
            globalWidgets.myTextRaleway(context, "For NO", ColorsX.subBlack, 20,
                0, 0, 0, FontWeight.bold, 12),
            globalWidgets.myTextField(TextInputType.text, ctl, false,
                'Write which section it should jump for NO.'),
          ],
        ),
        btnCancelOnPress: () {},
        btnCancelColor: ColorsX.subBlack,
        btnOkText: 'Create',
        buttonsTextStyle: TextStyle(fontSize: 13, fontWeight: FontWeight.w400),
        btnCancelText: 'Cancel',
        btnOkOnPress: () {
          debugPrint('OnClcik');
          GlobalWidgets.hideKeyboard(context);
          _addSectionToList(context);
        },
        onDismissCallback: (type) {
          debugPrint('Dialog Dismiss from callback $type');
        })
      ..show();
  }

  _addSectionToList(BuildContext context) {
    if (GlobalVariables.SECTIONS_LIST.isEmpty) {
      GlobalVariables.SECTIONS_LIST.add(sectionAddCtl.text);
      GlobalWidgets.successDialog(
          'Done', 'Section Created Successfully', context);
    } else if (GlobalVariables.SECTIONS_LIST.contains(sectionAddCtl.text)) {
      GlobalWidgets.showToast('This section already exists');
    } else {
      GlobalVariables.SECTIONS_LIST.add(sectionAddCtl.text);
      GlobalWidgets.successDialog(
          'Done', 'Section Created Successfully', context);
    }
  }
}
