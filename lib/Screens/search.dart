import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth;
import 'package:flutter/material.dart';
import 'package:flutter_profile_picture/flutter_profile_picture.dart';
import 'package:insta/Screens/searchProfile.dart';
import 'package:insta/shared/colors.dart';
import 'package:insta/shared/contants.dart';

class Search extends StatefulWidget {
  const Search({super.key});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  final searchController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: mobileBackgroundColor,
        appBar: AppBar(
          backgroundColor: mobileBackgroundColor,
          title: TextField(
            controller: searchController,
            onChanged: (value) => setState(() {}), // Refresh search results
            decoration: decorationTextfield.copyWith(
              hintText: "Search ...",
              fillColor: mobileBackgroundColor,
            ),
          ),
        ),
        body: searchController.text.trim().isEmpty
            ? const Center(
                child: Text(
                  "Type a username to search",
                  style: TextStyle(color: Colors.white70),
                ),
              )
            : StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('users')
                    .orderBy('username')
                    .startAt([searchController.text])
                    .endAt([searchController.text + '\uf8ff'])
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(child: Text("Something went wrong"));
                  }

                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    );
                  }

                  var docs = snapshot.data!.docs;

                  if (docs.isEmpty) {
                    return const Center(
                      child: Text(
                        "No users found",
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  }

                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      var user = docs[index];
                      return ListTile(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SearchProfile(
                                userData: user.data() as Map,
                                uid: user.id,
                                isfollowing: user["followers"].contains(
                                  FirebaseAuth.instance.currentUser!.uid,
                                ),
                              ),
                            ),
                          );
                          // Navigate to profile
                        },
                        leading: ProfilePicture(
                          name: user["username"],
                          radius: 25,
                          fontsize: 18,
                          img: user["profileImg"],
                        ),
                        title: Text(
                          user["username"],
                          style: const TextStyle(color: Colors.white),
                        ),
                      );
                    },
                  );
                },
              ),
      ),
    );
  }
}
