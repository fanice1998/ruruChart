import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
       
        colorScheme: ColorScheme.fromSeed(seedColor: Color.fromARGB(255, 255, 255, 255)),
        useMaterial3: true,
      ),
      home: const HomePage(title: 'Note'),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});
  final String title;

  @override
  State<HomePage> createState() => _HomePage();
}

class _HomePage extends State<HomePage> {

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    bool isMobile = screenWidth < 600;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: isMobile
        ?[
          Builder(
            builder: (context) {
              return IconButton(
                icon: Icon(Icons.menu),
                onPressed: () {
                  Scaffold.of(context).openEndDrawer();
                },
                );
            },
          ),
        ]
        : null,
      ),
      endDrawer: isMobile
      ? Drawer(
        // 側邊收縮欄位
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              child: ListTile(
                  leading: const Icon(Icons.menu),
                title: const Text(
                  'Menu',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 24,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                },
              )
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () {
                // 處理點擊事件
                Navigator.pop(context);
              }
            ),
            ListTile(
              leading: const Icon(Icons.home),
              title: const Text('Home'),
              onTap: () {
                // 處理點擊事件
                Navigator.pop(context);
              }
            )
          ],
        ),
      )
      :null,
      body: Expanded(
        flex: 8,
          child: ArticleFeatures(),
        )
      );
  }
}

class ArticleFeatures extends StatelessWidget {
  final List<Map<String, String>> items = [
    {'name': 'Item 1', 'price': '\$10'},
    {'name': 'Item 2', 'price': '\$10'},
    {'name': 'Item 3', 'price': '\$10'},
    {'name': 'Item 4', 'price': '\$10'},
    {'name': 'Item 5', 'price': '\$10'},
  ];

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index){
        return Card(
          child: ListTile(
            leading: const Icon(Icons.shopping_cart),
            title: Text(items[index]['name']!),
            subtitle: Text(items[index]['price']!),
          ),
        );
      },
      );
  }
}