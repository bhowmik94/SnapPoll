import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:snap_poll/global/global_variables.dart';
import 'package:snap_poll/global/size_config.dart';
import 'package:snap_poll/routes/app_pages.dart';
import 'package:snap_poll/screens/initial_qr_or_signin.dart';
import 'package:snap_poll/screens/sign_in_screen.dart';

import '../global/colors.dart';
import '../global/global_widgets.dart';

class MainPage extends StatefulWidget {
  const MainPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return _MainPageState();
  }
}

class _MainPageState extends State<MainPage> {
  GlobalWidgets globalWidgets = GlobalWidgets();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController ctl = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Get.toNamed(Routes.INITIAL_SCREEN);
        return false;
      },
      child: Scaffold(
        key: _scaffoldKey,
        body: SingleChildScrollView(child: body(context)),
        // drawer: DrawerWidget(context),
        appBar: AppBar(
            backgroundColor: ColorsX.appBarColor,
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(
                Icons.qr_code_outlined,
                color: ColorsX.white,
              ),
              onPressed: () => globalWidgets
                  .scanQRCode(context), //Scaffold.of(context).openDrawer(),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  if (GlobalVariables.isEng == true) {
                    Get.updateLocale(const Locale('de', 'GER'));
                    GlobalVariables.isEng = false;
                  } else {
                    Get.updateLocale(const Locale('en', 'US'));
                    GlobalVariables.isEng = true;
                  }
                },
                style: TextButton.styleFrom(foregroundColor: Colors.white),
                child: globalWidgets.myTextRaleway(context, 'changeLang'.tr,
                    ColorsX.white, 0, 0, 0, 0, FontWeight.w700, 16),
              ),
              MaterialButton(
                  onPressed: () {
                    FirebaseAuth.instance.signOut().then((value) {
                      print("Signed Out");
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const Initial()));
                    });
                  },
                  minWidth: 20,
                  color: ColorsX.appBarColor,
                  child: const Text(
                    "Logout",
                    style: TextStyle(color: Colors.white),
                  )),
            ]
            // leading: IconButton(
            //   icon: Icon(Icons.menu_rounded, color: ColorsX.white,),
            //   onPressed: () => _scaffoldKey.currentState?.openDrawer(), //Scaffold.of(context).openDrawer(),
            // ),
            ),
      ),
    );
  }

  body(BuildContext context) {
    return Container(
      width: SizeConfig.screenWidth,
      height: SizeConfig.screenHeight * 0.8,
      decoration: const BoxDecoration(color: ColorsX.white),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/main.png',
              height: 140,
              width: 140,
              fit: BoxFit.contain,
            ),
            SizedBox(
              height: 20,
            ),
            globalWidgets.myTextRaleway(context, 'Welcome!'.tr,
                ColorsX.appBarColor, 10, 10, 10, 10, FontWeight.w700, 26),
            createRowOne(context),
            createRowTwo(context),
          ],
        ),
      ),
    );
  }

  createFormButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Get.toNamed(Routes.CREATE_FORM_OPTIONS);
      },
      child: Container(
        width: SizeConfig.screenWidth,
        margin: const EdgeInsets.only(left: 20, right: 20, top: 30),
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(10.0)),
          color: ColorsX.uBdarkestBlue,
        ),
        child: Align(
          alignment: Alignment.center,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 15.0),
            child: globalWidgets.myTextRaleway(context, 'createForm'.tr,
                ColorsX.white, 0, 0, 0, 0, FontWeight.w600, 17),
          ),
        ),
      ),
    );
  }

  createRowOne(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Get.toNamed(Routes.CARD_FORM_LAYOUT);
        if (GlobalVariables.TITLE_OF_SURVEY.isEmpty) {
          // changed, so onpop of survey creation it will ask again for title
          surveyTitleDialog(context, ctl);
        } else {
          Get.toNamed(Routes.CREATE_SURVEY_QUESTION);
        }
      },
      child: Container(
        height: SizeConfig.screenHeight * .12,
        margin: const EdgeInsets.only(left: 20, right: 20, top: 20),
        decoration: const BoxDecoration(
            color: ColorsX.greyBackground,
            borderRadius: BorderRadius.all(Radius.circular(10))),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: SizeConfig.screenWidth * .25,
              height: SizeConfig.screenHeight * .12,
              decoration: const BoxDecoration(
                  color: ColorsX.cardBlueBackground,
                  borderRadius: BorderRadius.all(Radius.circular(10))),
              child: const Icon(
                Icons.assignment_add,
                color: ColorsX.appBarColor,
                size: 50,
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                globalWidgets.myTextRaleway(context, "New Survey".tr,
                    ColorsX.fullblack, 20, 10, 0, 0, FontWeight.w600, 17),
                globalWidgets.myTextRaleway(
                    context,
                    "Create your custom survey!".tr,
                    ColorsX.subBlack,
                    20,
                    10,
                    0,
                    0,
                    FontWeight.w700,
                    13),
              ],
            ),
          ],
        ),
      ),
    );
  }

  createRowTwo(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Get.toNamed(Routes.CARD_FORM_LAYOUT);
        Get.toNamed(Routes.ALL_SURVEYS);
      },
      child: Container(
        height: SizeConfig.screenHeight * .12,
        margin: const EdgeInsets.only(left: 20, right: 20, top: 20),
        decoration: const BoxDecoration(
            color: ColorsX.greyBackground,
            borderRadius: BorderRadius.all(Radius.circular(10))),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: SizeConfig.screenWidth * .25,
              height: SizeConfig.screenHeight * .12,
              decoration: const BoxDecoration(
                  color: ColorsX.cardBlueBackground,
                  borderRadius: BorderRadius.all(Radius.circular(10))),
              child: const Icon(
                Icons.credit_card_sharp,
                color: ColorsX.appBarColor,
                size: 50,
              ),
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                globalWidgets.myTextRaleway(context, "Your Surveys".tr,
                    ColorsX.fullblack, 20, 10, 0, 0, FontWeight.w600, 17),
                globalWidgets.myTextRaleway(
                    context,
                    "Manage your existing surveys".tr,
                    ColorsX.subBlack,
                    20,
                    10,
                    0,
                    0,
                    FontWeight.w700,
                    13),
              ],
            ),
          ],
        ),
      ),
    );
  }

  surveyTitleDialog(
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
            GlobalVariables.TITLE_OF_SURVEY = ctl.text;
            Get.toNamed(Routes.CREATE_SURVEY_QUESTION);
          }
        },
        onDismissCallback: (type) {
          debugPrint('Dialog Dismiss from callback $type');
        })
      ..show();
  }
}
