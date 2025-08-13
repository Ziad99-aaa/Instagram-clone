import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:insta/Screens/add.dart';
import 'package:insta/Screens/comment.dart';
import 'package:insta/Screens/fav.dart';
import 'package:insta/Screens/home.dart';
import 'package:insta/Screens/profile.dart';
import 'package:insta/Screens/search.dart';
import 'package:insta/shared/colors.dart';

class MobileScreen extends StatefulWidget {
  const MobileScreen({super.key});

  @override
  State<MobileScreen> createState() => _MobileScreenState();
}

class _MobileScreenState extends State<MobileScreen> {
  final PageController _pageController = PageController();
  var page = 0;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        bottomNavigationBar: CupertinoTabBar(
            onTap: (index) {
              _pageController.jumpToPage(index);
              // change icon color
            },
            backgroundColor: mobileBackgroundColor,
            items: [
              BottomNavigationBarItem(
                label: "Home",
                icon: Icon(
                    color: page == 0 ? primaryColor : secondaryColor,
                    Icons.home),
              ),
              BottomNavigationBarItem(
                label: "Search",
                icon: Icon(
                    color: page == 1 ? primaryColor : secondaryColor,
                    Icons.search),
              ),
              BottomNavigationBarItem(
                label: "Add",
                icon: Icon(
                    color: page == 2 ? primaryColor : secondaryColor,
                    Icons.add),
              ),
              BottomNavigationBarItem(
                label: "Fav",
                icon: Icon(
                    color: page == 3 ? primaryColor : secondaryColor,
                    Icons.favorite),
              ),
              BottomNavigationBarItem(
                label: "profile",
                icon: Icon(
                    color: page == 4 ? primaryColor : secondaryColor,
                    Icons.person),
              ),
            ]),
        body: PageView(
          onPageChanged: (index) {
            page = index;
            setState(() {});
          },
          physics: NeverScrollableScrollPhysics(),
          controller: _pageController,
          children: [Home(), Search(), Add(), Fav(), Profile()],
        ),
      ),
    );
  }
}
