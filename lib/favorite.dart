import 'package:flutter/material.dart';

class FavoritePage extends StatefulWidget {
  @override
  _FavoritePageState createState() => _FavoritePageState();
}

class _FavoritePageState extends State<FavoritePage> {
  TextEditingController nameController = TextEditingController();
  TextEditingController partnerNameController = TextEditingController();
  String lovePercentage = '';

  void calculateLovePercentage() {
    String name = nameController.text.trim();
    String partnerName = partnerNameController.text.trim();

    if (name.isNotEmpty && partnerName.isNotEmpty) {
      int randomLovePercentage =
          50 + (DateTime.now().millisecondsSinceEpoch % 51);

      setState(() {
        lovePercentage = '$randomLovePercentage%';
      });
    } else {
      setState(() {
        lovePercentage = 'Please enter both names';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          Colors.pink[100], // Set the background color to light pink
      body: Padding(
        padding: EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              'assets/ra.png', // Path to your image asset
              height: 200, // Adjust the height as needed
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 10.0),
              child: TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: 'Your Name',
                  // Rest of your input field code...
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 10.0),
              child: TextField(
                controller: partnerNameController,
                decoration: InputDecoration(
                  labelText: "Partner's Name",
                  // Rest of your input field code...
                ),
              ),
            ),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: calculateLovePercentage,
              child: Text('CALCULATE'),
            ),
            SizedBox(height: 30.0),
            Text(
              'Love Percentage: $lovePercentage',
              style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
