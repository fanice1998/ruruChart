import 'dart:ffi';
import 'dart:ui';

import 'package:circle_nav_bar/circle_nav_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  // appBar 需要使用 automaticallyImplyLeading: false 禁用返回按鈕
  @override
  Widget build(BuildContext context){
    // return DefaultTabController(
    //   length: 3, 
    //   child: Scaffold(
    //     appBar: AppBar(
    //       automaticallyImplyLeading: false,
    //       title: const Text("test1 appbar"),
    //       bottom: const TabBar(tabs: [
    //           Tab(icon: Icon(Icons.directions_car), text: 'Car'),
    //           Tab(icon: Icon(Icons.directions_transit), text: 'Transit'),
    //           Tab(icon: Icon(Icons.directions_bike), text: 'Bike'),
    //       ],),),
    //       body: const TabBarView(
    //         children: [
    //         Center(child: Text('Car Page')),
    //         Center(child: Text('Transit Page')),
    //         Center(child: Text('Bike Page')),
    //         ],
    //       ),
    //     ));
    return Scaffold(
      // AppBarrrrr
      appBar: AppBar(
        title: const Text("Half Circle Button Example"),
        automaticallyImplyLeading: false,
      ),
      // Bodyyyyyyyyy
      body: const Center(child: Text("HaHa")),
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
      bottomNavigationBar: RadiusBottomNav(tabIndex2: 1),
    );
  }
}

class RadiusBottomNav extends StatefulWidget{
  int tabIndex2;
  const RadiusBottomNav({
    Key? key, 
    required this.tabIndex2,
    }): super(key: key);

  @override
  State<RadiusBottomNav> createState() => _RadiusBottomNav();
}

class _RadiusBottomNav extends State<RadiusBottomNav> with SingleTickerProviderStateMixin{
  // int tabIndex2;
  int get tabIndex => tabIndex2;
  set tabIndex(int v) {
    tabIndex2 = v;
    setState(() {});
  }

  late PageController pageController;

  @override
  void initState(){
    super.initState();
    pageController = PageController( initialPage: tabIndex2);
  }

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
        activeIndex: tabIndex,
        onTap: (index) {
          tabIndex = index;
          pageController.jumpToPage(tabIndex);
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