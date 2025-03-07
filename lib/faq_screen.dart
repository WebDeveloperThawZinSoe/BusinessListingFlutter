import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import 'category_detail_screen.dart';
import "header_ads.dart";
import 'footer_ads.dart';

class FaqScreen extends StatefulWidget {
  @override
  _FaqScreenState createState() => _FaqScreenState();
}

class _FaqScreenState extends State<FaqScreen> {
  Future<List> fetchCategories() async {
    try {
      final response = await http.get(Uri.parse('https://cryptodroplists.com/api/category'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'];
      }
    } catch (e) {
      print("Error fetching categories: $e");
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Column(
        children: [
          // Ads Banner
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: HeaderADS(),
          ),

          // Category List
          Expanded(
              child: Text('Hello'),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: FooterAds(),
          ),
        ],
      ),
    );
  }
}
