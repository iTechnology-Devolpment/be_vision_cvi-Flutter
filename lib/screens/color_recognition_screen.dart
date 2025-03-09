import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:vibration/vibration.dart';
import 'package:flutter/animation.dart';

class ColorRecognitionScreen extends StatefulWidget {
  @override
  _ColorRecognitionScreenState createState() => _ColorRecognitionScreenState();
}

class _ColorRecognitionScreenState extends State<ColorRecognitionScreen>
    with TickerProviderStateMixin {
  FlutterTts flutterTts = FlutterTts();
  List<Color> colors = [
    Colors.red[900]!,
    Colors.blue[900]!,
    Colors.green[900]!,
    Colors.yellow[900]!,
    Colors.orange[900]!,
    Colors.purple[900]!
  ];
  List<String> colorNamesArabic = [
    'أحمر',
    'أزرق',
    'أخضر',
    'أصفر',
    'برتقالي',
    'أرجواني'
  ];
  List<String> colorNamesEnglish = [
    'Red',
    'Blue',
    'Green',
    'Yellow',
    'Orange',
    'Purple'
  ];
  int currentColorIndex = 0;
  bool isArabic = true;
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    flutterTts.setLanguage("ar");

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

  void speak(String text) async {
    await flutterTts.speak(text);
  }

  void vibrate() async {
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: 500);
    }
  }

  void nextColor() {
    _controller.forward().then((_) => _controller.reverse());
    setState(() {
      currentColorIndex = (currentColorIndex + 1) % colors.length;
    });
    String colorText = isArabic
        ? colorNamesArabic[currentColorIndex]
        : colorNamesEnglish[currentColorIndex];
    speak(isArabic ? 'هذا لون $colorText' : 'This is the color $colorText');
    vibrate();
  }

  void toggleLanguage() {
    setState(() {
      isArabic = !isArabic;
      flutterTts.setLanguage(isArabic ? "ar" : "en");
    });
    speak(isArabic ? "تم التبديل إلى العربية" : "Switched to English");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isArabic ? "تمييز الألوان" : "Color Recognition",
            style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.yellow[900],
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, size: 30),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.language, size: 30),
            onPressed: toggleLanguage,
            tooltip: isArabic ? "تبديل إلى الإنجليزية" : "Switch to Arabic",
          ),
        ],
      ),
      backgroundColor: Colors.black,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              isArabic
                  ? 'اضغط على المربع لسماع اللون'
                  : "Tap the box to hear the color",
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
                shadows: [
                  Shadow(
                    color: Colors.black,
                    blurRadius: 10,
                    offset: Offset(2, 2),
                  )
                ],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 30),
            GestureDetector(
              onTapDown: (_) => _controller.forward(),
              onTapUp: (_) => _controller.reverse(),
              onTap: () {
                String colorText = isArabic
                    ? colorNamesArabic[currentColorIndex]
                    : colorNamesEnglish[currentColorIndex];
                speak(isArabic
                    ? 'هذا لون $colorText'
                    : 'This is the color $colorText');
                vibrate();
              },
              child: AnimatedBuilder(
                animation: _animation,
                builder: (context, child) => Transform.scale(
                  scale: _animation.value,
                  child: child,
                ),
                child: Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    color: colors[currentColorIndex],
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white, width: 8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity(0.3),
                        spreadRadius: 5,
                        blurRadius: 15,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 30),
            Text(
              isArabic
                  ? 'هذا لون ${colorNamesArabic[currentColorIndex]}'
                  : 'This is ${colorNamesEnglish[currentColorIndex]}',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.w900,
                shadows: [
                  Shadow(
                    color: Colors.black,
                    blurRadius: 10,
                    offset: Offset(2, 2),
                  )
                ],
              ),
            ),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: nextColor,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber[800],
                padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40),
                  side: BorderSide(color: Colors.white, width: 3),
                ),
                shadowColor: Colors.amber[200],
                elevation: 10,
              ),
              child: Text(
                isArabic ? 'التالي' : 'Next',
                style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    letterSpacing: 1.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
