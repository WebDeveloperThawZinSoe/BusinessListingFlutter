import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'category_screen.dart';
import 'region_screen.dart';
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
        fontFamily: 'Roboto', // Premium sleek font
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
  ];

  @override
  void initState() {
    super.initState();
    _checkVersion();
  }

  Future<void> _checkVersion() async {
    const String currentVersion = "1.0.0"; // Change this when updating the app
    const String apiUrl = "https://cryptodroplists.com/api/version";

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        body: {"version": currentVersion},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data["status"] == false) {
          _showUpdateDialog(data["message"], data["play_store"], data["app_store"], data["direct"]);
        }
      }
    } catch (e) {
      print("Version check failed: $e");
    }
  }

  void _showUpdateDialog(String message, String playStore, String appStore, String direct) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // App Icon
                Container(
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: Colors.blueAccent.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.system_update,
                    color: Colors.blueAccent,
                    size: 60,
                  ),
                ),
                SizedBox(height: 20),

                // Title
                Text(
                  "Update Available",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10),

                // Message
                Text(
                  message,
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),

                // Buttons Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildUpdateButton("Play Store", playStore, Colors.green),
                    _buildUpdateButton("App Store", appStore, Colors.orange),
                    _buildUpdateButton("Direct", direct, Colors.blue),
                  ],
                ),
                SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

// Custom Button Widget
  Widget _buildUpdateButton(String label, String url, Color color) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      onPressed: () => _launchURL(url),
      child: Text(
        label,
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      ),
    );
  }

  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      print("Could not launch $url");
    }
  }

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
        centerTitle: true,
      ),
      body: _widgetOptions[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.category, size: 30),
            label: 'Category',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map, size: 30),
            label: 'Region',
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
}
