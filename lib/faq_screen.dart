import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FaqScreen extends StatefulWidget {
  @override
  _FAQScreenState createState() => _FAQScreenState();
}

class _FAQScreenState extends State<FaqScreen> {
  Future<List> fetchFAQs() async {
    try {
      final response =
      await http.get(Uri.parse('https://cryptodroplists.com/api/faq'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'];
      }
    } catch (e) {
      print("Error fetching FAQs: $e");
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: const Text(
          'FAQs',
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
      ),
      body: FutureBuilder<List>(
        future: fetchFAQs(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error loading FAQs"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("No FAQs available"));
          }

          final faqs = snapshot.data!;

          return ListView.builder(
            padding: EdgeInsets.all(10),
            itemCount: faqs.length,
            itemBuilder: (context, index) {
              final faq = faqs[index];
              return Card(
                margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 2,
                child: ExpansionTile(
                  title: Text(
                    faq['question'],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  children: [
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: Text(
                        _parseHtmlString(faq['answer']),
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  String _parseHtmlString(String htmlString) {
    return htmlString
        .replaceAll(RegExp(r'<[^>]*>|&[^;]+;'), ' ')
        .trim(); // Remove HTML tags
  }
}
