import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_profile_picture/flutter_profile_picture.dart';
import 'package:insta/Screens/comment.dart';
import 'package:insta/provider/user_provider.dart';
import 'package:intl/intl.dart';
import 'package:insta/shared/colors.dart';
import 'package:provider/provider.dart';

class Post extends StatefulWidget {
  final String username;
  final String postImg;
  final int likeCount;
  final int commentCount;
  final String description;
  final String userImg;
  final DateTime date;
  final String postId;
  final List likes; // ✅ added to know who liked

  const Post({
    super.key,
    required this.username,
    required this.postImg,
    required this.likeCount,
    required this.commentCount,
    required this.description,
    required this.userImg,
    required this.date,
    required this.postId,
    required this.likes,
  });

  @override
  State<Post> createState() => _PostState();
}

class _PostState extends State<Post> {
  late bool isLiked;
  late int likeCount;

  @override
  void initState() {
    super.initState();
    String uid = FirebaseAuth.instance.currentUser!.uid;
    isLiked = widget.likes.contains(uid);
    likeCount = widget.likeCount;
  }

  Future<void> toggleLike() async {
    try {
      String uid = FirebaseAuth.instance.currentUser!.uid;
      DocumentReference postRef = FirebaseFirestore.instance
          .collection('posts')
          .doc(widget.postId);

      if (isLiked) {
        // ✅ Unlike
        await postRef.update({
          "likes": FieldValue.arrayRemove([uid]),
        });
        setState(() {
          isLiked = false;
          likeCount--;
        });
      } else {
        // ✅ Like
        await postRef.update({
          "likes": FieldValue.arrayUnion([uid]),
        });
        setState(() {
          isLiked = true;
          likeCount++;
        });
      }
    } catch (e) {
      print("❌ Error toggling like: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final double widthScreen = MediaQuery.of(context).size.width;
    final allDataFromDB = Provider.of<UserProvider>(context).getUser;

    return Container(
      decoration: BoxDecoration(
        color: mobileBackgroundColor,
        borderRadius: BorderRadius.circular(15),
      ),
      margin: EdgeInsets.symmetric(
        vertical: 20,
        horizontal: widthScreen > 600 ? widthScreen / 4 : 0,
      ),
      child: Column(
        children: [
          // Top bar (profile + username + menu)
          Padding(
            padding: const EdgeInsets.all(13),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    ProfilePicture(
                      name: widget.username,
                      radius: 31,
                      fontsize: 21,
                      img: widget.userImg,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: Text(
                        widget.username,
                        style: const TextStyle(fontSize: 22),
                      ),
                    ),
                  ],
                ),
                widget.username != allDataFromDB!.username
                    ? const SizedBox()
                    : IconButton(
                        onPressed: () {
                          final parentContext = context;

                          showDialog(
                            context: parentContext,
                            builder: (BuildContext dialogContext) {
                              return SimpleDialog(
                                children: [
                                  SimpleDialogOption(
                                    padding: const EdgeInsets.all(20),
                                    onPressed: () async {
                                      Navigator.of(dialogContext).pop();
                                      await FirebaseFirestore.instance
                                          .collection('posts')
                                          .doc(widget.postId)
                                          .delete();

                                      if (parentContext.mounted) {
                                        ScaffoldMessenger.of(
                                          parentContext,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text('Post deleted'),
                                          ),
                                        );
                                      }
                                    },
                                    child: const Text('Delete Post'),
                                  ),
                                  SimpleDialogOption(
                                    padding: const EdgeInsets.all(20),
                                    onPressed: () {
                                      Navigator.of(dialogContext).pop();
                                    },
                                    child: const Text('Cancel'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        icon: const Icon(Icons.more_vert_outlined, size: 25),
                      ),
              ],
            ),
          ),

          // Post Image
          Image.network(
            widget.postImg,
            height: MediaQuery.of(context).size.height * .25,
            width: double.infinity,
            fit: BoxFit.cover,
          ),

          // Action buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: toggleLike,
                    icon: Icon(
                      isLiked ? Icons.favorite : Icons.favorite_border_outlined,
                      size: 25,
                      color: isLiked ? Colors.red : null,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CommentScreen(
                            profileImg: widget.userImg,
                            postId: widget.postId,
                          ),
                        ),
                      );
                    },
                    icon: Row(
                      children: [
                        const Icon(Icons.message_outlined, size: 25),
                        Text(
                          widget.commentCount > 99
                              ? "99+"
                              : widget.commentCount.toString(),
                          style: const TextStyle(fontSize: 20),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.send, size: 25),
                  ),
                ],
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.save_alt_outlined, size: 25),
              ),
            ],
          ),

          // Likes, description, and date
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "$likeCount likes",
                  style: TextStyle(color: secondaryColor, fontSize: 20),
                ),
                Row(
                  children: [
                    Text(
                      widget.username,
                      style: TextStyle(color: primaryColor, fontSize: 20),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      widget.description,
                      style: TextStyle(color: secondaryColor, fontSize: 20),
                    ),
                  ],
                ),
                Text(
                  DateFormat('yyyy-MM-dd HH:mm').format(widget.date),
                  style: TextStyle(color: secondaryColor, fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
