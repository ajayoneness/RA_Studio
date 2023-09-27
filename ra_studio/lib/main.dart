import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/services.dart';

void main() {
  runApp(MyApp());
}

class Category {
  final int id;
  final String name;
  final String lastname;
  final String description;
  final String longDescription;
  final String image;
  final String poster;
  final String slug;

  Category({
    required this.id,
    required this.name,
    required this.lastname,
    required this.description,
    required this.longDescription,
    required this.image,
    required this.poster,
    required this.slug,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'],
      name: json['name'],
      lastname: json['lastname'],
      description: json['decription'],
      longDescription: json['longdecription'],
      image: json['image'],
      poster: json['poster'],
      slug: json['slug'],
    );
  }
}

class Quote {
  final int id;
  final String color;
  final String quote;
  final int category;

  Quote({
    required this.id,
    required this.color,
    required this.quote,
    required this.category,
  });

  factory Quote.fromJson(Map<String, dynamic> json) {
    return Quote(
      id: json['id'],
      color: json['color'],
      quote: json['quote'],
      category: json['category'],
    );
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RA Studio',
      theme: ThemeData(
        primarySwatch: Colors.pink,
      ),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Category> categories = [];
  bool isLoading = true; // Track loading state

  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    final response = await http
        .get(Uri.parse('https://rastudio.pythonanywhere.com/api/categories/'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        categories = data.map((json) => Category.fromJson(json)).toList();
        isLoading = false; // Set loading state to false when data is loaded
      });
    } else {
      throw Exception('Failed to load categories');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('RA Studio'),
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(), // Show loader while loading
            )
          : ListView.builder(
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            CategoryDetailPage(category: category),
                      ),
                    );
                  },
                  child: CategoryCard(category: category),
                );
              },
            ),
    );
  }
}

class CategoryCard extends StatelessWidget {
  final Category category;

  CategoryCard({required this.category});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.network(category.image),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.name + ' ' + category.lastname,
                  style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8.0),
                Text(category.description),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class CategoryDetailPage extends StatefulWidget {
  final Category category;

  CategoryDetailPage({required this.category});

  @override
  _CategoryDetailPageState createState() => _CategoryDetailPageState();
}

class _CategoryDetailPageState extends State<CategoryDetailPage> {
  List<Quote> quotes = [];
  bool isLoading = true; // Initialize loading state to true

  @override
  void initState() {
    super.initState();
    fetchQuotes();
  }

  Future<void> fetchQuotes() async {
    final response = await http.get(Uri.parse(
        'https://rastudio.pythonanywhere.com/api/quotes/by_category/${widget.category.id}'));
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        quotes = data.map((json) => Quote.fromJson(json)).toList();
        isLoading = false; // Set loading state to false when quotes are loaded
      });
    } else {
      throw Exception('Failed to load quotes');
    }
  }

  // Function to copy a quote to the clipboard
  void copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Copied to clipboard: $text'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category.name + ' ' + widget.category.lastname),
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(), // Show loader while loading
            )
          : SingleChildScrollView(
              // Use SingleChildScrollView to make quotes scrollable
              child: Column(
                children: [
                  Image.network(widget.category.poster),
                  Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.category.name + ' ' + widget.category.lastname,
                          style: TextStyle(
                              fontSize: 24.0, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 8.0),
                        Text(widget.category.longDescription),
                      ],
                    ),
                  ),
                  SizedBox(height: 16.0),
                  Text(
                    'Quotes',
                    style:
                        TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10.0),
                  ListView.builder(
                    shrinkWrap: true,
                    physics:
                        NeverScrollableScrollPhysics(), // Disable scrolling for the inner ListView
                    itemCount: quotes.length,
                    itemBuilder: (context, index) {
                      final quote = quotes[index];
                      return GestureDetector(
                        onTap: () {
                          // Call copyToClipboard when the quote is tapped
                          copyToClipboard(quote.quote);
                        },
                        child: Container(
                          margin: EdgeInsets.fromLTRB(30.0, 8.0, 30.0, 8.0),
                          padding: EdgeInsets.all(10.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            boxShadow: [
                              BoxShadow(
                                color: Color.fromARGB(120, 255, 24, 24)
                                    .withOpacity(0.2),
                                spreadRadius: 2,
                                blurRadius: 1,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Column(
                            children: <Widget>[
                              Container(
                                alignment: Alignment.center,
                                child: Text(
                                  '❤️',
                                  style: TextStyle(
                                    fontSize: 60.0,
                                  ),
                                ),
                              ),
                              SizedBox(height: 8.0),
                              Center(
                                child: Text(
                                  quote.quote,
                                  style: TextStyle(fontSize: 13.0),
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }
}
