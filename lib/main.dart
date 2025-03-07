import 'package:flutter/material.dart';
import 'category_screen.dart';
import 'region_screen.dart';
import 'faq_screen.dart';
import 'nearBy.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(BusinessListingApp());
}

class BusinessListingApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        fontFamily: 'Roboto',
      ),
      home: BusinessHomePage(),
    );
  }
}

class BusinessHomePage extends StatefulWidget {
  @override
  _BusinessHomePageState createState() => _BusinessHomePageState();
}

class _BusinessHomePageState extends State<BusinessHomePage> {
  int _selectedIndex = 0;
  static final List<Widget> _widgetOptions = <Widget>[
    CategoryScreen(),
    RegionScreen(),
    Nearby()
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Yangon LINK',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.normal,
            letterSpacing: 1.2,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
        centerTitle: false,
        actions: [
          Builder(
            builder: (context) {
              return IconButton(
                icon: Icon(Icons.menu, size: 30, color: Colors.white),
                onPressed: () {
                  Scaffold.of(context).openEndDrawer();
                },
              );
            },
          ),
        ],
      ),

      // Right-side Drawer
      endDrawer: Drawer(
        child: Column(
          children: [
            // User Profile Section
            DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blueAccent, Colors.blue.shade900],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: AssetImage('images/icon/logo.jpg'),
                  ),
                  SizedBox(width: 15),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Welcome to',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Yangon Link',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Menu Items
            Expanded(
              child: ListView(
                children: [
                  _buildMenuItem(Icons.home, 'Home', () {
                    setState(() {
                      _selectedIndex = 0;
                    });
                    Navigator.pop(context);
                  }),
                  _buildMenuItem(Icons.map, 'Townships', () {
                    setState(() {
                      _selectedIndex = 1;
                    });
                    Navigator.pop(context);
                  }),
                  _buildMenuItem(Icons.location_on, 'Nearby', () {
                    setState(() {
                      _selectedIndex = 2;
                    });
                    Navigator.pop(context);
                  }),
                  _buildMenuItem(Icons.question_mark_rounded, 'FAQs', () {
                    setState(() {
                      _selectedIndex = 3;
                    });
                    Navigator.pop(context);
                  }),
                  Divider(thickness: 1, color: Colors.grey.shade300),
                  _buildMenuItem(Icons.phone_forwarded, 'Contact Us', () {
                    Navigator.pop(context);
                  }),
                  _buildMenuItem(Icons.store_mall_directory, 'Become A Shop', () {
                    Navigator.pop(context);
                  }),
                ],
              ),
            ),

            // Footer
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                'Version 1.0.0',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ),
          ],
        ),
      ),

      body: _widgetOptions[_selectedIndex],

      // Bottom Navigation
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home, size: 30),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map, size: 30),
            label: 'Township',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.location_on, size: 30),
            label: 'Nearby',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blueAccent,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: _onItemTapped,
      ),
    );
  }

  // Custom Drawer Menu Item
  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: Colors.blueAccent),
      title: Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
      onTap: onTap,
    );
  }
}
