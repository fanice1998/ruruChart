import 'dart:ui';

import 'package:circle_nav_bar/circle_nav_bar.dart';
import 'package:client/homePage/msgPage/msg_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}): super(key: key);

  @override
  State<HomePage> createState() => _HomePage();
}

class _HomePage extends State<HomePage> with SingleTickerProviderStateMixin{
  // const _HomePage({super.key});
  int _tabIndex = 1;
  int get tabIndex => _tabIndex;
  set tabIndex (int v) {
    _tabIndex = v; 
    setState(() {});
  }

  late PageController pageController;

  void _upTabIndex(int value) {
    setState(() {
      tabIndex = value;
      pageController.jumpToPage(tabIndex);
    });
  }

  @override
  void initState() {
    super.initState();
    pageController = PageController(initialPage: _tabIndex);
  }

  // appBar 需要使用 automaticallyImplyLeading: false 禁用返回按鈕
  @override
  Widget build(BuildContext context){
    return Scaffold(
      // AppBarrrrr
      appBar: AppBar(
        title: const Text("Half Circle Button Example"),
        automaticallyImplyLeading: false,
      ),
      // Bodyyyyyyyyy
      body: PageView(
        controller: pageController,
        onPageChanged: (v){
          tabIndex = v;
        },children: [
            // Container(width: double.infinity, height: double.infinity, color: Colors.red),
            MsgPage(),
            Container(width: double.infinity, height: double.infinity, color: Colors.green),
            Container(width: double.infinity, height: double.infinity, color: Colors.blue),
        ],
      ),
      // floatingActionButton
      // floatingActionButton: CircleButton(onTap: () {
      //   print("Home");
      //   Navigator.pushNamed(context, '/home');
      //   }, 
      //   iconData: Icons.home,
      //   ),
      // floatingActionButtonLocation
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      // bottomNavigationBar
      bottomNavigationBar: RadiusBottomNav(
        upTabIndex: _upTabIndex,
        tabIndex: tabIndex,
        ),
    );
  }
}

class RadiusBottomNav extends StatefulWidget{
  final Function(int) upTabIndex;
  final int tabIndex;
  RadiusBottomNav({
    required this.upTabIndex,
    required this.tabIndex,
    }):super();
  // int tabIndex;

  @override
  State<RadiusBottomNav> createState() => _RadiusBottomNav();
}

class _RadiusBottomNav extends State<RadiusBottomNav> with SingleTickerProviderStateMixin{
  // late PageController pageController;

  // @override
  // void initState(){
  //   super.initState();
  //   pageController = PageController(initialPage: _tabIndex);
  // }

  @override
  Widget build(BuildContext context) {
    return CircleNavBar(
        activeIcons: const [
          Icon(Icons.messenger_outline, color: Colors.white,),
          Icon(Icons.home, color: Colors.white,),
          Icon(Icons.settings, color: Colors.white),
        ],
        inactiveIcons: const [
          Text(
          "msg",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
          Text(
          "home",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
          Text(
          "setting",
          style: TextStyle(
            color: Colors.white,
          ),
        )
        ],
        color: Colors.grey,
        circleColor: Colors.white,
        height: 60,
        circleWidth: 60,
        activeIndex: widget.tabIndex,
        onTap: (index) {
          // tabIndex = index;
          // pageController.jumpToPage(tabIndex);
          widget.upTabIndex(index);
        },
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 20),
        cornerRadius: const BorderRadius.only(
          topLeft: Radius.circular(8),
          topRight: Radius.circular(8),
          bottomRight: Radius.circular(24),
          bottomLeft: Radius.circular(24),
        ),
        shadowColor:Colors.deepPurple,
        circleShadowColor: Colors.deepOrangeAccent,
        elevation: 10,
        gradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [Colors.blue, Colors.red],
        ),
        circleGradient: const LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [Colors.blue, Colors.red],
        ),
        
      );
  }
}