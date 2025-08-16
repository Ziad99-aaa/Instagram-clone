import 'dart:async';
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
  final List likes;

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
  bool showBigHeart = false;
  Timer? _heartTimer;

  @override
  void initState() {
    super.initState();
    String uid = FirebaseAuth.instance.currentUser!.uid;
    isLiked = widget.likes.contains(uid);
    likeCount = widget.likeCount;
  }

  @override
  void dispose() {
    _heartTimer?.cancel();
    super.dispose();
  }

  Future<void> toggleLike({bool fromDoubleTap = false}) async {
    try {
      String uid = FirebaseAuth.instance.currentUser!.uid;
      DocumentReference postRef =
          FirebaseFirestore.instance.collection('posts').doc(widget.postId);

      if (isLiked) {
        if (!fromDoubleTap) {
          // double tap will never dislike
          await postRef.update({
            "likes": FieldValue.arrayRemove([uid]),
          });
          if (!mounted) return;
          setState(() {
            isLiked = false;
            likeCount--;
          });
        }
      } else {
        await postRef.update({
          "likes": FieldValue.arrayUnion([uid]),
        });
        if (!mounted) return;
        setState(() {
          isLiked = true;
          likeCount++;
        });
      }
    } catch (e) {
      print("❌ Error toggling like: $e");
    }
  }

  void handleDoubleTap() {
    toggleLike(fromDoubleTap: true);

    if (!mounted) return; // ✅ avoid setState after dispose
    setState(() {
      showBigHeart = true;
    });

    _heartTimer?.cancel();
    _heartTimer = Timer(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() {
        showBigHeart = false;
      });
    });
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
          // 🔝 Top bar
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

                // ✅ safe null check for delete button
                (allDataFromDB != null &&
                        widget.username == allDataFromDB.username)
                    ? IconButton(
                        onPressed: () {
                          _showDeleteDialog(context);
                        },
                        icon: const Icon(Icons.more_vert_outlined, size: 25),
                      )
                    : const SizedBox(),
              ],
            ),
          ),

          // 🖼 Post Image + Heart overlay
          GestureDetector(
            onDoubleTap: handleDoubleTap,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Image.network(
                  widget.postImg,
                  height: MediaQuery.of(context).size.height * .35,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                // Big heart animation
                ...[100.0, 88.0, 73.0].map(
                  (size) => AnimatedOpacity(
                    opacity: showBigHeart ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.favorite,
                      size: size,
                      color: Colors.red.withOpacity(0.5),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ❤️ + 💬 actions
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
                    )
                  ),SizedBox(width: 10,),const Icon(Icons.send_rounded, size: 25),
                ],
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.bookmark_outline_rounded, size: 30),
              ),
            ],
          ),

          // 📌 likes, description, date
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
                    Flexible(
                      child: Text(
                        widget.description,
                        style: TextStyle(color: secondaryColor, fontSize: 20),
                        overflow: TextOverflow.ellipsis,
                      ),
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

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          title: const Text("Delete Post"),
          content: const Text("Are you sure you want to delete this post?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () async {
                try {
                  await FirebaseFirestore.instance
                      .collection('posts')
                      .doc(widget.postId)
                      .delete();
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("✅ Post deleted")),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("❌ Error deleting post: $e")),
                    );
                  }
                }
              },
              child: const Text(
                "Delete",
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}
