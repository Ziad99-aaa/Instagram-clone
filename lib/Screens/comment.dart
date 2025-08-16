import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_profile_picture/flutter_profile_picture.dart';
import 'package:insta/provider/user_provider.dart';
import 'package:insta/shared/colors.dart';
import 'package:insta/shared/contants.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class CommentScreen extends StatefulWidget {
  final String postId;
  final String profileImg;

  CommentScreen({super.key, required this.postId, required this.profileImg});

  @override
  State<CommentScreen> createState() => _CommentScreenState();
}

class _CommentScreenState extends State<CommentScreen> {
  final commentController = TextEditingController();
  bool isSending = false;
  bool isDone = false;

  @override
  Widget build(BuildContext context) {
    final allDataFromDB = Provider.of<UserProvider>(context).getUser;
    return Scaffold(
      backgroundColor: mobileBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(Icons.arrow_back, size: 30),
        ),
        backgroundColor: mobileBackgroundColor,
        title: Text(
          "Comments",
          style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          // Real-time comments
          Expanded(
            child: StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('posts')
                  .doc(widget.postId)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  );
                }

                if (!snapshot.hasData || snapshot.data?.data() == null) {
                  return Center(child: Text("No comments yet"));
                }

                var postData = snapshot.data!.data() as Map<String, dynamic>;
                List comments = postData['comments'] ?? [];

                return ListView.builder(
                  padding: EdgeInsets.all(8),
                  itemCount: comments.length,
                  itemBuilder: (context, index) {
                    var comment = comments[index];
                    String name = comment['name'] ?? '';
                    String text = comment['comment'] ?? '';
                    String profileImg = comment['profileImg'] ?? '';
                    DateTime date = (comment['date'] as Timestamp).toDate();
                    String formattedDate = DateFormat(
                      'dd/MM/yyyy',
                    ).format(date);

                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6.0),
                      child: Row(
                        children: [
                          SizedBox(width: 10),
                          ProfilePicture(
                            name: name.isNotEmpty ? name : "U",
                            radius: 31,
                            fontsize: 21,
                            img: profileImg.isNotEmpty ? profileImg : null,
                          ),
                          SizedBox(width: 10),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    name,
                                    style: TextStyle(
                                      fontSize: 21,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Text(text, style: TextStyle(fontSize: 20)),
                                ],
                              ),
                              Text(
                                formattedDate,
                                style: TextStyle(fontSize: 20),
                              ),
                            ],
                          ),
                          Spacer(),
                          IconButton(
                            onPressed: () {},
                            icon: Icon(Icons.favorite_border),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),

          // Comment input field
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                SizedBox(width: 10),
                ProfilePicture(
                  name: "z",
                  radius: 31,
                  fontsize: 21,
                  img: allDataFromDB!.profileImg,
                ),
                SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: commentController,
                    onChanged: (_) => setState(() {}),
                    decoration: decorationTextfield.copyWith(
                      hintText: "Comment ...",
                      fillColor: webBackgroundColor,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: commentController.text.trim().isEmpty || isSending
                      ? null
                      : () async {
                          setState(() {
                            isSending = true;
                          });

                          await addComment(
                            postId: widget.postId,
                            commentText: commentController.text.trim(),
                          );

                          setState(() {
                            isSending = false;
                            isDone = true;
                            commentController.clear();
                          });
                          if (!mounted) return;
                          await Future.delayed(Duration(seconds: 2));
                          setState(() {
                            isDone = false;
                          });
                        },
                  icon: isSending
                      ? SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : isDone
                      ? Icon(Icons.check_circle, color: Colors.green)
                      : Icon(Icons.send_rounded),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> addComment({
    required String postId,
    required String commentText,
  }) async {
    try {
      String uid = FirebaseAuth.instance.currentUser!.uid;

      DocumentSnapshot userSnap = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      Map<String, dynamic> userData = userSnap.data() as Map<String, dynamic>;

      Map<String, dynamic> commentData = {
        "name": userData["username"],
        "comment": commentText,
        "profileImg": userData["profileImg"],
        "date": DateTime.now(),
      };

      await FirebaseFirestore.instance.collection('posts').doc(postId).update({
        "comments": FieldValue.arrayUnion([commentData]),
      });

      print("✅ Comment added successfully");
    } catch (e) {
      print("❌ Error adding comment: $e");
    }
  }
}
