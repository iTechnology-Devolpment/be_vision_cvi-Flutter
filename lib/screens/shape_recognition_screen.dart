import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:vibration/vibration.dart';

class ShapeRecognitionScreen extends StatefulWidget {
  @override
  _ShapeRecognitionScreenState createState() => _ShapeRecognitionScreenState();
}

class _ShapeRecognitionScreenState extends State<ShapeRecognitionScreen>
    with TickerProviderStateMixin {
  FlutterTts flutterTts = FlutterTts();
  List<String> shapes = ['circle', 'square', 'triangle', 'star'];
  int currentShapeIndex = 0;
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

  String translate(String key) {
    Map<String, Map<String, String>> translations = {
      'ar': {
        'circle': 'دائرة',
        'square': 'مربع',
        'triangle': 'مثلث',
        'star': 'نجمة',
        'next': 'التالي',
        'languageChanged': 'تم تغيير اللغة',
        'appTitle': 'تمييز الأشكال',
        'currentShape': 'هذا شكل'
      },
      'en': {
        'circle': 'Circle',
        'square': 'Square',
        'triangle': 'Triangle',
        'star': 'Star',
        'next': 'Next',
        'languageChanged': 'Language changed',
        'appTitle': 'Shape Recognition',
        'currentShape': 'This is a'
      }
    };
    return translations[selectedLanguage]![key] ?? key;
  }

  void speak(String text) async => await flutterTts.speak(text);

  void vibrate() async {
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: 500);
    }
  }

  void nextShape() {
    _controller.forward().then((_) => _controller.reverse());
    setState(() => currentShapeIndex = (currentShapeIndex + 1) % shapes.length);
    speak('${translate("currentShape")} ${translate(shapes[currentShapeIndex])}');
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
            shadows: [Shadow(color: Colors.black, blurRadius: 5)],
          )),
      backgroundColor: Colors.yellow[900],
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

  Widget getShapeWidget() {
    String currentShape = shapes[currentShapeIndex];

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) => Transform.scale(
        scale: _animation.value,
        child: child,
      ),
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
        child: _getShapePainter(currentShape),
      ),
    );
  }

  Widget _getShapePainter(String shape) {
    switch (shape) {
      case 'circle':
        return Container(
          decoration: BoxDecoration(
            color: Colors.yellow[800],
            shape: BoxShape.circle,
          ),
        );
      case 'square':
        return Container(
          color: Colors.blue[900],
          margin: EdgeInsets.all(20),
        );
      case 'triangle':
        return CustomPaint(
          painter: TrianglePainter(),
        );
      case 'star':
        return CustomPaint(
          painter: StarPainter(),
        );
      default:
        return Container();
    }
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
            GestureDetector(
              onTapDown: (_) => _controller.forward(),
              onTapUp: (_) => _controller.reverse(),
              onTap: () {
                speak(
                    '${translate("currentShape")} ${translate(shapes[currentShapeIndex])}');
                vibrate();
              },
              child: getShapeWidget(),
            ),
            SizedBox(height: 30),
            Text(
              translate(shapes[currentShapeIndex]),
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.w900,
                shadows: [Shadow(color: Colors.black, blurRadius: 10)],
              ),
            ),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: nextShape,
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
                translate("next"),
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

class TrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.green[900]!
      ..style = PaintingStyle.fill;

    final Paint borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8;

    Path path = Path();
    path.moveTo(size.width / 2, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();

    canvas.drawPath(path, paint);
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class StarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.red[900]!
      ..style = PaintingStyle.fill;

    final Paint borderPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8;

    Path path = Path();
    double centerX = size.width / 2;
    double centerY = size.height / 2;
    double radius = size.width / 2.5;

    for (int i = 0; i < 10; i++) {
      double angle = i * 36 * (pi / 180);
      double r = i % 2 == 0 ? radius : radius / 2;
      double x = centerX + r * cos(angle);
      double y = centerY + r * sin(angle);
      if (i == 0)
        path.moveTo(x, y);
      else
        path.lineTo(x, y);
    }
    path.close();

    canvas.drawPath(path, paint);
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}