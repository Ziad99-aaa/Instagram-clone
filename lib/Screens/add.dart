import 'dart:math';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:insta/shared/colors.dart';
import 'package:path/path.dart' show basename;

class Add extends StatefulWidget {
  const Add({super.key});

  @override
  State<Add> createState() => _AddState();
}

class _AddState extends State<Add> {
  Uint8List? imgPath;
  String? imgName;
  bool isUploading = false;
  Map userData = {};
  bool isLoading = true;
  int following = 0;
  int followers = 0;
  final TextEditingController captionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    getData();
  }

  uploadImage2Screen(ImageSource source) async {
    Navigator.pop(context);
    final XFile? pickedImg = await ImagePicker().pickImage(source: source);
    try {
      if (pickedImg != null) {
        Uint8List img = await pickedImg.readAsBytes();
        int random = Random().nextInt(9999999);
        String name = "$random${basename(pickedImg.path)}";

        setState(() {
          imgPath = img;
          imgName = name;
          isUploading = true;
        });
      } else {
        print("No image selected");
      }
    } catch (e) {
      print("Error => $e");
    }
  }

  showmodel() {
    return showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(22),
          height: 170,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () async {
                  await uploadImage2Screen(ImageSource.camera);
                },
                child: Row(
                  children: const [
                    Icon(Icons.camera, size: 30),
                    SizedBox(width: 11),
                    Text("From Camera", style: TextStyle(fontSize: 20)),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              GestureDetector(
                onTap: () async {
                  await uploadImage2Screen(ImageSource.gallery);
                },
                child: Row(
                  children: const [
                    Icon(Icons.photo_outlined, size: 30),
                    SizedBox(width: 11),
                    Text("From Gallery", style: TextStyle(fontSize: 20)),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  getData() async {
    setState(() {
      isLoading = true;
    });
    try {
      DocumentSnapshot<Map<String, dynamic>> user = await FirebaseFirestore
          .instance
          .collection('users')
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .get();
      userData = user.data()!;
      following = userData["following"].length;
      followers = userData["followers"].length;
    } catch (e) {
      print(e.toString());
    }
    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return isUploading
        ? Scaffold(
            backgroundColor: Colors.black,
            appBar: AppBar(
              backgroundColor: Colors.black,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  setState(() {
                    isUploading = false;
                    imgPath = null;
                    captionController.clear();
                  });
                },
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    // TODO: Handle post submission
                  },
                  child: const Text(
                    "Post",
                    style: TextStyle(color: Colors.blue, fontSize: 16),
                  ),
                ),
              ],
            ),
            body: isLoading
                ? const Center(child: CircularProgressIndicator())
                : Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Profile Picture
                            CircleAvatar(
                              radius: 24,
                              backgroundImage: NetworkImage(
                                userData["profileImg"],
                              ),
                            ),
                            const SizedBox(width: 12),

                            // Caption Input
                            Expanded(
                              child: TextField(
                                controller: captionController,
                                maxLines: null,
                                style: const TextStyle(color: Colors.white),
                                decoration: const InputDecoration(
                                  hintText: 'Write a caption...',
                                  hintStyle: TextStyle(color: Colors.grey),
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // ✅ Display selected image from memory
                        if (imgPath != null)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.memory(
                              imgPath!,
                              height: MediaQuery.of(context).size.height * 0.25,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                      ],
                    ),
                  ),
          )
        : Scaffold(
            backgroundColor: mobileBackgroundColor,
            body: Center(
              child: IconButton(
                onPressed: () {
                  showmodel();
                },
                icon: const Icon(Icons.file_upload, size: 60),
              ),
            ),
          );
  }
}
