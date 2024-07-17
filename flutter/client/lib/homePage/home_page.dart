import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context){
    return DefaultTabController(
      length: 3, 
      child: Scaffold(
        appBar: AppBar(
          title: const Text("test1 appbar"),
          bottom: const TabBar(tabs: [
              Tab(icon: Icon(Icons.directions_car), text: 'Car'),
              Tab(icon: Icon(Icons.directions_transit), text: 'Transit'),
              Tab(icon: Icon(Icons.directions_bike), text: 'Bike'),
          ],),),
          body: const TabBarView(
            children: [
            Center(child: Text('Car Page')),
            Center(child: Text('Transit Page')),
            Center(child: Text('Bike Page')),
            ],
          ),
        ));
  }
}
