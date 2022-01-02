import 'dart:developer';

import 'package:event_handler/screens/authenticate/registration.dart';
import 'package:event_handler/screens/home/home.dart';
import 'package:event_handler/services/auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

class SignIn extends StatefulWidget {
  const SignIn({Key? key}) : super(key: key);

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final AuthService _authService = AuthService();
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
            // child: Form(
            //   key: _key,
            //   child: Column(
            //     mainAxisAlignment: MainAxisAlignment.center,
            //     children: [
            //       Padding(
            //         padding: const EdgeInsets.all(8.0),
            //         child: TextFormField(
            //           validator: validateEmail,
            //           keyboardType: TextInputType.emailAddress,
            //           decoration: const InputDecoration(hintText: 'Email'),
            //           onChanged: (value) {
            //             setState(() {
            //               _email = value.trim();
            //             });
            //           },
            //         ),
            //       ),
            //       Padding(
            //         padding: const EdgeInsets.all(8.0),
            //         child: TextFormField(
            //           //validator: validatePassword,
            //           obscureText: true,
            //           decoration: const InputDecoration(hintText: 'Password'),
            //           onChanged: (value) {
            //             setState(() {
            //               _password = value.trim();
            //             });
            //           },
            //         ),
            //       ),
            //       Row(
            //         children: [
            //           ElevatedButton(
            //             child: isSignInLoading
            //                 ? CircularProgressIndicator(
            //                     color: Colors.white,
            //                   )
            //                 : const Text('Sign in'),
            //             onPressed: () async {
            //               setState(() => isSignInLoading = true);
            //               if (_key.currentState!.validate()) {
            //                 dynamic result = await _authService
            //                     .signInWithEmailAndPassword(_email, _password);
            //                 if (result == null) {
            //                   log('error signing in');
            //                 } else {
            //                   log('signed in as: ' + result.email);
            //                 }
            //               }
            //               if (this.mounted) {
            //                 setState(() => isSignInLoading = false);
            //               }
            //             },
            //           ),
            //           const Padding(
            //             padding: EdgeInsets.only(left: 20.0),
            //             child: Text("If you don't have an account click"),
            //           ),
            //           Padding(
            //             padding: EdgeInsets.zero,
            //             child: InkWell(
            //               onTap: () {
            //                 Navigator.push(
            //                     context,
            //                     MaterialPageRoute(
            //                         builder: (context) => Registration()));
            //               },
            //               child: const Padding(
            //                 padding: EdgeInsets.all(10.0),
            //                 child: Text("here",
            //                     style: TextStyle(
            //                       color: Colors.blue,
            //                     )),
            //               ),
            //             ),
            //           )
            //         ],
            //       ),
            //     ],
            //   ),
            // ),
          ),
          Form(
            key: _key,
            child: Container(
              height: double.infinity,
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
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
                        Container(
                            padding: EdgeInsets.only(
                                left: size.width / 10, right: size.width / 10),
                            child: Text(
                              'Email',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            )),
                        SizedBox(
                          height: size.height / 60,
                        ),
                        Container(
                          margin: EdgeInsets.only(
                              left: size.width / 10, right: size.width / 10),
                          padding: EdgeInsets.only(
                              left: size.width / 25, right: size.width / 25),
                          alignment: Alignment.centerLeft,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(150),
                            color: Colors.white,
                          ),
                          height: size.height / 14,
                          child: TextFormField(
                            cursorColor: Colors.black,
                            validator: validateEmail,
                            keyboardType: TextInputType.emailAddress,
                            style: TextStyle(color: Colors.black),
                            decoration: InputDecoration(
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.only(top: 14),
                                prefixIcon: Icon(
                                  Icons.person,
                                  color: Colors.black,
                                ),
                                hintText: 'Enter your Email'),
                            onChanged: (value) {
                              setState(() {
                                _email = value.trim();
                                print(_email);
                              });
                            },
                          ),
                        ),
                        SizedBox(
                          height: size.height / 60,
                        ),
                        Container(
                            padding: EdgeInsets.only(
                                left: size.width / 10, right: size.width / 10),
                            child: Text(
                              'Password',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            )),
                        SizedBox(
                          height: size.height / 60,
                        ),
                        Container(
                          margin: EdgeInsets.only(
                              left: size.width / 10, right: size.width / 10),
                          padding: EdgeInsets.only(
                              left: size.width / 25, right: size.width / 25),
                          alignment: Alignment.centerLeft,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(150),
                            color: Colors.white,
                          ),
                          height: size.height / 14,
                          child: TextFormField(
                            obscureText: _obscureText,
                            cursorColor: Colors.black,
                            style: TextStyle(color: Colors.black),
                            decoration: InputDecoration(
                                border: InputBorder.none,
                                contentPadding: EdgeInsets.only(top: 14),
                                prefixIcon: Icon(
                                  Icons.lock,
                                  color: Colors.black,
                                ),
                                suffixIcon: IconButton(
                                  onPressed: () async {
                                    setState(() {
                                      _obscureText =
                                          _obscureText == true ? false : true;
                                    });
                                  },
                                  icon: Icon(
                                    Icons.visibility,
                                    color: Colors.black,
                                  ),
                                ),
                                hintText: 'Enter your Password'),
                            onChanged: (value) {
                              setState(() {
                                _password = value.trim();
                                print(_password);
                              });
                            },
                          ),
                        ),
                        Container(
                          height: size.height / 24,
                          // color: Colors.green,
                          padding: EdgeInsets.only(
                              left: size.width / 10, right: size.width / 10),
                          // margin: EdgeInsets.only(
                          //     left: size.width / 25, right: size.width / 25),
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            child: Text(
                              'Forgot Password?',
                              style:
                                  TextStyle(color: Colors.black, fontSize: 14),
                            ),
                            onPressed: () => {},
                          ),
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
                                    'Sign in',
                                    style: TextStyle(color: Colors.black),
                                  ),
                            onPressed: () async {
                              setState(() => isSignInLoading = true);
                              if (_key.currentState!.validate()) {
                                dynamic result = await _authService
                                    .signInWithEmailAndPassword(
                                        _email, _password);
                                if (result == null) {
                                  log('Error signing in');
                                } else {
                                  log('Signed in as: ' + result.email);
                                }
                              }
                              if (this.mounted) {
                                setState(() => isSignInLoading = false);
                              }
                            },
                          ),
                        ),
                        SizedBox(
                          height: size.height / 15,
                        ),
                        Container(
                          padding: EdgeInsets.only(
                              left: size.width / 10, right: size.width / 10),
                          alignment: Alignment.center,
                          child: RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(text: 'Don\'t have an Account?'),
                                TextSpan(
                                  text: '  Register',
                                  style: TextStyle(color: Colors.black),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  Registration()));
                                    },
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: size.height / 40,
                        ),
                        Container(
                          padding: EdgeInsets.only(
                              left: size.width / 10, right: size.width / 10),
                          margin: EdgeInsets.symmetric(
                              vertical: size.height * 0.02),
                          alignment: Alignment.center,
                          child: Row(
                            children: <Widget>[
                              buildDivider(),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                child: Text(
                                  "OR",
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                              ),
                              buildDivider(),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.only(
                              left: size.width / 10, right: size.width / 10),
                          alignment: Alignment.center,
                          child: Text(
                            'Sign in with',
                            style: TextStyle(color: Colors.white),
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
                                onTap: () => () {},
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
                                onTap: () => () {},
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
        color: Color(0xFFD9D9D9),
        height: 2,
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
  String pattern =
      r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$';
  RegExp regex = RegExp(pattern);
  if (!regex.hasMatch(formPassword))
    return '''
      Password must be at least 8 characters,
      include an uppercase letter, number and symbol.
      ''';
  return null;
}
