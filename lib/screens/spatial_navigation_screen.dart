import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class SpatialNavigationScreen extends StatefulWidget {
  @override
  _SpatialNavigationScreenState createState() =>
      _SpatialNavigationScreenState();
}

class _SpatialNavigationScreenState extends State<SpatialNavigationScreen> {
  FlutterTts flutterTts = FlutterTts();
  String _selectedLanguage = "ar-SA"; // Default Arabic
  bool isArabic = true;

  // Location translations
  Map<String, String> locationTranslations = {
    'غرفة النوم': 'Bedroom',
    'المطبخ': 'Kitchen',
    'الحمام': 'Bathroom',
    'الصالة': 'Living Room',
  };

  @override
  void initState() {
    super.initState();
    _initializeTTS();
  }

  Future<void> _initializeTTS() async {
    await flutterTts.setLanguage(_selectedLanguage);
    await flutterTts.setSpeechRate(0.5);
    await flutterTts.setVolume(1.0);
    await flutterTts.setPitch(1.0);
  }

  Future<void> speak(String text) async {
    await flutterTts.stop();
    await flutterTts.speak(text);
  }

  void navigateTo(String location) {
    String translatedLocation = locationTranslations[location] ?? location;
    String text =
    isArabic ? 'اتجه نحو $location' : 'Go towards $translatedLocation';

    speak(text);
  }

  void toggleLanguage(String language) async {
    setState(() {
      isArabic = language == "ar-SA";
      _selectedLanguage = language;
    });
    await flutterTts.setLanguage(_selectedLanguage);
  }

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isArabic ? 'التوجيه المكاني' : 'Spatial Navigation',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold,color: Colors.white),
        ),
        backgroundColor: Colors.blue[900],
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context), // Back to Home
        ),
        actions: [
          // قائمة منسدلة لتغيير اللغة
          PopupMenuButton<String>(
            onSelected: (String value) {
              toggleLanguage(value);
            },
            icon: Icon(Icons.language, color: Colors.white),
            itemBuilder: (BuildContext context) => [
              PopupMenuItem(
                value: "ar-SA",
                child: Text("🇸🇦 العربية"),
              ),
              PopupMenuItem(
                value: "en-US",
                child: Text("🇺🇸 English"),
              ),
            ],
          ),
        ],
      ),
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              isArabic ? 'اختر موقعًا للانتقال إليه' : 'Choose a location',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 30),

            _buildNavigationButton('غرفة النوم'),
            SizedBox(height: 15),
            _buildNavigationButton('المطبخ'),
            SizedBox(height: 15),
            _buildNavigationButton('الحمام'),
            SizedBox(height: 15),
            _buildNavigationButton('الصالة'),
            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationButton(String location) {
    String translatedLocation = locationTranslations[location] ?? location;
    String text = isArabic ? location : translatedLocation;
    return Container(
      width: 250,
      child: ElevatedButton(
        onPressed: () => navigateTo(location),
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(vertical: 16),
          backgroundColor: Colors.blue[900],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          elevation: 5,
        ),
        child: Text(
          text,
          style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
    );
  }
}
