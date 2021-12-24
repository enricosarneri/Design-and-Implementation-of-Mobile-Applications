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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Form(
        key: _key,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                validator: validateEmail,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(hintText: 'Email'),
                onChanged: (value) {
                  setState(() {
                    _email = value.trim();
                  });
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextFormField(
                //validator: validatePassword,
                obscureText: true,
                decoration: const InputDecoration(hintText: 'Password'),
                onChanged: (value) {
                  setState(() {
                    _password = value.trim();
                  });
                },
              ),
            ),
            Row(
              children: [
                ElevatedButton(
                  child: isSignInLoading
                      ? CircularProgressIndicator(
                          color: Colors.white,
                        )
                      : const Text('Sign in'),
                  onPressed: () async {
                    setState(() => isSignInLoading = true);
                    if (_key.currentState!.validate()) {
                      dynamic result = await _authService
                          .signInWithEmailAndPassword(_email, _password);
                      if (result == null) {
                        log('error signing in');
                      } else {
                        log('signed in as: ' + result.email);
                      }
                    }
                    if(this.mounted){
                      setState(() => isSignInLoading= false);
                    }
                  },
                ),
                const Padding(
                  padding: EdgeInsets.only(left: 20.0),
                  child: Text("If you don't have an account click"),
                ),
                Padding(
                  padding: EdgeInsets.zero,
                  child: InkWell(
                    onTap: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Registration()));
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(10.0),
                      child: Text("here",
                          style: TextStyle(
                            color: Colors.blue,
                          )),
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
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
