import 'package:be_vision_cvi/screens/items_recognition/color_recognition_screen.dart';
import 'package:be_vision_cvi/screens/items_recognition/fruit_recognition_screen.dart';
import 'package:be_vision_cvi/screens/items_recognition/kitchen_tools_recognition_screen.dart';
import 'package:be_vision_cvi/screens/items_recognition/pet_recognition_screen.dart';
import 'package:be_vision_cvi/screens/items_recognition/predator_recognition_screen.dart';
import 'package:be_vision_cvi/screens/items_recognition/shape_recognition_screen.dart';
import 'package:be_vision_cvi/screens/items_recognition/transportation_recognition_screen.dart';
import 'package:be_vision_cvi/screens/items_recognition/vegetable_recognition_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:vibration/vibration.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class RecognitionScreen extends StatefulWidget {
  @override
  _RecognitionScreenState createState() => _RecognitionScreenState();
}

class _RecognitionScreenState extends State<RecognitionScreen>
    with TickerProviderStateMixin {
  FlutterTts flutterTts = FlutterTts();
  String selectedLanguage = 'ar';
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    flutterTts.setLanguage(selectedLanguage);

    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );

    _animation = Tween(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Map<String, Map<String, String>> translations = {
    'ar': {
      'next': 'التالي',
      'languageChanged': 'تم تغيير اللغة',
      'appTitle': 'أنشطة التعلم'
    },
    'en': {
      'next': 'Next',
      'languageChanged': 'Language changed',
      'appTitle': 'Learning Activity'
    }
  };

  String translate(String key) => translations[selectedLanguage]![key] ?? key;

  void speak(String text) async => await flutterTts.speak(text);

  void vibrate() async {
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: 500);
    }
  }

  void changeLanguage() {
    setState(() => selectedLanguage = selectedLanguage == 'ar' ? 'en' : 'ar');
    flutterTts.setLanguage(selectedLanguage);
    speak(translate("languageChanged"));
  }

  AppBar buildAppBar() {
    return AppBar(
      title: Text(translate("appTitle"),
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.5,
            color: Colors.white,
            shadows: [Shadow(color: Colors.black, blurRadius: 5)],
          )),
      backgroundColor: Colors.blue[900],
      toolbarHeight: 80,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, size: 35, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.language, size: 35, color: Colors.white),
          onPressed: changeLanguage,
          tooltip: selectedLanguage == 'ar'
              ? 'Switch to English'
              : 'تبديل إلى العربية',
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(),
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: GridView.count(
                  crossAxisCount: 2,
                  childAspectRatio: 0.9,
                  crossAxisSpacing: 15,
                  mainAxisSpacing: 15,
                  children: [
                    _buildActivityButton(
                      'الألوان',
                      Icons.color_lens,
                      Colors.blue[900]!,
                      ColorRecognitionScreen(),
                    ),
                    _buildActivityButton(
                      'الأشكال',
                      Icons.shape_line,
                      Colors.blue[900]!,
                      ShapeRecognitionScreen(),
                    ),
                    _buildActivityButton(
                      'الحيوانات الأليفة',
                      Icons.pets,
                      Colors.blue[900]!,
                      PetRecognitionScreen(),
                    ),
                    _buildActivityButton(
                      'الحيوانات المفترسة',
                      FontAwesomeIcons.wolfPackBattalion,
                      Colors.blue[900]!,
                      PredatorRecognitionScreen(),
                    ),
                    _buildActivityButton(
                      'الفاكهة',
                      Icons.apple,
                      Colors.blue[900]!,
                      FruitRecognitionScreen(),
                    ),
                    _buildActivityButton(
                      'الخضروات',
                      FontAwesomeIcons.carrot,
                      Colors.blue[900]!,
                      VegetableRecognitionScreen(),
                    ),
                    _buildActivityButton(
                      'أدوات المطبخ',
                      Icons.kitchen,
                      Colors.blue[900]!,
                      KitchenToolsRecognitionScreen(),
                    ),
                    _buildActivityButton(
                      'وسائل النقل',
                      Icons.car_crash,
                      Colors.blue[900]!,
                      TransportationRecognitionScreen(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityButton(
      String title, IconData icon, Color color, Widget screen) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          speak(title);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => screen),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: color.withOpacity(0.9),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: Colors.white),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Cairo',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
