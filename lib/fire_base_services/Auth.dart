import 'package:firebase_auth/firebase_auth.dart';
import 'package:insta/fire_base_services/imgApi.dart';
import 'package:insta/fire_base_services/storage.dart';
import 'package:insta/models/user.dart';
import 'package:insta/shared/snackbar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Auth {
  register({
    required emaill,
    required pass,
    required userNamee,
    required titlee,
    required imgName,
    required imgPath,
    required context,
  }) async {
    String message = "ERORR=> no read";
    try {
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: emaill, password: pass);
      message = "ERORR=> Registerd only";

      // __________________________________

      // String urlll = getImgURL(imgName: imgName, imgPath: imgPath);
      String urlll = await uploadToImgBB(imgpath: imgPath, imgName: imgName);
      // ____________________________________
      message = "ERORR=> img upload";
      CollectionReference users = FirebaseFirestore.instance.collection(
        'users',
      );
      UserDate user = UserDate(
        username: userNamee,
        email: emaill,
        password: pass,
        title: titlee,
        profileImg: urlll,
      );

      users
          .doc(credential.user!.uid)
          .set(user.convert2Map())
          .then((value) => print("User Added"))
          .catchError((error) => print("Failed to add user: $error"));
      message = "✅ User registered and data saved";
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
    showSnackBar(context, message);
  }

  signIn({required emaill, required passwordd}) async {
    try {
      // ignore: unused_local_variable
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: emaill,
        password: passwordd,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        print('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        print('Wrong password provided for that user.');
      }
    }
  }
}
