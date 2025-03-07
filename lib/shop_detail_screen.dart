import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:html/parser.dart' show parse;
import "header_ads.dart";
import 'footer_ads.dart';

class ShopDetailScreen extends StatefulWidget {
  final int shopId;

  ShopDetailScreen({required this.shopId});

  @override
  _ShopDetailScreenState createState() => _ShopDetailScreenState();
}

class _ShopDetailScreenState extends State<ShopDetailScreen> {
  Map<String, dynamic>? shop;
  List<dynamic> socials = [];
  List<dynamic> shopGallery = [];
  List<dynamic> products = [];
  List<dynamic> ads = [];
  bool isLoading = true;
  late PageController _pageController;
  int _currentPage = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    fetchShopDetails();
    fetchAds();
    _pageController = PageController(initialPage: 0);
    fetchAds();
  }

  Future<void> fetchShopDetails() async {
    final response = await http.get(
        Uri.parse('https://cryptodroplists.com/api/shop/${widget.shopId}'));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        shop = data['shop'] ?? {};
        socials = data['socials'] ?? [];
        shopGallery = data['shopGallerys'] ?? [];
        products = (data['products']?['data'] as List?) ?? [];
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });
    }
  }
  Future<void> fetchAds() async {
    final response = await http.get(
        Uri.parse('https://cryptodroplists.com/api/ads'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        ads = data['data']
            .where((ad) => ad['type'] == 'content_center')
            .toList();
        isLoading = false;
      });

      if (ads.length > 1) {
        startAutoSlide();
      }
    }
  }

  void startAutoSlide() {
    _timer?.cancel(); // Cancel any existing timer
    _timer = Timer.periodic(Duration(seconds: 5), (timer) {
      if (_currentPage < ads.length - 1) {
        _currentPage++;
      } else {
        _currentPage = 0;
      }
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          _currentPage,
          duration: Duration(milliseconds: 500),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  String parseHtmlDescription(String? htmlString) {
    if (htmlString == null) return "";
    var document = parse(htmlString);
    return document.body?.text ?? "";
  }

  void _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);

    if (url.startsWith('mailto:')) {
      // Force it to open in an external app
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else if (url.startsWith('tel:')) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      await launchUrl(uri, mode: LaunchMode.platformDefault);
    }
  }
  void _openGoogleMaps(double latitude, double longitude) async {
    final url =
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open Google Maps')));
    }
  }
  void _showImagePopup(String? imageUrl) {

    if (imageUrl == null || imageUrl.isEmpty) return;
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(imageUrl, fit: BoxFit.cover),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double? latitude = double.tryParse(shop?['latitude']?.toString() ?? '');
    double? longitude = double.tryParse(shop?['longitude']?.toString() ?? '');
    return Scaffold(
      appBar: AppBar(
        title: Text("Shop Details"),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: HeaderADS(),
              ),
              // Cover Photo & Logo
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Image.network(
                    'https://cryptodroplists.com/storage/' +
                        (shop?['cover_photo'] ?? ""),
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        Container(
                          height: 200,
                          width: double.infinity,
                          color: Colors.grey[300],
                          child: Icon(Icons.image, size: 30),
                        ),
                  ),
                  Positioned(
                    bottom: -30,
                    left: 20,
                    child: CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.white,
                      backgroundImage: shop?['profile_photo'] != null
                          ? NetworkImage(
                          'https://cryptodroplists.com/storage/' +
                              shop!['profile_photo'])
                          : null,
                      child: shop?['profile_photo'] == null
                          ? Icon(Icons.store, size: 40, color: Colors.grey)
                          : null,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 40),

              // Shop Name & Description
              Text(
                shop?['name'] ?? "No Name",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(parseHtmlDescription(shop?['description'])),
              SizedBox(height: 20),

              // Inside your Widget
              SizedBox(height: 40),
              Text("Social Links:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              socials.isEmpty
                  ? Text("No social accounts available", style: TextStyle(color: Colors.grey))
                  : Wrap(
                spacing: 10,
                children: socials.map((social) {
                  String link = social['link'] ?? "";
                  String account = social['account'] ?? "Unknown";
                  IconData icon = Icons.link;
                  String? url;

                  switch (account.toLowerCase()) {
                    case 'email':
                      icon = Icons.email;
                      url = 'mailto:$link'; // Opens email app
                      break;
                    case 'phone':
                      icon = Icons.phone;
                      url = 'tel:$link'; // Opens dialer
                      break;
                    case 'facebook':
                      icon = Icons.facebook;
                      break;
                    case 'messenger':
                      icon = Icons.message;
                      break;
                    case 'instagram':
                      icon = Icons.camera_alt;
                      break;
                    case 'twitter (x)':
                      icon = Icons.share;
                      break;
                    case 'tiktok':
                      icon = Icons.music_note;
                      break;
                    case 'youtube':
                      icon = Icons.play_circle_fill;
                      break;
                    case 'linkedin':
                      icon = Icons.business;
                      break;
                    case 'viber':
                      icon = Icons.chat;
                      break;
                    case 'wechat':
                      icon = Icons.wechat;
                      break;
                    case 'telegram':
                      icon = Icons.send;
                      break;
                  }

                  return GestureDetector(
                    onTap: () => _launchUrl(url ?? link), // Ensures all links open correctly
                    child: Chip(
                      label: Text(account),
                      avatar: Icon(icon, color: Colors.blueAccent),
                      backgroundColor: Colors.blueAccent.withOpacity(0.2),
                    ),
                  );
                }).toList(),
              ),
              SizedBox(height: 20),


              // Google Maps Button
              if (latitude != null && longitude != null)
                ElevatedButton.icon(
                  onPressed: () => _openGoogleMaps(latitude, longitude),
                  icon: Icon(Icons.map),
                  label: Text("View on Google Maps"),
                ),
              SizedBox(height: 20),
              // Gallery
              Text("Gallery:",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 20),
              shopGallery.isEmpty
                  ? Text("No gallery images available", style: TextStyle(color: Colors.grey))
                  : Container(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: shopGallery.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () => _showImagePopup(
                          'https://cryptodroplists.com/storage/' + (shopGallery[index]['photo'] ?? "")),
                      child: Padding(
                        padding: const EdgeInsets.only(right: 10.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            'https://cryptodroplists.com/storage/' +
                                (shopGallery[index]['photo'] ?? ""),
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                                  width: 100,
                                  height: 100,
                                  color: Colors.grey[300],
                                  child: Icon(Icons.image, size: 50),
                                ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              SizedBox(height: 20),

              // Ads Section with Auto-Sliding
              if (ads.isNotEmpty)
                SizedBox(
                  height: 70,
                  child: PageView.builder(
                    controller: _pageController,
                    itemCount: ads.length,
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      final ad = ads[index];
                      return GestureDetector(
                        onTap: () => _launchUrl(ad['link']),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            'https://cryptodroplists.com/storage/' +
                                ad['image'],
                            width: double.infinity,
                            height: 70,
                            fit: BoxFit.cover,
                            loadingBuilder:
                                (context, child, loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                  child: CircularProgressIndicator());
                            },
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                                  height: 70,
                                  color: Colors.grey[300],
                                  child: Icon(Icons.broken_image, size: 50),
                                ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              SizedBox(height: 20),
              SizedBox(height: 20),
              // Products
              Text("Products:",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              products.isEmpty
                  ? Text("No products available", style: TextStyle(color: Colors.grey))
                  : GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.8,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  return Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 4,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            'https://cryptodroplists.com/storage/' +
                                (products[index]['photo'] ?? ""),
                            width: double.infinity,
                            height: 120,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(
                                  height: 120,
                                  color: Colors.grey[300],
                                  child: Icon(Icons.image, size: 50),
                                ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                products[index]['name'] ?? "Unknown Product",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              Text("Price: ${products[index]['price'] != null ? "${products[index]['price']} Ks" : "N/A"}")

                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: FooterAds(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
