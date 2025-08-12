import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:insta/shared/colors.dart';

class SearchProfile extends StatefulWidget {
  final Map userData; // Data of the user whose profile is being viewed
  final String uid; // UID of the user being viewed
  final bool isfollowing; // Initial following status

  const SearchProfile({
    super.key,
    required this.userData,
    required this.uid,
    required this.isfollowing,
  });

  @override
  State<SearchProfile> createState() => _SearchProfileState();
}

class _SearchProfileState extends State<SearchProfile> {
  late bool _isFollowing; // Track whether the current user follows this profile
  late List followers; // List of followers for the viewed user

  @override
  void initState() {
    super.initState();
    _isFollowing = widget.isfollowing;
    followers = List.from(widget.userData["followers"]);
    print(
      "initState completed -> isFollowing: $_isFollowing, followers count: ${followers.length}",
    );
  }

  /// Function to follow/unfollow the user
  Future<void> toggleFollow() async {
    String currentUid = FirebaseAuth.instance.currentUser!.uid;

    DocumentReference userRef = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.uid);
    DocumentReference currentUserRef = FirebaseFirestore.instance
        .collection('users')
        .doc(currentUid);

    if (_isFollowing) {
      // UNFOLLOW LOGIC
      await userRef.update({
        "followers": FieldValue.arrayRemove([currentUid]),
      });
      await currentUserRef.update({
        "following": FieldValue.arrayRemove([widget.uid]),
      });

      setState(() {
        followers.remove(currentUid);
        _isFollowing = false;
      });

      print("toggleFollow -> Unfollowed user: ${widget.uid}");
    } else {
      // FOLLOW LOGIC
      await userRef.update({
        "followers": FieldValue.arrayUnion([currentUid]),
      });
      await currentUserRef.update({
        "following": FieldValue.arrayUnion([widget.uid]),
      });

      setState(() {
        followers.add(currentUid);
        _isFollowing = true;
      });

      print("toggleFollow -> Followed user: ${widget.uid}");
    }
  }

  @override
  Widget build(BuildContext context) {
    final double widthScreen = MediaQuery.of(context).size.width;

    print("build method executed -> followers count: ${followers.length}");

    return Scaffold(
      backgroundColor: mobileBackgroundColor,
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        title: Text(widget.userData["username"]),
      ),
      body: Column(
        children: [
          // --- PROFILE HEADER SECTION ---
          Row(
            children: [
              // Profile Image
              Container(
                margin: const EdgeInsets.only(left: 22),
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color.fromARGB(125, 78, 91, 110),
                ),
                child: CircleAvatar(
                  radius: 40,
                  backgroundImage: NetworkImage(widget.userData["profileImg"]),
                ),
              ),

              // Stats: Posts / Followers / Following
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildCountColumn("0", "Posts"),
                    const SizedBox(width: 17),
                    _buildCountColumn(followers.length.toString(), "Followers"),
                    const SizedBox(width: 17),
                    _buildCountColumn(
                      widget.userData["following"].length.toString(),
                      "Following",
                    ),
                  ],
                ),
              ),
            ],
          ),

          // --- TITLE / BIO ---
          Container(
            margin: const EdgeInsets.fromLTRB(45, 21, 0, 0),
            width: double.infinity,
            child: Text(
              widget.userData["title"] ?? "",
              style: const TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(height: 15),

          // --- FOLLOW / UNFOLLOW BUTTON ---
          ElevatedButton.icon(
            onPressed: toggleFollow,
            icon: Icon(
              _isFollowing ? Icons.person_remove : Icons.person_add,
              size: 20,
              color: Colors.white,
            ),
            label: Text(
              _isFollowing ? "Unfollow" : "Follow",
              style: const TextStyle(fontSize: 17, color: Colors.white),
            ),
            style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all(
                _isFollowing
                    ? const Color.fromARGB(143, 255, 0, 0)
                    : const Color.fromARGB(143, 25, 0, 255),
              ),
              padding: MaterialStateProperty.all(
                EdgeInsets.symmetric(
                  vertical: widthScreen > 600 ? 19 : 10,
                  horizontal: 33,
                ),
              ),
              shape: MaterialStateProperty.all(
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
              ),
            ),
          ),
          const SizedBox(height: 9),

          Divider(
            color: const Color.fromARGB(255, 54, 54, 54),
            thickness: widthScreen > 600 ? 0.06 : 0.44,
          ),
          const SizedBox(height: 19),

          // --- POSTS GRID ---
          Expanded(
            child: FutureBuilder<QuerySnapshot>(
              future: FirebaseFirestore.instance
                  .collection('posts')
                  .where("uid", isEqualTo: widget.uid)
                  .get(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  print("FutureBuilder error: ${snapshot.error}");
                  return const Center(child: Text("Something went wrong"));
                }
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  );
                }

                var posts = snapshot.data!.docs;
                print("Posts fetched -> count: ${posts.length}");

                if (posts.isEmpty) {
                  return const Center(
                    child: Text(
                      "No posts yet",
                      style: TextStyle(color: Colors.white70),
                    ),
                  );
                }

                return Padding(
                  padding: widthScreen > 600
                      ? const EdgeInsets.all(66.0)
                      : const EdgeInsets.all(3.0),
                  child: GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 3 / 2,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                    itemCount: posts.length,
                    itemBuilder: (context, index) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: Image.network(
                          posts[index]["imgPost"],
                          fit: BoxFit.cover,
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Helper widget for displaying counts (Posts / Followers / Following)
  Column _buildCountColumn(String count, String label) {
    print("_buildCountColumn executed -> $label: $count");
    return Column(
      children: [
        Text(
          count,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          label,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}
