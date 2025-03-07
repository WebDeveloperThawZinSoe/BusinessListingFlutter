import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'region_detail_screen.dart';
import "header_ads.dart";
import 'footer_ads.dart';

class RegionScreen extends StatefulWidget {
  @override
  _RegionScreenState createState() => _RegionScreenState();
}

class _RegionScreenState extends State<RegionScreen> {
  late Future<List<dynamic>> _futureRegions;

  @override
  void initState() {
    super.initState();
    _futureRegions = fetchRegions();
  }

  Future<List<dynamic>> fetchRegions() async {
    try {
      final response = await http.get(Uri.parse('https://cryptodroplists.com/api/region'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'] ?? [];
      } else {
        throw Exception("Failed to load regions");
      }
    } catch (e) {
      print("Error fetching regions: $e");
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: HeaderADS(),
          ),
          Expanded(

            child: FutureBuilder<List<dynamic>>(
              future: _futureRegions,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _buildShimmerEffect();
                } else if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text("No regions found", style: TextStyle(fontSize: 16)));
                }

                List regions = snapshot.data!;
                return ListView.builder(
                  itemCount: regions.length,
                  itemBuilder: (context, index) {
                    String imageUrl = 'https://cryptodroplists.com/storage/${regions[index]['icon']}';
                    String name = regions[index]['name'] ?? "Unknown Region";

                    return InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RegionDetailScreen(
                              regionId: regions[index]['id'],
                            ),
                          ),
                        );
                      },
                      child: Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 4,
                        shadowColor: Colors.black.withOpacity(0.1),
                        child: ListTile(
                          contentPadding: EdgeInsets.all(18),
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: CachedNetworkImage(
                              imageUrl: imageUrl,
                              width: 70,
                              height: 70,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => _buildImagePlaceholder(),
                              errorWidget: (context, url, error) => Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                            ),
                          ),
                          title: Text(
                            name,
                            style: TextStyle(fontSize: 16, color: Colors.black87),
                          ),
                          trailing: Icon(Icons.arrow_forward_ios, color: Colors.blueAccent, size: 20),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: FooterAds(),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerEffect() {
    return ListView.builder(
      itemCount: 6, // Show 6 loading placeholders
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 4,
            shadowColor: Colors.black.withOpacity(0.1),
            child: ListTile(
              contentPadding: EdgeInsets.all(18),
              leading: Container(width: 70, height: 70, color: Colors.white),
              title: Container(height: 20, color: Colors.white),
              trailing: Icon(Icons.arrow_forward_ios, color: Colors.white),
            ),
          ),
        );
      },
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(12),
      ),
    );
  }
}
