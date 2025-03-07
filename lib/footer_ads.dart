import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

class FooterAds extends StatefulWidget {
  final String adType; // Allows customization for different types of ads

  FooterAds({this.adType = 'footer'});

  @override
  _AdsSliderState createState() => _AdsSliderState();
}

class _AdsSliderState extends State<FooterAds> {
  List<dynamic> ads = [];
  bool isLoading = true;
  late PageController _pageController;
  int _currentPage = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    fetchAds();
  }

  Future<void> fetchAds() async {
    final response =
    await http.get(Uri.parse('https://cryptodroplists.com/api/ads'));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        ads = data['data']
            .where((ad) => ad['type'] == widget.adType)
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

  void _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      print("Could not launch $url");
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Center(child: CircularProgressIndicator())
        : ads.isNotEmpty
        ? SizedBox(
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
                'https://cryptodroplists.com/storage/' + ad['image'],
                width: double.infinity,
                height: 70,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(child: CircularProgressIndicator());
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
    )
        : SizedBox(); // If no ads, show nothing
  }
}
