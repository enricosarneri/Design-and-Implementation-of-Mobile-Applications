import 'dart:developer';

import 'package:event_handler/models/user.dart';
import 'package:event_handler/screens/authenticate/sign_in.dart';
import 'package:event_handler/screens/home/home.dart';
import 'package:event_handler/wrapper.dart';
import 'package:event_handler/services/authentication/auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Registration extends StatefulWidget {
  @override
  _RegistrationState createState() => _RegistrationState();
  const Registration({Key? key, required this.authServices}) : super(key: key);
  final AuthService authServices;
}

class _RegistrationState extends State<Registration> {
  final GlobalKey<FormState> _key = GlobalKey<FormState>();

  String _name = '';
  String _surname = '';
  String _email = '';
  String? _dataOfBirth = '';
  String _password = '';
  bool _isOwner = false;
  bool isSignUpLoading = false;

  Widget _buildName() {
    return TextFormField(
      decoration: InputDecoration(labelText: 'Name'),
      validator: (String? value) {
        if (value!.isEmpty) {
          return 'Name is required';
        }
      },
      onChanged: (value) {
        setState(() {
          _name = value.trim();
        });
      },
    );
  }

  Widget _buildSurname() {
    return TextFormField(
      decoration: InputDecoration(labelText: 'Surname'),
      validator: (String? value) {
        if (value!.isEmpty) {
          return 'Surname is required';
        }
      },
      onChanged: (value) {
        setState(() {
          _surname = value.trim();
        });
      },
    );
  }

  Widget _buildEmail() {
    return TextFormField(
      validator: validateEmail,
      keyboardType: TextInputType.emailAddress,
      decoration: const InputDecoration(hintText: 'Email'),
      onChanged: (value) {
        setState(() {
          _email = value.trim();
        });
      },
    );
  }

  //Widget _builDateOfBirth(){
  //return null;
  //}

  Widget _buildPassword() {
    return TextFormField(
      validator: validatePassword,
      obscureText: true,
      decoration: const InputDecoration(hintText: 'Password'),
      onChanged: (value) {
        setState(() {
          _password = value.trim();
        });
      },
    );
  }

  Widget _buildIsOwner() {
    return CheckboxListTile(
        value: _isOwner,
        title: Text(
          "Are you an owner of a local?",
          style: TextStyle(fontSize: 20),
        ),
        onChanged: (value) {
          setState(() {
            _isOwner = value!;
          });
        });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    bool _obscureText = true;
    return Scaffold(
      // body: Container(
      //   margin: EdgeInsets.all(24),
      //   child: Form(
      //     key: _key,
      //     child: ListView(
      //       children: <Widget>[
      //         _buildName(),
      //         SizedBox(height: 20),
      //         _buildSurname(),
      //         SizedBox(height: 20),
      //         _buildEmail(),
      //         SizedBox(height: 20),
      //         //_builDateOfBirth(),
      //         _buildPassword(),
      //         SizedBox(height: 20),
      //         _buildIsOwner(),
      //         SizedBox(height: 100),
      //         ElevatedButton(
      //             child: isSignUpLoading
      //                 ? CircularProgressIndicator(
      //                     color: Colors.white,
      //                   )
      //                 : const Text('Sign up'),
      //             onPressed: () async {
      //               setState(() => isSignUpLoading = true);
      //               if (!_key.currentState!.validate()) {
      //                 setState(() => isSignUpLoading = false);
      //                 return;
      //               }
      //               log("isOwner is: " + _isOwner.toString());
      //               log("name: " + _name);
      //               log("surname: " + _surname);
      //               dynamic result =
      //                   await _authService.createUserWithEmailAndPassword(
      //                       _email, _password, _name, _surname, _isOwner);

      //               if (result == null) {
      //                 log('error signing up');
      //               } else {
      //                 Navigator.pop(context);
      //                 log('signed up as: ' + result.email);
      //               }
      //               if (this.mounted) {
      //                 setState(() => isSignUpLoading = false);
      //               }
      //               //Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => Home()));
      //             }),
      //       ],
      //     ),
      //   ),
      // ),
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
              height: double.infinity,
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      height: size.height * 0.14,
                      width: 40,
                      decoration: BoxDecoration(
                          // image: DecorationImage(
                          //   image: AssetImage("assets/google.png"),
                          // ),
                          ),
                    ),
                    // SvgPicture.asset(
                    //   "",
                    //   height: size.height * 0.25,
                    // ),
                    Text(
                      "Sign Up",
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
                          alignment: Alignment.centerLeft,
                          // color: Colors.white,
                          height: size.height / 11,
                          child: Container(
                            height: double.infinity,
                            width: double.infinity,
                            child: SizedBox.expand(
                              child: TextFormField(
                                maxLength: 50,
                                cursorColor: Colors.black,
                                validator: validateEmail,
                                keyboardType: TextInputType.emailAddress,
                                style: TextStyle(
                                  color: Colors.black,
                                ),
                                textAlignVertical: TextAlignVertical.center,
                                decoration: InputDecoration(
                                  contentPadding:
                                      EdgeInsets.only(top: 0, bottom: 0),
                                  border: OutlineInputBorder(
                                    gapPadding: 25,
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                        width: 0.7, color: Colors.black),
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                    gapPadding: 20,
                                    borderRadius: BorderRadius.circular(50),
                                    borderSide: new BorderSide(
                                      color: Colors.red.shade700,
                                      width: 2,
                                    ),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    gapPadding: 25,
                                    borderRadius: BorderRadius.circular(50),
                                    borderSide: new BorderSide(
                                      color: Colors.red.shade700,
                                    ),
                                  ),
                                  prefixIcon: Icon(
                                    Icons.person,
                                    color: Colors.black,
                                  ),
                                  hintText: 'Enter your Email',
                                  hintStyle: TextStyle(
                                      fontSize: 14, color: Colors.black),
                                  labelText: "Email",
                                  labelStyle: TextStyle(color: Colors.black),
                                  floatingLabelBehavior:
                                      FloatingLabelBehavior.always,
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    _email = value.trim();
                                  });
                                },
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: size.height / 80,
                        ),
                        Container(
                          margin: EdgeInsets.only(
                            left: size.width / 10,
                            right: size.width / 10,
                          ),
                          alignment: Alignment.centerLeft,
                          height: size.height / 11,
                          child: Container(
                            height: double.infinity,
                            width: double.infinity,
                            child: SizedBox.expand(
                              child: TextFormField(
                                maxLength: 20,
                                validator: validatePassword,
                                obscureText: _obscureText,
                                cursorColor: Colors.black,
                                style: TextStyle(color: Colors.black),
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
                                  labelStyle: TextStyle(color: Colors.black),
                                  hintStyle: TextStyle(
                                      fontSize: 14, color: Colors.black),
                                  labelText: "Password",
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
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    _password = value.trim();
                                  });
                                },
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: size.height / 80,
                        ),
                        Container(
                          margin: EdgeInsets.only(
                            left: size.width / 10,
                            right: size.width / 10,
                          ),
                          alignment: Alignment.centerLeft,
                          height: size.height / 10,
                          child: Container(
                            // height: size.height / 5,

                            width: double.infinity,
                            child: Center(
                              child: TextFormField(
                                validator: (String? value) {
                                  if (value!.isEmpty) {
                                    return 'Name is Required';
                                  }
                                },
                                cursorColor: Colors.black,
                                style: TextStyle(color: Colors.black),
                                textAlignVertical: TextAlignVertical.center,
                                decoration: InputDecoration(
                                  helperText: ' ',
                                  contentPadding: EdgeInsets.only(
                                    top: 0,
                                    bottom: 5,
                                    left: 48,
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    gapPadding: 25,
                                    borderRadius: BorderRadius.circular(50),
                                    borderSide: new BorderSide(
                                      color: Colors.red.shade700,
                                    ),
                                  ),
                                  border: OutlineInputBorder(
                                    gapPadding: 25,
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(width: 0.7),
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
                                  hintText: 'Enter your Name',
                                  labelStyle: TextStyle(color: Colors.black),
                                  hintStyle: TextStyle(
                                      fontSize: 14, color: Colors.black),
                                  labelText: "Name",
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    _name = value.trim();
                                  });
                                },
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: size.height / 200,
                        ),
                        Container(
                          margin: EdgeInsets.only(
                            left: size.width / 10,
                            right: size.width / 10,
                          ),
                          alignment: Alignment.centerLeft,
                          height: size.height / 10,
                          child: Container(
                            height: double.infinity,
                            width: double.infinity,
                            child: SizedBox.expand(
                              child: TextFormField(
                                validator: (String? value) {
                                  if (value!.isEmpty) {
                                    return 'Surname is Required';
                                  }
                                },
                                cursorColor: Colors.black,
                                style: TextStyle(color: Colors.black),
                                textAlignVertical: TextAlignVertical.center,
                                decoration: InputDecoration(
                                  helperText: ' ',
                                  contentPadding: EdgeInsets.only(
                                    top: 0,
                                    bottom: 5,
                                    left: 48,
                                  ),
                                  focusedErrorBorder: OutlineInputBorder(
                                    gapPadding: 20,
                                    borderRadius: BorderRadius.circular(50),
                                    borderSide: new BorderSide(
                                      color: Colors.red.shade700,
                                      width: 2,
                                    ),
                                  ),
                                  errorBorder: OutlineInputBorder(
                                    gapPadding: 25,
                                    borderRadius: BorderRadius.circular(50),
                                    borderSide: new BorderSide(
                                      color: Colors.red.shade700,
                                    ),
                                  ),
                                  border: OutlineInputBorder(
                                    gapPadding: 25,
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(width: 0.7),
                                  ),
                                  floatingLabelBehavior:
                                      FloatingLabelBehavior.always,
                                  hintText: 'Enter your Surname',
                                  labelStyle: TextStyle(color: Colors.black),
                                  hintStyle: TextStyle(
                                      fontSize: 14, color: Colors.black),
                                  labelText: "Surname",
                                ),
                                onChanged: (value) {
                                  setState(() {
                                    _surname = value.trim();
                                  });
                                },
                              ),
                            ),
                          ),
                        ),
                        Container(
                          height: size.height / 25,
                          alignment: Alignment.center,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                "Are you an owner of a local?",
                                textAlign: TextAlign.center,
                              ),
                              Switch(
                                  value: _isOwner,
                                  onChanged: (value) {
                                    setState(() {
                                      _isOwner = value;
                                    });
                                  })
                            ],
                          ),
                        ),
                        SizedBox(
                          height: size.height / 50,
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
                            child: isSignUpLoading
                                ? CircularProgressIndicator(
                                    color: Colors.white,
                                  )
                                : const Text(
                                    'Sign Up',
                                    style: TextStyle(color: Colors.black),
                                  ),
                            onPressed: () async {
                              setState(() => isSignUpLoading = true);
                              if (!_key.currentState!.validate()) {
                                setState(() => isSignUpLoading = false);
                                return;
                              }
                              log("isOwner is: " + _isOwner.toString());
                              log("name: " + _name);
                              log("surname: " + _surname);
                              dynamic result = await widget.authServices
                                  .createUserWithEmailAndPassword(_email,
                                      _password, _name, _surname, _isOwner);

                              if (result == null) {
                                log('error signing up');
                              } else {
                                Navigator.pop(context);
                                log('signed up as: ' + result.email);
                              }
                              if (this.mounted) {
                                setState(() => isSignUpLoading = false);
                              }
                            },
                          ),
                        ),
                        SizedBox(
                          height: size.height / 45,
                        ),
                        Container(
                          padding: EdgeInsets.only(
                              left: size.width / 10, right: size.width / 10),
                          alignment: Alignment.center,
                          child: RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: 'Already have an Account?',
                                  style:
                                      TextStyle(fontWeight: FontWeight.normal),
                                ),
                                TextSpan(
                                  text: '  Sign In',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      Navigator.pop(context);
                                    },
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: size.height / 30,
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
                                  style: TextStyle(fontWeight: FontWeight.w600),
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
                            'Sign Up with',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.normal),
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
                                  await widget.authServices
                                      .signInWithGoogle()
                                      .then((UserCredential value) {
                                    final displayName = value.user!.displayName;
                                    print(displayName);
                                    Navigator.pop(context);
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
    return 'Password is required';
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
