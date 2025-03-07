import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'shop_detail_screen.dart';
import 'package:html/parser.dart' show parse;
import "header_ads.dart";
import 'footer_ads.dart';


class CategoryDetailScreen extends StatefulWidget {
  final int categoryId;

  CategoryDetailScreen({required this.categoryId});

  @override
  _CategoryDetailScreenState createState() => _CategoryDetailScreenState();
}

class _CategoryDetailScreenState extends State<CategoryDetailScreen> {
  late Future<Map<String, dynamic>> _categoryDetails;

  @override
  void initState() {
    super.initState();
    _categoryDetails = fetchCategoryDetails();
  }

  Future<Map<String, dynamic>> fetchCategoryDetails() async {
    try {
      final response = await http.get(
          Uri.parse('https://cryptodroplists.com/api/category/${widget.categoryId}'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      } else {
        throw Exception('Failed to load category details');
      }
    } catch (e) {
      throw Exception('Failed to fetch data: $e');
    }
  }

  String parseHtmlDescription(String htmlString) {
    var document = parse(htmlString);
    return document.body?.text ?? "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Category Details'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: HeaderADS(),
          ),
          Expanded(
            child: FutureBuilder<Map<String, dynamic>>(
              future: _categoryDetails,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return _buildShimmerEffect();
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data == null) {
                  return Center(child: Text('No data found.'));
                }
            
                final category = snapshot.data!['category'];
                final businesses = snapshot.data!['data']['data'];
            
                return Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: CachedNetworkImage(
                          imageUrl: 'https://cryptodroplists.com/storage/' + category['icon'],
                          height: 150,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => _buildImagePlaceholder(),
                          errorWidget: (context, url, error) =>
                              Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                        ),
                      ),
                      SizedBox(height: 20),
                      Text(
                        category['title'] ?? "No Title",
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      Text(parseHtmlDescription(category['description'] ?? "")),
                      SizedBox(height: 20),
                      Text(
                        "Businesses in this Category:",
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 10),
                      Expanded(
                        child: businesses.isEmpty
                            ? Center(child: Text("No businesses found"))
                            : ListView.builder(
                          itemCount: businesses.length,
                          itemBuilder: (context, index) {
                            return Card(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              elevation: 4,
                              child: ListTile(
                                contentPadding: EdgeInsets.all(16),
                                leading: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: CachedNetworkImage(
                                    imageUrl: 'https://cryptodroplists.com/storage/' +
                                        businesses[index]['profile_photo'] ?? "",
                                    width: 60,
                                    height: 60,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => _buildImagePlaceholder(),
                                    errorWidget: (context, url, error) =>
                                        Icon(Icons.image_not_supported, size: 50, color: Colors.grey),
                                  ),
                                ),
                                title: Text(businesses[index]['name'] ?? ""),
                                subtitle: Text(businesses[index]['address'] ?? ""),
                                trailing: Icon(Icons.arrow_forward, color: Colors.blueAccent),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          ShopDetailScreen(shopId: businesses[index]['id']),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
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
      itemCount: 6, // Display 6 loading placeholders
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 4,
            shadowColor: Colors.black.withOpacity(0.1),
            child: ListTile(
              contentPadding: EdgeInsets.all(16),
              leading: Container(width: 60, height: 60, color: Colors.white),
              title: Container(height: 20, color: Colors.white),
              subtitle: Container(height: 15, color: Colors.white),
              trailing: Icon(Icons.arrow_forward_ios, color: Colors.white),
            ),
          ),
        );
      },
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      width: 60,
      height: 60,
      color: Colors.grey[300],
    );
  }
}
