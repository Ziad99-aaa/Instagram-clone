import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:insta/Screens/add.dart';
import 'package:insta/Screens/fav.dart';
import 'package:insta/Screens/home.dart';
import 'package:insta/Screens/profile.dart';
import 'package:insta/Screens/search.dart';
import 'package:insta/shared/colors.dart';

class WebScreen extends StatefulWidget {
  const WebScreen({super.key});

  @override
  State<WebScreen> createState() => _WebScreenState();
}

class _WebScreenState extends State<WebScreen> {
  final PageController _pageController = PageController();
  var page = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 100,
        title: SvgPicture.asset(
          "assets/img/instagram.svg",
          color: primaryColor,
          height: 32,
        ),
        actions: [
          IconButton(
              onPressed: () {
                _pageController.jumpToPage(0);
              },
              icon: Icon(
                Icons.home,
                color:  page == 0 ? primaryColor : secondaryColor,
                size: 28,
              )),
          IconButton(
              onPressed: () {
                _pageController.jumpToPage(1);
              },
              icon: Icon(
                Icons.search,
                color:  page == 1 ? primaryColor : secondaryColor,
                size: 28,
              )),
          IconButton(
              onPressed: () {
                _pageController.jumpToPage(2);
              },
              icon: Icon(
                Icons.add_a_photo,
                color:  page == 2 ? primaryColor : secondaryColor,
                size: 28,
              )),
          IconButton(
              onPressed: () {
                _pageController.jumpToPage(3);
              },
              icon: Icon(
                Icons.favorite,
                color: page == 3 ? primaryColor : secondaryColor,
                size: 28,
              )),
          IconButton(
              onPressed: () {
                _pageController.jumpToPage(4);
              },
              icon: Icon(
                Icons.person,
                color: page == 4? primaryColor : secondaryColor,
                size: 28,
              )),
        ],
      ),
      body: PageView(
        onPageChanged: (index) {
          page = index;
          setState(() {});
        },
        physics: NeverScrollableScrollPhysics(),
        controller: _pageController,
        children: [Home(), Search(), Add(), Fav(), Profile()],
      ),
    );
  }
}
