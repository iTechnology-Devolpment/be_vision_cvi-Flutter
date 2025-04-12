import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:vibration/vibration.dart';

class FruitRecognitionScreen extends StatefulWidget {
  @override
  _FruitRecognitionScreenState createState() => _FruitRecognitionScreenState();
}

class _FruitRecognitionScreenState extends State<FruitRecognitionScreen>
    with TickerProviderStateMixin {
  FlutterTts flutterTts = FlutterTts();
  String selectedLanguage = 'ar';
  late AnimationController _controller;
  late Animation<double> _animation;
  int currentItemIndex = 0;

  final List<Map<String, dynamic>> items = [
    {
      'image': 'assets/fruits/apple.jpg',
      'nameEn': 'Apple',
      'nameAr': 'تفاحة'
    },
    {
      'image': 'assets/fruits/banana.jpg',
      'nameEn': 'Banana',
      'nameAr': 'موزة'
    },
    {
      'image': 'assets/fruits/orange.jpg',
      'nameEn': 'Orange',
      'nameAr': 'برتقالة'
    },
  ];

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
      'appTitle': 'الفاكهة',
      'currentItem': ''
    },
    'en': {
      'next': 'Next',
      'languageChanged': 'Language changed',
      'appTitle': 'Fruits',
      'currentItem': 'This is a'
    }
  };

  String translate(String key) => translations[selectedLanguage]![key] ?? key;

  void speak(String text) async => await flutterTts.speak(text);

  void vibrate() async {
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: 500);
    }
  }

  void nextItem() {
    _controller.forward().then((_) => _controller.reverse());
    setState(() => currentItemIndex = (currentItemIndex + 1) % items.length);
    speak('${translate("currentItem")} ${items[currentItemIndex][selectedLanguage == 'ar' ? 'nameAr' : 'nameEn']}');
    vibrate();
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
          tooltip: selectedLanguage == 'ar' ? 'Switch to English' : 'تبديل إلى العربية',
        ),
      ],
    );
  }

  Widget getItemWidget() {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) => Transform.scale(
        scale: _animation.value,
        child: child,
      ),
      child: GestureDetector(
        onTap: () {
          speak('${translate("currentItem")} ${items[currentItemIndex][selectedLanguage == 'ar' ? 'nameAr' : 'nameEn']}');
          vibrate();
        },
        child: Container(
          width: 250,
          height: 250,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white, width: 8),
            boxShadow: [
              BoxShadow(
                color: Colors.white.withOpacity(0.3),
                spreadRadius: 5,
                blurRadius: 15,
                offset: Offset(0, 3),
              )
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Image.asset(
              items[currentItemIndex]['image'],
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
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
            getItemWidget(),
            SizedBox(height: 30),
            Text(
              items[currentItemIndex][selectedLanguage == 'ar' ? 'nameAr' : 'nameEn'],
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.w900,
                shadows: [Shadow(color: Colors.black, blurRadius: 10)],
              ),
            ),
            SizedBox(height: 80),
            ElevatedButton(
              onPressed: nextItem,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[800],
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40),
                  side: BorderSide(color: Colors.white, width: 3),
                ),
                shadowColor: Colors.blue[200],
                elevation: 10,
              ),
              child: Text(
                translate("next"),
                style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    letterSpacing: 1.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}