import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebaseruletest/youtubepromotion.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'package:flutter/services.dart';
import 'dart:core';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  String loginStatus = 'Not Login';

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final userEmail= 'testemail@mail.com';
  final userPassword = 'testpassword';
  final userData = 'userData33';
  FirebaseUser _user;

  @override
  void initState() {
    _checkAuthStatus();
    super.initState();
  }

  Future<void> _checkAuthStatus() async{
    if (await _auth.currentUser() != null) {
      setState(() {
        loginStatus = 'Login';
      });
    } else {
      setState(() {
        loginStatus = 'Not Login';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Firebase Rules Test'),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _subjectTitle('- Authentication Status: $loginStatus'),
          Row(children: _authenticationButtons(),),
          _subjectTitle('- Database Test'),
          Row(children: _databaseButtons(),),
          _subjectTitle('- Storage Test'),
          Row(children: _storageButtons(),),
          youtubePromotion()
        ],
      ),
    );
  }


  List<Widget> _authenticationButtons(){
    return <Widget>[
      _regularButton('Sign Up',Colors.white,Colors.deepOrange[900],_authSignUp),
      _regularButton('Sign in',Colors.white,Colors.black,_authSignIn),
      _regularButton('Log out',Colors.black,Colors.white,_authLogOut),
    ];
  }

  void _authSignUp() async{
    try{
      _user = (await _auth.createUserWithEmailAndPassword(
        email: userEmail,
        password: userPassword,
      )).user;
      setState(() {
        if(_user != null) loginStatus = 'Login';
      });
      _showDialogWithText('Sign Up and Sign In success!');
    }catch(e){
      _showDialogWithText('${e.message} \n\nPlease touch Sign In button');
    }
  }

  void _authSignIn() async{

    try{
      AuthResult authResult = await _auth.signInWithEmailAndPassword(email: userEmail, password: userPassword);
      _user = authResult.user;
      setState(() {
        if(_user != null) loginStatus = 'Login';
      });
      _showDialogWithText('Login success!');
    } on PlatformException catch (err) {
      _showDialogWithText('${err.message}\n\nThere is no account');
    } catch (err) {
      _showDialogWithText('${err.message}\n\nThere is no account');
    }

  }

  void _authLogOut(){
    _auth.signOut();
    setState(() {
      loginStatus = 'Not Login';
    });
    _showDialogWithText('Log out success!');
  }


  List<Widget> _databaseButtons(){
    return <Widget>[
      _regularButton('Add Data',Colors.white,Colors.deepOrange[900],_databaseAddData),
      _regularButton('Get Data',Colors.white,Colors.black,_databaseGetData),
    ];
  }

  void _databaseAddData() async{
    try{
      await Firestore.instance.collection(userData).document(userData).setData({
        userData:userData
      });
      _showDialogWithText('Add data success!');
    } on PlatformException catch (err) {
      _showDialogWithText('${err.message}\n\nPlease check your login status');
    } catch (err) {
      _showDialogWithText('${err.message}\n\nPlease check your login status');
    }
  }

  void _databaseGetData() async{
    try{
      await Firestore.instance.collection(userData).getDocuments();
      _showDialogWithText('Get data success!');
      print('You can get data');
    } on PlatformException catch (err) {
      _showDialogWithText('${err.message}\n\nPlease check your login status');
    } catch (err) {
      _showDialogWithText('${err.message}\n\nPlease check your login status');
    }

  }

  List<Widget> _storageButtons(){
    return <Widget>[
      _regularButton('Upload File',Colors.white,Colors.deepOrange[900],_storageUploadFile),
      _regularButton('Download File',Colors.white,Colors.black,_storageDownloadFile),
    ];
  }

  void _storageUploadFile() async{
    try{
      File imageFileFromGallery = await ImagePicker.pickImage(source: ImageSource.gallery);
      if(imageFileFromGallery != null) {
        StorageReference reference = FirebaseStorage.instance.ref().child('testfile');
        StorageUploadTask uploadTask = reference.putFile(imageFileFromGallery);
        await uploadTask.onComplete;
//      StorageTaskSnapshot storageTaskSnapshot = await uploadTask.onComplete;
//      String imageURL = await storageTaskSnapshot.ref.getDownloadURL();
//      print('image URL is $imageURL');
      }
    } on PlatformException catch (err) {
      _showDialogWithText('${err.message}\n\nPlease check your login status');
    } catch (err) {
      _showDialogWithText('${err.message}\n\nPlease check your login status');
    }
  }

  void _storageDownloadFile() async{
    try{
      StorageReference reference = FirebaseStorage.instance.ref().child('testfile');
      String downloadURL = await reference.getDownloadURL();
      print('download URL is $downloadURL');
      _showDialogWithText('Download File success!');
    } on PlatformException catch (err) {
      _showDialogWithText('${err.message}\n\nPlease check your login status');
    } catch (err) {
      _showDialogWithText('${err.message}\n\nPlease check your login status');
    }
  }


  Widget _subjectTitle(String textString){
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(textString,style: TextStyle(fontWeight: FontWeight.bold,fontSize: 21),),
    );
  }

  Widget _regularButton(String buttonTextString, Color textColor, Color buttonColor, Function buttonEvent){
    return Padding(
      padding: const EdgeInsets.all(6.0),
      child: RaisedButton(
        onPressed: buttonEvent,
        child: Text(buttonTextString,style: TextStyle(color: textColor),),
        color: buttonColor,
        elevation:6,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  void _showDialogWithText(String textMessage) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Text(textMessage),
          );
        }
    );
  }
}