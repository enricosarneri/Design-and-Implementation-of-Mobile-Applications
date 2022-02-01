import 'dart:developer';

import 'package:event_handler/screens/authenticate/change_password.dart';
import 'package:event_handler/screens/authenticate/registration.dart';
import 'package:event_handler/screens/home/home.dart';
import 'package:event_handler/wrapper.dart';
import 'package:event_handler/services/authentication/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:permission_handler/permission_handler.dart';

class SignIn extends StatefulWidget {
  const SignIn({Key? key, required this.authServices}) : super(key: key);
  final AuthService authServices;
  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth > 900) {
            return WideLayout(
              authServices: widget.authServices,
            );
          } else {
            return NarrowLayout(
              authServices: widget.authServices,
            );
          }
        },
      ),
    );
  }
}

class NarrowLayout extends StatefulWidget {
  final AuthService? authServices;
  @override
  NarrowLayout({Key? key, this.authServices}) : super(key: key);
  _NarrowLayoutState createState() => _NarrowLayoutState();
}

class _NarrowLayoutState extends State<NarrowLayout> {
  final GlobalKey<FormState> _key = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  bool isSignInLoading = false;
  bool isSignUpLoading = false;
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Container(
            height: double.infinity,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  // Colors.blueGrey,
                  Color(0xFFFFFFFF),
                  Color(0xFFECEFF1),
                  Color(0xFFCFD8DC),
                  Color(0xFFB0BEC5),
                  Color(0xFF90A4AE),
                  Color(0xFF78909C),
                ],
              ),
            ),
          ),
          Form(
            key: _key,
            child: SizedBox(
              height: size.height,
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(top: size.height / 12),
                      height: size.height * 0.15,
                      width: size.width,
                      //   // child: ShaderMask(
                      //   //   shaderCallback: (rect) {
                      //   //     return LinearGradient(
                      //   //       begin: Alignment.bottomCenter,
                      //   //       end: Alignment.topCenter,
                      //   //       colors: [
                      //   //         Colors.transparent,
                      //   //         Colors.black38,
                      //   //         Colors.transparent
                      //   //       ],
                      //   //     ).createShader(
                      //   //         Rect.fromLTRB(0, 0, rect.width, rect.height));
                      //   //   },
                      //   //   blendMode: BlendMode.dstIn,
                      //   // child: Image.asset(
                      //   //   'assets/bap.png',
                      //   //   fit: BoxFit.cover,
                      //   // ),
                      // ),
                    ),
                    Text(
                      "Sign In",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: 28),
                    ),
                    SizedBox(
                      height: size.height / 60,
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(
                          height: size.height / 60,
                        ),
                        Container(
                          margin: EdgeInsets.only(
                            left: size.width / 10,
                            right: size.width / 10,
                          ),
                          alignment: Alignment.topLeft,
                          // color: Colors.white,
                          height: size.height / 10,
                          child: Container(
                            // height: size.height / 7,
                            width: double.infinity,
                            child: TextFormField(
                              cursorColor: Colors.black,
                              validator: validateEmail,
                              keyboardType: TextInputType.emailAddress,
                              style:
                                  TextStyle(color: Colors.black, fontSize: 16),
                              textAlignVertical: TextAlignVertical.center,
                              decoration: InputDecoration(
                                helperText: ' ',
                                contentPadding:
                                    EdgeInsets.only(top: 0, bottom: 0),
                                border: OutlineInputBorder(
                                  gapPadding: 25,
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                errorBorder: OutlineInputBorder(
                                  gapPadding: 25,
                                  borderRadius: BorderRadius.circular(50),
                                  borderSide: new BorderSide(
                                    color: Colors.red.shade700,
                                  ),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(width: 1.2),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  gapPadding: 20,
                                  borderRadius: BorderRadius.circular(50),
                                  borderSide: new BorderSide(
                                    color: Colors.red.shade700,
                                    width: 2,
                                  ),
                                ),
                                prefixIcon: Icon(
                                  Icons.person,
                                  color: Colors.black,
                                ),
                                hintText: 'Enter your Email',
                                hintStyle: TextStyle(
                                    fontSize: 16, color: Colors.black),
                                labelText: "Email",
                                labelStyle: TextStyle(color: Colors.black),
                                floatingLabelBehavior:
                                    FloatingLabelBehavior.always,
                              ),
                              onChanged: (value) {
                                setState(() {
                                  _email = value.trim();
                                  print(_email);
                                });
                              },
                            ),
                          ),
                        ),
                        Stack(
                          children: [
                            Container(
                              margin: EdgeInsets.only(
                                left: size.width / 10,
                                right: size.width / 10,
                              ),
                              alignment: Alignment.centerLeft,
                              height: size.height / 8,
                              child: Container(
                                height: double.infinity,
                                width: double.infinity,
                                child: SizedBox.expand(
                                  child: TextFormField(
                                    validator: validatePassword,
                                    obscureText: _obscureText,
                                    cursorColor: Colors.black,
                                    style: TextStyle(
                                        color: Colors.black, fontSize: 16),
                                    textAlignVertical: TextAlignVertical.center,
                                    decoration: InputDecoration(
                                      contentPadding:
                                          EdgeInsets.only(top: 0, bottom: 0),
                                      border: OutlineInputBorder(
                                        gapPadding: 25,
                                        borderRadius: BorderRadius.circular(50),
                                      ),
                                      focusedBorder: UnderlineInputBorder(
                                        borderSide: BorderSide(width: 0.7),
                                      ),
                                      errorBorder: OutlineInputBorder(
                                        gapPadding: 25,
                                        borderRadius: BorderRadius.circular(50),
                                        borderSide: new BorderSide(
                                          color: Colors.red.shade700,
                                        ),
                                      ),
                                      focusedErrorBorder: OutlineInputBorder(
                                        gapPadding: 20,
                                        borderRadius: BorderRadius.circular(50),
                                        borderSide: new BorderSide(
                                          color: Colors.red.shade700,
                                          width: 2,
                                        ),
                                      ),
                                      floatingLabelBehavior:
                                          FloatingLabelBehavior.always,
                                      prefixIcon: Icon(
                                        Icons.lock,
                                        color: Colors.black,
                                      ),
                                      hintText: 'Enter your Password',
                                      labelStyle:
                                          TextStyle(color: Colors.black),
                                      hintStyle: TextStyle(
                                          fontSize: 16, color: Colors.black),
                                      labelText: "Password",
                                      suffixIcon: IconButton(
                                        onPressed: () async {
                                          setState(() {
                                            _obscureText = _obscureText == true
                                                ? false
                                                : true;
                                          });
                                        },
                                        icon: Icon(
                                          Icons.visibility,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                    onChanged: (value) {
                                      setState(() {
                                        _password = value.trim();
                                        print(_password);
                                      });
                                    },
                                  ),
                                ),
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(
                                  left: size.width / 10,
                                  right: size.width / 10,
                                  top: 50),
                              // color: Colors.green,
                              height: size.height / 24,

                              // margin: EdgeInsets.only(
                              //     left: size.width / 25, right: size.width / 25),
                              alignment: Alignment.bottomRight,

                              child: TextButton(
                                child: Text(
                                  'Forgot Password?',
                                  style: TextStyle(
                                    decoration: TextDecoration.underline,
                                    color: Colors.black,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  textAlign: TextAlign.right,
                                ),
                                onPressed: () => {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => Change_Password(),
                                    ),
                                  ),
                                },
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: size.height / 30,
                        ),
                        Container(
                          height: size.height / 16,
                          margin: EdgeInsets.only(
                              left: size.width / 10, right: size.width / 10),
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              primary: Colors.white,
                              onPrimary: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30.0),
                              ),
                            ),
                            child: isSignInLoading
                                ? CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : const Text(
                                    'Sign In',
                                    style: TextStyle(
                                        color: Colors.black, fontSize: 16),
                                  ),
                            onPressed: () async {
                              setState(() => isSignInLoading = true);
                              if (_key.currentState!.validate()) {
                                if (await Permission.location
                                    .request()
                                    .isDenied) {
                                  await [
                                    Permission.location,
                                  ].request();
                                  Fluttertoast.showToast(
                                      msg:
                                          "Please accept the permissions otherwise the app won't be able to run correctly :(",
                                      gravity: ToastGravity.CENTER,
                                      toastLength: Toast.LENGTH_LONG);
                                } else {
                                  dynamic result = await widget.authServices!
                                      .signInWithEmailAndPassword(
                                          _email, _password);
                                  if (result == null) {
                                    log('Error signing in');
                                  } else {
                                    log('Signed in as: ' + result.email);
                                  }
                                }
                              }
                              if (this.mounted) {
                                setState(() => isSignInLoading = false);
                              }
                            },
                          ),
                        ),
                        SizedBox(
                          height: size.height / 45,
                        ),
                        Container(
                          padding: EdgeInsets.only(
                              left: size.width / 2.7, right: size.width / 2.7),
                          margin: EdgeInsets.symmetric(
                              vertical: size.height * 0.005),
                          alignment: Alignment.center,
                          child: Row(
                            children: <Widget>[
                              buildDivider(),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                child: Text(
                                  "OR",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16),
                                ),
                              ),
                              buildDivider(),
                            ],
                          ),
                          // child: Text(
                          //   'OR',
                          //   style: TextStyle(
                          //       color: Colors.black,
                          //       fontWeight: FontWeight.w600),
                          // ),
                        ),
                        Container(
                          padding: EdgeInsets.only(
                              left: size.width / 10, right: size.width / 10),
                          alignment: Alignment.center,
                          child: Text(
                            'Sign In with',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.normal,
                                fontSize: 16),
                          ),
                        ),
                        SizedBox(
                          height: size.height / 50,
                        ),
                        Container(
                          padding: EdgeInsets.only(
                              left: size.width / 8, right: size.width / 8),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              GestureDetector(
                                onTap: () {},
                                child: Container(
                                  height: 40,
                                  width: 40,
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.transparent,
                                      image: DecorationImage(
                                          image: AssetImage(
                                              "assets/facebook.png"))),
                                ),
                              ),
                              GestureDetector(
                                onTap: () async {
                                  await widget.authServices!
                                      .signInWithGoogle()
                                      .then((UserCredential value) {
                                    final displayName = value.user!.displayName;
                                    print(displayName);
                                    Navigator.pushAndRemoveUntil(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => Wrapper()),
                                        (route) => false);
                                  });
                                  setState(() {});
                                },
                                child: Container(
                                  height: 40,
                                  width: 40,
                                  decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.transparent,
                                      image: DecorationImage(
                                          image:
                                              AssetImage("assets/google.png"))),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: size.height / 13,
                        ),
                        Container(
                          margin: EdgeInsets.only(
                              left: size.width / 10, right: size.width / 10),
                          child: Divider(
                            thickness: 1.2,
                            color: Colors.black45.withOpacity(0.3),
                            height: 15,
                          ),
                        ),
                        SizedBox(
                          height: size.height / 50,
                        ),
                        Container(
                          padding: EdgeInsets.only(
                              left: size.width / 10, right: size.width / 10),
                          alignment: Alignment.center,
                          child: RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Don\'t have an Account?',
                                  style: TextStyle(
                                      fontWeight: FontWeight.normal,
                                      fontSize: 16),
                                ),
                                TextSpan(
                                  text: '  Sign Up',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  Registration(
                                                    authServices:
                                                        widget.authServices!,
                                                  )));
                                    },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Expanded buildDivider() {
    return Expanded(
      child: Divider(
        thickness: 1.5,
        color: Colors.black45.withOpacity(0.3),
        height: 15,
      ),
    );
  }
}

class WideLayout extends StatefulWidget {
  final AuthService? authServices;
  @override
  WideLayout({Key? key, this.authServices}) : super(key: key);
  _WideLayoutState createState() => _WideLayoutState();
}

class _WideLayoutState extends State<WideLayout> {
  final GlobalKey<FormState> _key = GlobalKey<FormState>();
  String _email = '';
  String _password = '';
  bool isSignInLoading = false;
  bool isSignUpLoading = false;
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Container(
            height: double.infinity,
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  // Colors.blueGrey,
                  Color(0xFFFFFFFF),
                  Color(0xFFECEFF1),
                  Color(0xFFCFD8DC),
                  Color(0xFFB0BEC5),
                  Color(0xFF90A4AE),
                  Color(0xFF78909C),
                ],
              ),
            ),
          ),
          Form(
            key: _key,
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 250),
              child: SizedBox(
                height: size.height,
                child: SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Container(
                        margin: EdgeInsets.only(top: size.height / 12),
                        height: size.height * 0.15,
                        width: size.width,
                        //   // child: ShaderMask(
                        //   //   shaderCallback: (rect) {
                        //   //     return LinearGradient(
                        //   //       begin: Alignment.bottomCenter,
                        //   //       end: Alignment.topCenter,
                        //   //       colors: [
                        //   //         Colors.transparent,
                        //   //         Colors.black38,
                        //   //         Colors.transparent
                        //   //       ],
                        //   //     ).createShader(
                        //   //         Rect.fromLTRB(0, 0, rect.width, rect.height));
                        //   //   },
                        //   //   blendMode: BlendMode.dstIn,
                        //   // child: Image.asset(
                        //   //   'assets/bap.png',
                        //   //   fit: BoxFit.cover,
                        //   // ),
                        // ),
                      ),
                      Text(
                        "Sign In",
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            fontSize: 28),
                      ),
                      SizedBox(
                        height: size.height / 60,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          SizedBox(
                            height: size.height / 60,
                          ),
                          Container(
                            margin: EdgeInsets.only(
                              left: size.width / 10,
                              right: size.width / 10,
                            ),
                            alignment: Alignment.topLeft,
                            // color: Colors.white,
                            height: size.height / 10,
                            child: Container(
                              // height: size.height / 7,
                              width: double.infinity,
                              child: TextFormField(
                                cursorColor: Colors.black,
                                validator: validateEmail,
                                keyboardType: TextInputType.emailAddress,
                                style: TextStyle(
                                    color: Colors.black, fontSize: 16),
                                textAlignVertical: TextAlignVertical.center,
                                decoration: InputDecoration(
                                  helperText: ' ',
                                  contentPadding:
                                      EdgeInsets.only(top: 0, bottom: 0),
                                  border: OutlineInputBorder(
                                    gapPadding: 25,
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    gapPadding: 25,
                                    borderRadius: BorderRadius.circular(50),
                                    borderSide: new BorderSide(
                                      color: Colors.red.shade700,
                                    ),
                                  ),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(width: 1.2),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                    gapPadding: 20,
                                    borderRadius: BorderRadius.circular(50),
                                    borderSide: new BorderSide(
                                      color: Colors.red.shade700,
                                      width: 2,
                                    ),
                                  ),
                                  prefixIcon: Icon(
                                    Icons.person,
                                    color: Colors.black,
                                  ),
                                  hintText: 'Enter your Email',
                                  hintStyle: TextStyle(
                                      fontSize: 16, color: Colors.black),
                                  labelText: "Email",
                                  labelStyle: TextStyle(color: Colors.black),
                                  floatingLabelBehavior:
                                      FloatingLabelBehavior.always,
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    _email = value.trim();
                                    print(_email);
                                  });
                                },
                              ),
                            ),
                          ),
                          Stack(
                            children: [
                              Container(
                                margin: EdgeInsets.only(
                                  left: size.width / 10,
                                  right: size.width / 10,
                                ),
                                alignment: Alignment.centerLeft,
                                height: size.height / 8,
                                child: Container(
                                  height: double.infinity,
                                  width: double.infinity,
                                  child: SizedBox.expand(
                                    child: TextFormField(
                                      validator: validatePassword,
                                      obscureText: _obscureText,
                                      cursorColor: Colors.black,
                                      style: TextStyle(
                                          color: Colors.black, fontSize: 16),
                                      textAlignVertical:
                                          TextAlignVertical.center,
                                      decoration: InputDecoration(
                                        contentPadding:
                                            EdgeInsets.only(top: 0, bottom: 0),
                                        border: OutlineInputBorder(
                                          gapPadding: 25,
                                          borderRadius:
                                              BorderRadius.circular(50),
                                        ),
                                        focusedBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(width: 0.7),
                                        ),
                                        errorBorder: OutlineInputBorder(
                                          gapPadding: 25,
                                          borderRadius:
                                              BorderRadius.circular(50),
                                          borderSide: new BorderSide(
                                            color: Colors.red.shade700,
                                          ),
                                        ),
                                        focusedErrorBorder: OutlineInputBorder(
                                          gapPadding: 20,
                                          borderRadius:
                                              BorderRadius.circular(50),
                                          borderSide: new BorderSide(
                                            color: Colors.red.shade700,
                                            width: 2,
                                          ),
                                        ),
                                        floatingLabelBehavior:
                                            FloatingLabelBehavior.always,
                                        prefixIcon: Icon(
                                          Icons.lock,
                                          color: Colors.black,
                                        ),
                                        hintText: 'Enter your Password',
                                        labelStyle:
                                            TextStyle(color: Colors.black),
                                        hintStyle: TextStyle(
                                            fontSize: 16, color: Colors.black),
                                        labelText: "Password",
                                        suffixIcon: IconButton(
                                          onPressed: () async {
                                            setState(() {
                                              _obscureText =
                                                  _obscureText == true
                                                      ? false
                                                      : true;
                                            });
                                          },
                                          icon: Icon(
                                            Icons.visibility,
                                            color: Colors.black,
                                          ),
                                        ),
                                      ),
                                      onChanged: (value) {
                                        setState(() {
                                          _password = value.trim();
                                          print(_password);
                                        });
                                      },
                                    ),
                                  ),
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.only(
                                    left: size.width / 10,
                                    right: size.width / 10,
                                    top: 50),
                                // color: Colors.green,
                                height: size.height / 24,

                                // margin: EdgeInsets.only(
                                //     left: size.width / 25, right: size.width / 25),
                                alignment: Alignment.bottomRight,

                                child: TextButton(
                                  child: Text(
                                    'Forgot Password?',
                                    style: TextStyle(
                                      decoration: TextDecoration.underline,
                                      color: Colors.black,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    textAlign: TextAlign.right,
                                  ),
                                  onPressed: () => {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => Change_Password(),
                                      ),
                                    ),
                                  },
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: size.height / 30,
                          ),
                          Container(
                            height: size.height / 16,
                            margin: EdgeInsets.only(
                                left: size.width / 10, right: size.width / 10),
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                primary: Colors.white,
                                onPrimary: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30.0),
                                ),
                              ),
                              child: isSignInLoading
                                  ? CircularProgressIndicator(
                                      color: Colors.black,
                                    )
                                  : const Text(
                                      'Sign In',
                                      style: TextStyle(
                                          color: Colors.black, fontSize: 16),
                                    ),
                              onPressed: () async {
                                setState(() => isSignInLoading = true);
                                if (_key.currentState!.validate()) {
                                  if (await Permission.location
                                      .request()
                                      .isDenied) {
                                    await [
                                      Permission.location,
                                    ].request();
                                    Fluttertoast.showToast(
                                        msg:
                                            "Please accept the permissions otherwise the app won't be able to run correctly :(",
                                        gravity: ToastGravity.CENTER,
                                        toastLength: Toast.LENGTH_LONG);
                                  } else {
                                    dynamic result = await widget.authServices!
                                        .signInWithEmailAndPassword(
                                            _email, _password);
                                    if (result == null) {
                                      log('Error signing in');
                                    } else {
                                      log('Signed in as: ' + result.email);
                                    }
                                  }
                                }
                                if (this.mounted) {
                                  setState(() => isSignInLoading = false);
                                }
                              },
                            ),
                          ),
                          SizedBox(
                            height: size.height / 45,
                          ),
                          Container(
                            padding: EdgeInsets.only(
                                left: size.width / 2.7,
                                right: size.width / 2.7),
                            margin: EdgeInsets.symmetric(
                                vertical: size.height * 0.005),
                            alignment: Alignment.center,
                            child: Row(
                              children: <Widget>[
                                buildDivider(),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10),
                                  child: Text(
                                    "OR",
                                    style:
                                        TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                ),
                                buildDivider(),
                              ],
                            ),
                            // child: Text(
                            //   'OR',
                            //   style: TextStyle(
                            //       color: Colors.black,
                            //       fontWeight: FontWeight.w600),
                            // ),
                          ),
                          Container(
                            padding: EdgeInsets.only(
                                left: size.width / 10, right: size.width / 10),
                            alignment: Alignment.center,
                            child: Text(
                              'Sign In with',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.normal,
                                  fontSize: 16),
                            ),
                          ),
                          SizedBox(
                            height: size.height / 50,
                          ),
                          Container(
                            padding: EdgeInsets.only(
                                left: size.width / 8, right: size.width / 8),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                GestureDetector(
                                  onTap: () {},
                                  child: Container(
                                    height: 40,
                                    width: 40,
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.transparent,
                                        image: DecorationImage(
                                            image: AssetImage(
                                                "assets/facebook.png"))),
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () async {
                                    await widget.authServices!
                                        .signInWithGoogle()
                                        .then((UserCredential value) {
                                      final displayName =
                                          value.user!.displayName;
                                      print(displayName);
                                      Navigator.pushAndRemoveUntil(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => Wrapper()),
                                          (route) => false);
                                    });
                                    setState(() {});
                                  },
                                  child: Container(
                                    height: 40,
                                    width: 40,
                                    decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.transparent,
                                        image: DecorationImage(
                                            image: AssetImage(
                                                "assets/google.png"))),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: size.height / 13,
                          ),
                          Container(
                            margin: EdgeInsets.only(
                                left: size.width / 10, right: size.width / 10),
                            child: Divider(
                              color: Colors.black45,
                              height: 15,
                            ),
                          ),
                          SizedBox(
                            height: size.height / 50,
                          ),
                          Container(
                            padding: EdgeInsets.only(
                                left: size.width / 10, right: size.width / 10),
                            alignment: Alignment.center,
                            child: RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'Don\'t have an Account?',
                                    style: TextStyle(
                                        fontWeight: FontWeight.normal,
                                        fontSize: 16),
                                  ),
                                  TextSpan(
                                    text: '  Sign Up',
                                    style: TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16),
                                    recognizer: TapGestureRecognizer()
                                      ..onTap = () {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    Registration(
                                                      authServices:
                                                          widget.authServices!,
                                                    )));
                                      },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Expanded buildDivider() {
    return Expanded(
      child: Divider(
        thickness: 1.5,
        color: Colors.black45,
        height: 15,
      ),
    );
  }
}

String? validateEmail(String? formEmail) {
  if (formEmail == null || formEmail.isEmpty)
    return 'E-mail address is required';
  String pattern = r'\w+@\w+\.\w+';
  RegExp regExp = RegExp(pattern);
  if (!regExp.hasMatch(formEmail)) return 'Invalid E-mail Address format.';
  return null;
}

String? validatePassword(String? formPassword) {
  if (formPassword == null || formPassword.isEmpty)
    return 'Password address is required';
  // String pattern =
  //     r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$';
  // RegExp regex = RegExp(pattern);
  // if (!regex.hasMatch(formPassword))
  //   return '''
  //     Password must be at least 8 characters,
  //     include an uppercase letter, number and symbol.
  //     ''';
  // return null;
}
