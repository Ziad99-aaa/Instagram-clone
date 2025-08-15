import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:insta/fire_base_services/imgApi.dart';
import 'package:insta/models/user.dart';
import 'package:insta/shared/snackbar.dart';

class Auth {
  /// Register a new user with email, password, profile image & extra data
  Future<void> register({
    required String emaill,
    required String pass,
    required String userNamee,
    required String titlee,
    required String imgName,
    required Uint8List imgPath,
    required context,
  }) async {
    String message = "❌ Unknown error";
    try {
      // Step 1: Create user in Firebase Auth
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: emaill, password: pass);

      message = "✅ Account created, uploading profile image...";

      // Step 2: Upload profile image to ImgBB
      String urlll = await uploadToImgBB(imgpath: imgPath, imgName: imgName);

      // Step 3: Save user data to Firestore
      UserData user = UserData(
        username: userNamee,
        email: emaill,
        password: pass,
        title: titlee,
        profileImg: urlll,
        followers: [],
        following: [],
      );

      await FirebaseFirestore.instance
          .collection('users')
          .doc(credential.user!.uid)
          .set(user.convert2Map());

      message = "🎉 User registered successfully!";
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        message = "⚠️ The password provided is too weak.";
      } else if (e.code == 'email-already-in-use') {
        message = "⚠️ The account already exists for that email.";
      } else {
        message = "⚠️ ${e.message}";
      }
    } catch (e) {
      message = "❌ Error: $e";
    }

    // Show result to user
    showSnackBar(context, message);
  }

  /// Sign in existing user
  Future<void> signIn({
    required String emaill,
    required String passwordd,
    required context,
  }) async {
    String message = "";
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emaill,
        password: passwordd,
      );
      message = "✅ Logged in successfully!";
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        message = "⚠️ No user found for that email.";
      } else if (e.code == 'wrong-password') {
        message = "⚠️ Wrong password provided.";
      } else {
        message = "⚠️ ${e.message}";
      }
    } catch (e) {
      message = "❌ Error: $e";
    }
    showSnackBar(context, message);
  }

  /// Get current logged-in user's data from Firestore
  Future<UserData> getUserDetails() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      print("no user");
    }
    DocumentSnapshot snap = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .get();
    return UserData.convertSnap2Model(snap);
  }
}
