import 'package:firebase_auth/firebase_auth.dart';
import 'package:insta/shared/snackbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Auth {
  register({
    required email,
    required pass,
    required userName,
    required title,
    required context,
  }) async {
    String message = "ERORR=> no read";
    try {
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: pass);
      message = "ERORR=> Registerd only";
      CollectionReference users = FirebaseFirestore.instance.collection(
        'users',
      );
      users
          .doc(credential.user!.uid)
          .set({
            'user name': userName,
            'title': title,
            'email': email,
            'password': pass,
          })
          .then((value) => print("User Added"))
          .catchError((error) => print("Failed to add user: $error"));
      message = "ERORR=> Registerd & User added 💕";
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        showSnackBar(context, "The password provided is too weak.");
      } else if (e.code == 'email-already-in-use') {
        showSnackBar(context, "The account already exists for that email.");
      } else {
        showSnackBar(context, "ERROR - Please try again late");
      }
    } catch (e) {
      print(e);
    }
     print(message);
  }
}
