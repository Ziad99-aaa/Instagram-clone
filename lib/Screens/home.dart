import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:insta/shared/colors.dart';

import 'package:flutter_profile_picture/flutter_profile_picture.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  @override
  Widget build(BuildContext context) {
    final double widthScreen = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor:
          widthScreen > 600 ? webBackgroundColor : mobileBackgroundColor,
      appBar: widthScreen > 600
          ? null
          : AppBar(
              toolbarHeight: 100,
              title: SvgPicture.asset(
                "assets/img/instagram.svg",
                // ignore: deprecated_member_use
                color: primaryColor,
                height: 32,
              ),
              actions: [
                IconButton(
                    onPressed: () {},
                    icon: Icon(
                      Icons.messenger_outline,
                      size: 28,
                    )),
                IconButton(
                    onPressed: () {},
                    icon: Icon(
                      Icons.output_outlined,
                      size: 28,
                    ))
              ],
            ),
      body: Container(
        decoration: BoxDecoration(
            color: mobileBackgroundColor,
            borderRadius: BorderRadius.circular(15)),
        margin: EdgeInsets.symmetric(vertical: 20, horizontal: widthScreen>600? widthScreen/4:0),
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(13),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      ProfilePicture(
                        name: 'z',
                        radius: 31,
                        fontsize: 21,
                      ),
                      Padding(
                        padding: EdgeInsets.only(left: 20),
                        child: Text(
                          "Usernamee",
                          style: TextStyle(fontSize: 22),
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                      onPressed: () {},
                      icon: Icon(
                        Icons.more_vert_outlined,
                        size: 25,
                      ))
                ],
              ),
            ),
            Image.network(
                height: MediaQuery.of(context).size.height * .25,
                width: double.infinity,
                fit: BoxFit.cover,
                "https://tse4.mm.bing.net/th/id/OIP.jfHpU8YVBzzsNyzAU0kz2AHaEK?rs=1&pid=ImgDetMain&o=7&rm=3"),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    IconButton(
                        onPressed: () {},
                        icon: Icon(
                          Icons.favorite_border_outlined,
                          size: 25,
                        )),
                    IconButton(
                        onPressed: () {},
                        icon: Icon(
                          Icons.message_outlined,
                          size: 25,
                        )),
                    IconButton(
                        onPressed: () {},
                        icon: Icon(
                          Icons.send,
                          size: 25,
                        )),
                  ],
                ),
                IconButton(
                    onPressed: () {},
                    icon: Icon(
                      Icons.save_alt_outlined,
                      size: 25,
                    ))
              ],
            ),
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "10 like",
                    style: TextStyle(color: secondaryColor, fontSize: 20),
                  ),
                  Row(
                    children: [
                      Text(
                        "ziad ramy",
                        style: TextStyle(color: primaryColor, fontSize: 20),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        "messi",
                        style: TextStyle(color: secondaryColor, fontSize: 20),
                      ),
                    ],
                  ),
                  Text(
                    "10 june 2025",
                    style: TextStyle(color: secondaryColor, fontSize: 20),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
