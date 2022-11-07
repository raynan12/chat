// ignore_for_file: prefer_const_constructors

import 'package:chat/helpers/helper_function.dart';
import 'package:chat/pages/auth/login_page.dart';
import 'package:chat/pages/home_page.dart';
import 'package:chat/shared/constants.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if(kIsWeb) {
    await Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: Constants.apiKey, 
        appId: Constants.appId, 
        messagingSenderId: Constants.messagingSenderId, 
        projectId: Constants.projectId));
  } else {
    await Firebase.initializeApp();
  }

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _isSignedIn = false;

  @override
  void initState() {
    super.initState();
    getUserLoggedInStatus();
  }

  getUserLoggedInStatus() async {
    await HelperFunctions.getUserLoggedInStatus().then((value) {
      if(value != null) {
        setState(() {
          _isSignedIn = value;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Constants().primaryColor,
        scaffoldBackgroundColor: Colors.white),
      home: _isSignedIn ? HomePage() : LoginPage(),
    );
  }
}

/*
// Import the functions you need from the SDKs you need
import { initializeApp } from "firebase/app";
// TODO: Add SDKs for Firebase products that you want to use
// https://firebase.google.com/docs/web/setup#available-libraries

// Your web app's Firebase configuration
const firebaseConfig = {
  apiKey: "AIzaSyBLC2AB6qS92Rr4nwmZ8_lbKQ6ITb0xSe8",
  authDomain: "chatflutter93418.firebaseapp.com",
  projectId: "chatflutter93418",
  storageBucket: "chatflutter93418.appspot.com",
  messagingSenderId: "938850566712",
  appId: "1:938850566712:web:8977d4eadeff372e085ccd"
};

// Initialize Firebase
const app = initializeApp(firebaseConfig);
*/