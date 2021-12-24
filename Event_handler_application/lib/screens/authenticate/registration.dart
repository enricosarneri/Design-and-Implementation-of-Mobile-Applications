
import 'dart:developer';

import 'package:event_handler/models/user.dart';
import 'package:event_handler/screens/home/home.dart';
import 'package:event_handler/screens/wrapper.dart';
import 'package:event_handler/services/auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Registration extends StatefulWidget {

  @override
  _RegistrationState createState() => _RegistrationState();
}

class _RegistrationState extends State<Registration> {
  final AuthService _authService= AuthService();
  final GlobalKey<FormState> _key = GlobalKey<FormState>();
  
  String _name='';
  String _surname='';
  String _email='';
  String? _dataOfBirth='';
  String _password='';
  bool _isOwner=false;
  bool isSignUpLoading= false;

  Widget _buildName(){
    return TextFormField(
      decoration: InputDecoration(labelText: 'Name'),
      validator: (String? value){
        if(value!.isEmpty){
          return 'Name is Required';
        }
      },
      onChanged: (value){
      setState(() {
      _name= value.trim();
        });
      },
    );
  }

    Widget _buildSurname(){
      return TextFormField(
      decoration: InputDecoration(labelText: 'Surname'),
      validator: (String? value){
        if(value!.isEmpty){
          return 'Surname is Required';
        }
      },
      onChanged: (value){
      setState(() {
      _surname= value.trim();
        });
      },
    );
  }

    Widget _buildEmail(){
    return TextFormField(
      validator: validateEmail,
      keyboardType: TextInputType.emailAddress,
      decoration: const InputDecoration( hintText: 'Email' ),
      onChanged: (value){
      setState(() {
      _email= value.trim();
        });
      } ,
    );
  }

    //Widget _builDateOfBirth(){
    //return null;
  //}

    Widget _buildPassword(){
    return TextFormField(
    validator: validatePassword,
    obscureText: true,
    decoration: const InputDecoration( hintText: 'Password'),
    onChanged: (value){
    setState(() {
      _password= value.trim();
        });
      } ,
    );
  }

    Widget _buildIsOwner(){
    return CheckboxListTile(
      value: _isOwner,
      title: Text("Are you an owner of a local?", style: TextStyle(fontSize: 20),),
      onChanged: (value){
        setState(() {
          _isOwner= value!;
        });
      }
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Registration')),
      body: Container(
        margin: EdgeInsets.all(24),
        child: Form(
          key: _key,
          child: ListView(
          children: <Widget>[
            _buildName(),
            SizedBox(height: 20),
            _buildSurname(),
            SizedBox(height: 20),
            _buildEmail(),
            SizedBox(height: 20),
            //_builDateOfBirth(),
            _buildPassword(),
            SizedBox(height: 20),
            _buildIsOwner(),
            SizedBox(height: 100),
            ElevatedButton(
              child: isSignUpLoading
              ? CircularProgressIndicator(color: Colors.white,) 
              : const Text('Sign up'),
              onPressed: () async{
              setState(() => isSignUpLoading= true);
              if(!_key.currentState!.validate()){
                  setState(() => isSignUpLoading= false);
                  return;
              }
              log("isOwner is: "+ _isOwner.toString());
              log("name: "+ _name);
              log("surname: "+ _surname);
              dynamic result= await _authService.createUserWithEmailAndPassword(_email, _password, _name, _surname, _isOwner);

              if (result== null){
                log('error signing up');
                }
              else{
                Navigator.pop(context);
                log('signed up as: '+ result.email);
              }
              if(this.mounted){
                setState(() => isSignUpLoading= false);
              }
                //Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => Home()));
              }), 

            ],
          ),
        ),
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
    if(formPassword== null || formPassword.isEmpty) return 'Password is required';
    //String pattern = r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$';
  //RegExp regex = RegExp(pattern);
  //if (!regex.hasMatch(formPassword))
    //return '''
      //Password must be at least 8 characters,
      //include an uppercase letter, number and symbol.
      //''';
  return null;
}