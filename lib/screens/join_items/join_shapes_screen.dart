import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:vibration/vibration.dart';

class JoinShapesScreen extends StatefulWidget {
  @override
  _JoinShapesScreenState createState() => _JoinShapesScreenState();
}

class _JoinShapesScreenState extends State<JoinShapesScreen>
    with TickerProviderStateMixin {
  int _correctMatches = 0;
  final FlutterTts flutterTts = FlutterTts();
  bool isArabic = true;
  late AnimationController _controller;
  late Animation<double> _animation;

  final Map<Color, String> colorNameMapArabic = {
    Colors.red: 'أحمر',
    Colors.blue: 'أزرق',
    Colors.green: 'أخضر',
  };

  final Map<Color, String> colorNameMapEnglish = {
    Colors.red: 'Red',
    Colors.blue: 'Blue',
    Colors.green: 'Green',
  };

  final Map<IconData, String> shapeNameMapArabic = {
    Icons.circle: 'دائرة',
    Icons.square: 'مربع',
    Icons.change_history: 'مثلث',
  };

  final Map<IconData, String> shapeNameMapEnglish = {
    Icons.circle: 'Circle',
    Icons.square: 'Square',
    Icons.change_history: 'Triangle',
  };

  final List<Map<String, dynamic>> _items = [
    {'id': 1, 'color': Colors.red, 'shape': Icons.circle, 'matched': false},
    {'id': 2, 'color': Colors.blue, 'shape': Icons.square, 'matched': false},
    {
      'id': 3,
      'color': Colors.green,
      'shape': Icons.change_history,
      'matched': false
    },
  ];

  final List<Map<String, dynamic>> _targets = [
    {'id': 1, 'color': Colors.red, 'shape': Icons.circle},
    {'id': 2, 'color': Colors.blue, 'shape': Icons.square},
    {'id': 3, 'color': Colors.green, 'shape': Icons.change_history},
  ];

  @override
  void initState() {
    super.initState();
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
      final matchedItem = _items.firstWhere((item) => item['id'] == itemId);
      final itemName = isArabic
          ? shapeNameMapArabic[matchedItem['shape']]!
          : shapeNameMapEnglish[matchedItem['shape']]!;
      speak(isArabic ? 'أحسنت $itemName' : 'Perfect $itemName');
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
        title: Text(isArabic ? "الأشكال" : "Shapes",
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
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: _items.map((item) {
                        return Draggable<int>(
                          data: item['id'],
                          feedback: _buildShape(item, scale: 1.2),
                          childWhenDragging: Opacity(
                            opacity: 0.5,
                            child: _buildShape(item),
                          ),
                          onDragStarted: () {
                            final colorName = isArabic
                                ? colorNameMapArabic[item['color']]!
                                : colorNameMapEnglish[item['color']]!;
                            final shapeName = isArabic
                                ? shapeNameMapArabic[item['shape']]!
                                : shapeNameMapEnglish[item['shape']]!;
                            speak('$colorName $shapeName');
                            vibrate();
                          },
                          child:
                              item['matched'] ? Container() : _buildShape(item),
                        );
                      }).toList(),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: _targets.map((target) {
                        return DragTarget<int>(
                          builder: (context, candidates, rejects) {
                            return AnimatedBuilder(
                              animation: _controller,
                              builder: (context, child) {
                                return Transform.scale(
                                  scale: _animation.value,
                                  child: child,
                                );
                              },
                              child: Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 5,
                                    style: candidates.isNotEmpty
                                        ? BorderStyle.none
                                        : BorderStyle.solid,
                                  ),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Center(
                                  child: Icon(
                                    target['shape'],
                                    color: _items.any((item) =>
                                            item['id'] == target['id'] &&
                                            item['matched'])
                                        ? target[
                                            'color'] // Full opacity when matched
                                        : target['color'].withOpacity(0.3),
                                    // 30% opacity otherwise
                                    size: 80,
                                  ),
                                ),
                              ),
                            );
                          },
                          onAccept: (data) => _handleMatch(data, target['id']),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                isArabic
                    ? 'اسحب الشكل إلى المكان المناسب'
                    : 'Drag the shape to the correct place',
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

  Widget _buildShape(Map<String, dynamic> item, {double scale = 1.0}) {
    return Transform.scale(
      scale: scale,
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: item['color'],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white, width: 5),
          boxShadow: [
            BoxShadow(
              color: Colors.white.withOpacity(0.3),
              spreadRadius: 2,
              blurRadius: 10,
              offset: Offset(0, 3),
            )
          ],
        ),
        child: Icon(item['shape'], color: Colors.white, size: 60),
      ),
    );
  }
}
