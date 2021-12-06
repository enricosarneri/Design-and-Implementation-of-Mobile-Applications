import 'dart:developer';

import 'package:event_handler/screens/home/home.dart';
import 'package:event_handler/services/auth.dart';
import 'package:flutter/material.dart';

class SignIn extends StatefulWidget {
  const SignIn({ Key? key }) : super(key: key);

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {
  final AuthService _authService= AuthService();
  final GlobalKey<FormState> _key = GlobalKey<FormState>();
  String _email='';
  String _password='';
  bool isSignInLoading= false;
  bool isSignUpLoading= false;



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login'),),
      body: Form(
        key: _key,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child:TextFormField(
                validator: validateEmail,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration( hintText: 'Email' ),
                  onChanged: (value){
                  setState(() {
                    _email= value.trim();
                  });
                } ,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child:TextFormField(
                //validator: validatePassword,
                obscureText: true,
                decoration: const InputDecoration( hintText: 'Password'),
                onChanged: (value){
                  setState(() {
                    _password= value.trim();
                  });
                } ,
              ),
            ),
            Row(children: [
              ElevatedButton(
                child: isSignInLoading
                 ? CircularProgressIndicator(color: Colors.white,) 
                 : const Text('Sign in'),
                onPressed: () async{
                  setState(() => isSignInLoading= true);
                  if(_key.currentState!.validate()){
                  dynamic result=await _authService.signInWithEmailAndPassword(_email, _password);
                  if (result== null){
                    log('error signing in');
                  }
                  else{
                    log('signed in as: '+ result.email);
                    }
                  }
                  setState(() => isSignInLoading= false);

                },),
              ElevatedButton(
                 child: isSignUpLoading
                 ? CircularProgressIndicator(color: Colors.white,) 
                 : const Text('Sign up'),
                onPressed: () async{
                  setState(() => isSignUpLoading= true);
                  if(_key.currentState!.validate()){
                  dynamic result= await _authService.createUserWithEmailAndPassword(_email, _password);
                  if (result== null){
                    log('error signing up');
                  }
                  else{
                    log('signed up as: '+ result.email);
                    }
                  }
                  setState(() => isSignUpLoading= false);
                  //Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => Home()));
              }),   
            ],)],),
      ),
    );
  }
}

String? validateEmail(String? formEmail){
  if(formEmail== null || formEmail.isEmpty) return 'E-mail address is required';
  String pattern = r'\w+@\w+\.\w+';
  RegExp regExp= RegExp(pattern);
  if(!regExp.hasMatch(formEmail)) return 'Invalid E-mail Address format.';
  return null;
}

String? validatePassword(String? formPassword){
    if(formPassword== null || formPassword.isEmpty) return 'Password address is required';
    String pattern = r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$';
  RegExp regex = RegExp(pattern);
  if (!regex.hasMatch(formPassword))
    return '''
      Password must be at least 8 characters,
      include an uppercase letter, number and symbol.
      ''';
  return null;
}