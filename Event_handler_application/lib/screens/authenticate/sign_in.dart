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
  String _email='';
  String _password='';


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login'),),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child:TextField(
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
            child:TextField(
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
              child: const Text('Sign in'),
              onPressed: () async{
                dynamic result=await _authService.signInWithEmailAndPassword(_email, _password);
                if (result== null){
                  log('error signing in');
                }
                else{
                  log('signed in as: '+ result.email);
                }
              },),
            ElevatedButton(
              child: const Text('Sign up'),
              onPressed: (){
                _authService.createUserWithEmailAndPassword(_email, _password);
                //Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => Home()));
            }),   
          ],)],),
    );
  }
}