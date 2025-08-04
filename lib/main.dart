import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:insta/Screens/register.dart';
import 'package:insta/Screens/sign_in.dart';
import 'package:insta/firebase_options.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:insta/provider/user_provider.dart';
import 'package:insta/responsive/mobile.dart';
import 'package:insta/responsive/responsive.dart';
import 'package:insta/responsive/web.dart';
import 'package:insta/shared/snackbar.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: "AIzaSyBnAfL7Q__4x6osgOSyZyu1qRVsQ1sYvGo",
        authDomain: "insta-1cc5a.firebaseapp.com",
        projectId: "insta-1cc5a",
        storageBucket: "insta-1cc5a.firebasestorage.app",
        messagingSenderId: "1044856833793",
        appId: "1:1044856833793:web:7bb5e1b6edbe954437bd00",
      ),
    );
  } else {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
          create: (context) {return UserProvider();},
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark(),
        home: StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(color: Colors.white),
              );
            } else if (snapshot.hasError) {
              return showSnackBar(context, "Something went wrong");
            } else if (snapshot.hasData) {
              return Responsive(
                myMobileScreen: MobileScreen(),
                myWebScreen: WebScreen(),
              );
            } else {
              return Login();
            }
          },
        ),
        // Responsive(
        //   myMobileScreen: MobileScreen(),
        //   myWebScreen: WebScreen(),
        // ),
      ),
    );
  }
}
