import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:vibration/vibration.dart';

class JoinTransportationScreen extends StatefulWidget {
  @override
  _JoinTransportationScreenState createState() => _JoinTransportationScreenState();
}

class _JoinTransportationScreenState extends State<JoinTransportationScreen>
    with TickerProviderStateMixin {
  int _correctMatches = 0;
  final FlutterTts flutterTts = FlutterTts();
  bool isArabic = true;
  late AnimationController _controller;
  late Animation<double> _animation;

  final List<Map<String, dynamic>> _items = [
    {
      'id': 1,
      'image': 'assets/transportation/airplane.jpg',
      'matched': false,
      'nameEn': 'Airplane',
      'nameAr': 'طائرة'
    },
    {
      'id': 2,
      'image': 'assets/transportation/car.jpg',
      'matched': false,
      'nameEn': 'Car',
      'nameAr': 'سيارة'
    },
    {
      'id': 3,
      'image': 'assets/transportation/ship.jpg',
      'matched': false,
      'nameEn': 'Ship',
      'nameAr': 'سفينة'
    },
  ];

  final List<Map<String, dynamic>> _targets = [
    {'id': 1, 'image': 'assets/transportation/airplane.jpg'},
    {'id': 2, 'image': 'assets/transportation/car.jpg'},
    {'id': 3, 'image': 'assets/transportation/ship.jpg'},
  ];

  @override
  void initState() {
    super.initState();
    // Add these 2 lines to shuffle lists on initialization
    _items.shuffle();
    _targets.shuffle();
    flutterTts.setLanguage("ar");
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
    _animation = Tween(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  void _resetGame() {
    setState(() {
      _correctMatches = 0;
      _items.forEach((item) => item['matched'] = false);
      _items.shuffle();
      _targets.shuffle();
    });
  }

  void speak(String text) async {
    await flutterTts.speak(text);
  }

  void vibrate({int duration = 500}) async {
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: duration);
    }
  }

  void toggleLanguage() {
    setState(() {
      isArabic = !isArabic;
      flutterTts.setLanguage(isArabic ? "ar" : "en");
    });
    speak(isArabic ? "تم التبديل إلى العربية" : "Switched to English");
    vibrate();
  }

  void _handleMatch(int itemId, int targetId) {
    if (itemId == targetId) {
      setState(() {
        _correctMatches++;
        _items.firstWhere((item) => item['id'] == itemId)['matched'] = true;
      });
      var item = _items.firstWhere((item) => item['id'] == itemId);
      final itemName = isArabic ? item['nameAr']! : item['nameEn']!;
      speak(isArabic ? 'أحسنت $itemName}' : 'Correct $itemName');
      vibrate();
      _controller.forward().then((_) => _controller.reverse());
    } else {
      speak(isArabic ? 'خطأ' : 'Wrong');
      vibrate(duration: 250);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isArabic ? "وسائل النقل" : "Transportations",
            style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
        backgroundColor: Colors.blue[900],
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, size: 30, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, size: 30, color: Colors.white),
            onPressed: _resetGame,
            tooltip: isArabic ? "إعادة التشغيل" : "Restart",
          ),
          IconButton(
            icon: Icon(Icons.language, size: 30, color: Colors.white),
            onPressed: toggleLanguage,
            tooltip: isArabic ? "تبديل إلى الإنجليزية" : "Switch to Arabic",
          ),
        ],
      ),
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: _items.map((item) {
                      if (item['matched']) {
                        // Hide matched items
                        return SizedBox(
                            width: 100, height: 100); // Maintain layout space
                      }
                      return Draggable<int>(
                        data: item['id'],
                        feedback: Image.asset(item['image'],
                            width: 100,
                            opacity: const AlwaysStoppedAnimation(0.5)),
                        childWhenDragging: Opacity(
                          opacity: 0.2,
                          child: Image.asset(item['image'], width: 100),
                        ),
                        child: GestureDetector(
                          onTap: () {
                            speak(isArabic ? item['nameAr'] : item['nameEn']);
                            vibrate();
                          },
                          child: Image.asset(item['image'], width: 100),
                        ),
                      );
                    }).toList(),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: _targets.map((target) {
                      return DragTarget<int>(
                        onAccept: (data) => _handleMatch(data, target['id']),
                        builder: (context, candidateData, rejectedData) {
                          bool isMatched = _items.any((item) =>
                              item['id'] == target['id'] && item['matched']);
                          return Container(
                            width: 100,
                            height: 100,
                            margin: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: isMatched
                                ? GestureDetector(
                                    onTap: () {
                                      final matchedItem = _items.firstWhere(
                                          (item) =>
                                              item['id'] == target['id'] &&
                                              item['matched']);
                                      speak(isArabic
                                          ? matchedItem['nameAr']
                                          : matchedItem['nameEn']);
                                      vibrate();
                                    },
                                    child: Image.asset(target['image'],
                                        width: 100),
                                  )
                                : Image.asset(target['image'],
                                    width: 100,
                                    opacity: const AlwaysStoppedAnimation(0.3)),
                          );
                        },
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                isArabic
                    ? 'اسحب وسيلة النقل إلى المكان المناسب'
                    : 'Drag the transportation to the correct place',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  shadows: [Shadow(color: Colors.black, blurRadius: 10)],
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.blue[900],
                border: Border.all(color: Colors.white, width: 3),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Text(
                    isArabic
                        ? 'التقدم: $_correctMatches/${_items.length}'
                        : 'Progress: $_correctMatches/${_items.length}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      shadows: [Shadow(color: Colors.white, blurRadius: 5)],
                    ),
                  ),
                  Icon(Icons.celebration, color: Colors.red[900], size: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
