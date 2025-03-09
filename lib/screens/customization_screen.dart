import 'package:flutter/material.dart';

class CustomizationScreen extends StatefulWidget {
  @override
  _CustomizationScreenState createState() => _CustomizationScreenState();
}

class _CustomizationScreenState extends State<CustomizationScreen> {
  bool highContrast = true;
  double volume = 1.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SwitchListTile(
              title: Text(
                'وضع التباين العالي',
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              value: highContrast,
              onChanged: (value) {
                setState(() {
                  highContrast = value;
                });
              },
            ),
            SizedBox(height: 20),
            Text(
              'مستوى الصوت',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            Slider(
              value: volume,
              onChanged: (value) {
                setState(() {
                  volume = value;
                });
              },
              min: 0.0,
              max: 1.0,
            ),
          ],
        ),
      ),
    );
  }
}