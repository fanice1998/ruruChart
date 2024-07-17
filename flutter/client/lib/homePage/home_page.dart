import 'package:flutter/material.dart';

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
      appBar: AppBar(
        title: const Text("Half Circle Button Example"),
        automaticallyImplyLeading: false,
      ),
      body: const Center(child: Text("HaHa")),
      floatingActionButton: SemiCircleButton(
        onPressed: () {
          Navigator.of(context).pushReplacementNamed('/home');
        }
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

class SemiCircleButton extends StatelessWidget {
  final VoidCallback onPressed;

  const SemiCircleButton({Key? key, required this.onPressed}): super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: GestureDetector(
        onTap: onPressed,
        child: CustomPaint(
          painter: SemiCirclePainter(),
          child: Container(
            height: 50,
            child: const  Center(
              child: Icon(Icons.home, color: Colors.white,),
            ),
          ),
        ),
      ),
    );
  }
}


class SemiCirclePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint= Paint()
    ..color = Colors.blue
    ..style = PaintingStyle.fill;

    final path = Path()
    ..moveTo(0, size.height)
    ..lineTo(size.width, size.height)
    ..arcToPoint(
      Offset(0, size.height),
      radius: Radius.circular(size.height),
      clockwise: false,
    );

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}