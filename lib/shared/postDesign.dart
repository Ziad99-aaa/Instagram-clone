import 'package:flutter/material.dart';
import 'package:flutter_profile_picture/flutter_profile_picture.dart';
import 'package:insta/Screens/comment.dart';
import 'package:intl/intl.dart';
import 'package:insta/shared/colors.dart';

class Post extends StatelessWidget {
  final String username;
  final String postImg;
  final int likeCount;
  final String description;
  final String userImg;
  final DateTime date;
  final String postId;
  


  const Post({
    super.key,

    required this.username,
    required this.postImg,
    required this.likeCount,
    required this.description,
    required this.date,
    required this.userImg,
    required this.postId,
  });

  @override
  Widget build(BuildContext context) {
    final double widthScreen = MediaQuery.of(context).size.width;

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
                      name: username,
                      radius: 31,
                      fontsize: 21,
                      img: userImg,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 20),
                      child: Text(
                        username,
                        style: const TextStyle(fontSize: 22),
                      ),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () {},
                  icon: const Icon(Icons.more_vert_outlined, size: 25),
                ),
              ],
            ),
          ),

          // Post Image
          Image.network(
            postImg,
            height: MediaQuery.of(context).size.height * .25,
            width: double.infinity,
            fit: BoxFit.cover,
          ),

          // Action buttons (like, comment, share, save)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.favorite_border_outlined, size: 25),
                  ),
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CommentScreen(profileImg: userImg,postId: postId),
                        ),
                      );
                    },
                    icon: const Icon(Icons.message_outlined, size: 25),
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
                      username,
                      style: TextStyle(color: primaryColor, fontSize: 20),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      description,
                      style: TextStyle(color: secondaryColor, fontSize: 20),
                    ),
                  ],
                ),
                Text(
                  DateFormat('yyyy-MM-dd HH:mm').format(date),
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
