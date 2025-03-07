import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shimmer/shimmer.dart';
import "header_ads.dart";
import 'footer_ads.dart';
import 'shop_detail_screen.dart';

class Nearby extends StatefulWidget {
  @override
  _NearByScreenState createState() => _NearByScreenState();
}

class _NearByScreenState extends State<Nearby> {
  double latitude = 0.0;
  double longitude = 0.0;
  bool isLoading = true;
  List<dynamic> shopList = [];

  @override
  void initState() {
    super.initState();
    _checkPermissionsAndGetLocation();
  }

  Future<void> _checkPermissionsAndGetLocation() async {
    PermissionStatus status = await Permission.location.request();
    if (status.isGranted) {
      _getCurrentLocation();
    } else {
      _fetchShops();
    }
  }

  Future<void> _getCurrentLocation() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      _fetchShops();
      return;
    }
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    setState(() {
      latitude = position.latitude;
      longitude = position.longitude;
    });
    _fetchShops();
  }

  Future<void> _fetchShops() async {
    String apiUrl = "https://cryptodroplists.com/api/nearby/$latitude/$longitude";
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          shopList = data['data'];
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (error) {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(child: HeaderADS()),
              SliverPadding(
                padding: EdgeInsets.only(top: 10),
                sliver: isLoading
                    ? SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.8,
                  ),
                  delegate: SliverChildBuilderDelegate(
                        (context, index) => ShimmerCard(),
                    childCount: 6,
                  ),
                )
                    : shopList.isEmpty
                    ? SliverToBoxAdapter(
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Text("No shops found", style: TextStyle(fontSize: 16, color: Colors.grey[700])),
                    ),
                  ),
                )
                    : SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 10,
                    mainAxisSpacing: 10,
                    childAspectRatio: 0.8,
                  ),
                  delegate: SliverChildBuilderDelegate(
                        (context, index) => ShopCard(shop: shopList[index]),
                    childCount: shopList.length,
                  ),
                ),
              ),
              SliverToBoxAdapter(child:  SizedBox(height: 20)),
              SliverToBoxAdapter(child: FooterAds()),
            ],
          ),
        ),
      ),
    );
  }
}

class ShopCard extends StatelessWidget {
  final dynamic shop;
  ShopCard({required this.shop});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: (){
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                ShopDetailScreen(shopId: shop["id"]),
          ),
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 3,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                child: CachedNetworkImage(
                  imageUrl: "https://cryptodroplists.com/storage/${shop['profile_photo']}",
                  placeholder: (context, url) => ShimmerCard(),
                  errorWidget: (context, url, error) => Icon(Icons.broken_image, size: 50),
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(10),
              child: Column(
      
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    shop['name'],
                    style: TextStyle(fontSize: 15, color: Colors.black87),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 5),
                  Text(
                    shop['address'] ?? "No address available",
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
      
                  ),
                  SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    children: [
                      if (shop['city_name'] != null && shop['city_name'].isNotEmpty)
                        _buildBadge(shop['city_name'], Colors.blueAccent),
                      if (shop['category_name'] != null && shop['category_name'].isNotEmpty)
                        _buildBadge(shop['category_name'], Colors.green),
                    ],
                  ),
      
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
Widget _buildBadge(String text, Color color) {
  return Container(
    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    decoration: BoxDecoration(
      color: color.withOpacity(0.2),
      borderRadius: BorderRadius.circular(15),
    ),
    child: Text(
      text,
      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: color),
    ),
  );
}
class ShimmerCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

}