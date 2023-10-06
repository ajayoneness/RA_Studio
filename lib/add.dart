import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class AddQuoteScreen extends StatefulWidget {
  @override
  _AddQuoteScreenState createState() => _AddQuoteScreenState();
}

class _AddQuoteScreenState extends State<AddQuoteScreen> {
  final TextEditingController quoteController = TextEditingController();
  String selectedCategory = "1"; // Default category
  bool formSubmitted = false;
  List<Map<String, dynamic>> categoryData = [];
  Color selectedColor = Colors.red; // Default color
  bool colorPickerVisible = false;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    final response = await http.get(
      Uri.parse('https://rastudio.pythonanywhere.com/api/categories/'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        categoryData = data.cast<Map<String, dynamic>>();
        if (categoryData.isNotEmpty) {
          selectedCategory = categoryData.first['id'].toString();
        }
      });
    } else {
      // Handle API error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to fetch categories'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void openColorPickerDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Pick a color'),
          content: SingleChildScrollView(
            child: ColorPicker(
              pickerColor: selectedColor,
              onColorChanged: (Color color) {
                setState(() {
                  selectedColor = color;
                });
              },
              colorPickerWidth: 300.0,
              pickerAreaHeightPercent: 0.7,
              enableAlpha: true,
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Done'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _submitQuote() async {
    final String newQuote = quoteController.text.trim();
    if (newQuote.isNotEmpty) {
      final Map<String, dynamic> requestData = {
        "color": selectedColor.value
            .toRadixString(16)
            .substring(2), // Use the selected color
        "quote": newQuote,
        "category": selectedCategory,
      };

      final response = await http.post(
        Uri.parse('https://rastudio.pythonanywhere.com/api/quotes/'),
        body: requestData,
      );

      if (response.statusCode == 201) {
        // Quote added successfully (201 Created)
        setState(() {
          formSubmitted = true;
          colorPickerVisible = false; // Hide the color picker button
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Quote added successfully!'),
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        // Handle API error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to add quote'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink[100],
      body: ListView(
        padding: EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 16.0), // Adjust padding
        children: [
          Image.asset(
            'assets/ra.png', // Path to your image asset
            height: 200, // Adjust the height as needed
          ),
          DropdownButtonFormField<String>(
            value: selectedCategory,
            onChanged: (String? newValue) {
              setState(() {
                selectedCategory = newValue!;
              });
            },
            items: categoryData.map<DropdownMenuItem<String>>((category) {
              return DropdownMenuItem<String>(
                value: category['id'].toString(),
                child: Text('${category['name']} ${category['lastname']}'),
              );
            }).toList(),
            decoration: InputDecoration(
              labelText: 'Category',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 16),
          GestureDetector(
            onTap: () {
              setState(() {
                colorPickerVisible = !colorPickerVisible;
              });
              if (colorPickerVisible) {
                openColorPickerDialog();
              }
            },
            child: Container(
              color: selectedColor,
              height: 40,
              child: Center(
                child: Text(
                  'Tap to Pick a Color',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 16),
          if (colorPickerVisible) SizedBox(height: 16),
          TextFormField(
            controller: quoteController,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Quote',
              border: OutlineInputBorder(),
            ),
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: formSubmitted
                ? null
                : _submitQuote, // Disable button after submission
            child: Text('Add Quote'),
          ),
          if (formSubmitted)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Thank you for submitting!',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
        ],
      ),
    );
  }
}
