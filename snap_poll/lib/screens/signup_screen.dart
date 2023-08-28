import 'package:firebase_auth/firebase_auth.dart';
//import 'package:firebase_signin/reusable_widgets/reusable_widget.dart';
//import 'package:firebase_signin/screens/home_screen.dart';
//import 'package:firebase_signin/utils/color_utils.dart';
import 'package:flutter/material.dart';
import 'package:snap_poll/global/global_widgets.dart';
import 'package:snap_poll/screens/main_page.dart';
import 'package:snap_poll/screens/terms_and_conditions.dart';

import '../global/colors.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool isChecked = false;
  TextEditingController _passwordTextController = TextEditingController();
  TextEditingController _emailTextController = TextEditingController();
  TextEditingController _userNameTextController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: ColorsX.appBarColor,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Sign Up",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ),
      body: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          decoration: const BoxDecoration(color: ColorsX.white),
          child: SingleChildScrollView(
              child: Padding(
            padding: EdgeInsets.fromLTRB(20, 120, 20, 0),
            child: Column(
              children: <Widget>[
                Image.asset(
                  'assets/images/uni_logo.png',
                  height: 150,
                  width: 150,
                  fit: BoxFit.contain,
                ),
                const SizedBox(
                  height: 70,
                ),
                const SizedBox(
                  height: 20,
                ),
                GlobalWidgets().reusableTextField("Enter UserName",
                    Icons.person_outline, false, _userNameTextController),
                const SizedBox(
                  height: 20,
                ),
                GlobalWidgets().reusableTextField("Enter Email Id",
                    Icons.person_outline, false, _emailTextController),
                const SizedBox(
                  height: 20,
                ),
                GlobalWidgets().reusableTextField("Enter Password",
                    Icons.lock_outlined, true, _passwordTextController),
                const SizedBox(
                  height: 20,
                ),
                consentForm(context),
                GlobalWidgets().firebaseUIButton(context, "Sign Up", () {
                  if (isChecked) {
                    FirebaseAuth.instance
                        .createUserWithEmailAndPassword(
                            email: _emailTextController.text,
                            password: _passwordTextController.text)
                        .then((value) {
                      print("Created New Account");
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const MainPage()));
                    }).onError((error, stackTrace) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        duration: Duration(seconds: 3),
                        content: Text(
                            'The email address is already in use by another account'),
                      ));
                      //print("Error ${error.toString()}");
                    });
                  } else {
                    GlobalWidgets.showToast(
                        'Please accept the consent form to continue');
                  }
                })
              ],
            ),
          ))),
    );
  }

  Widget consentForm(context) {
    return Container(
      child: CheckboxListTile(
        title: const Text(" ", style: TextStyle(color: Colors.black87)),
        value: isChecked,
        onChanged: (bool? value) {
          setState(() {
            isChecked = value!;
          });
        },
        secondary: GestureDetector(
          onTap: () {
            Navigator.push(context,
                MaterialPageRoute(builder: (context) => TermsAndConditions()));
          },
          child: const Text(
            " Accept consent form(Click here for details)",
            style:
                TextStyle(color: Colors.blueGrey, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
