import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:insta/fire_base_services/imgApi.dart';
import 'package:insta/fire_base_services/storage.dart';
import 'package:insta/models/post.dart';
import 'package:insta/shared/snackbar.dart';

import 'package:uuid/uuid.dart';

class FirestoreMethods {
  uploadPost({
    required imgName,
    required imgPath,
    required description,
    required profileImg,
    required username,
    required context,
  }) async {
    String message = "ERROR => Not starting the code";

    try {
      // ______________________________________________________________________
      String urlll = await uploadToImgBB(imgpath: imgPath, imgName: imgName);

            // String urlll = await getImgURL(
            //     imgName: imgName,
            //     imgPath: imgPath,
            //     folderName: 'imgPosts/${FirebaseAuth.instance.currentUser!.uid}');

      // // _______________________________________________________________________
      // firebase firestore (Database)
      CollectionReference posts = FirebaseFirestore.instance.collection(
        'posts',
      );

      String newId = const Uuid().v1();

      PostData postt = PostData(
        datePublished: DateTime.now(),
        description: description,
        imgPost: urlll,
        likes: [],
        profileImg: profileImg,
        postId: newId,
        uid: FirebaseAuth.instance.currentUser!.uid,
        username: username,
      );

      message = "ERROR => erroe hereeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee";
      posts
          .doc(newId)
          .set(postt.convert2Map())
          .then((value) => print("done................"))
          .catchError((error) => print("Failed to post: $error"));

      message = " Posted successfully ♥ ♥";
    } on FirebaseAuthException catch (e) {
      showSnackBar(context, "ERROR :  ${e.code} ");
    } catch (e) {
      print(e);
    }

    showSnackBar(context, message);
  }
}
