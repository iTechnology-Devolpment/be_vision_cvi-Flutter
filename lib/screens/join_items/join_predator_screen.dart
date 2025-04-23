import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:vibration/vibration.dart';

class JoinPredatorScreen extends StatefulWidget {
  @override
  _JoinPredatorScreenState createState() => _JoinPredatorScreenState();
}

class _JoinPredatorScreenState extends State<JoinPredatorScreen>
    with TickerProviderStateMixin {
  int _correctMatches = 0;
  final FlutterTts flutterTts = FlutterTts();
  bool isArabic = true;
  late AnimationController _controller;
  late Animation<double> _animation;
  int _currentBatch = 0;

  final List<Map<String, dynamic>> _allItems = [
    {
      'id': 1,
      'matched': false,
      'image': 'assets/animals/predators/gorilla.jpg',
      'nameEn': 'Gorilla',
      'nameAr': 'الغوريلا'
    },
    {
      'id': 2,
      'matched': false,
      'image': 'assets/animals/predators/lion.jpg',
      'nameEn': 'Lion',
      'nameAr': 'أسد'
    },
    {
      'id': 3,
      'matched': false,
      'image': 'assets/animals/predators/tiger.jpg',
      'nameEn': 'Tiger',
      'nameAr': 'نمر'
    },
  ];

  late List<List<Map<String, dynamic>>> _batches;
  late List<List<Map<String, dynamic>>> _targetBatches;

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
    _resetGame();
  }

  List<List<Map<String, dynamic>>> _generateBatches(
      List<Map<String, dynamic>> list, int batchSize) {
    List<List<Map<String, dynamic>>> batches = [];
    for (int i = 0; i < list.length; i += batchSize) {
      batches.add(list.sublist(
          i, i + batchSize > list.length ? list.length : i + batchSize));
    }
    return batches;
  }

  void _resetGame() {
    setState(() {
      _correctMatches = 0;
      _currentBatch = 0;
      _allItems.forEach((item) => item['matched'] = false);
      _allItems.shuffle();
      List<Map<String, dynamic>> targets = List.from(_allItems);
      _batches = _generateBatches(_allItems, 3);
      _targetBatches = List.generate(
        _batches.length,
        (index) => List.from(_batches[index].map((item) => {
              'id': item['id'],
              'image': item['image'],
              'nameEn': item['nameEn'],
              'nameAr': item['nameAr'],
              'matched': false
            }))
          ..shuffle(),
      );
    });
  }

  Future<void> speak(String text) async => await flutterTts.speak(text);

  Future<void> vibrate({int duration = 500}) async {
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

  void _handleMatch(int itemId, int targetId) async {
    if (itemId == targetId) {
      setState(() {
        _correctMatches++;
        _batches[_currentBatch]
            .firstWhere((item) => item['id'] == itemId)['matched'] = true;
      });
      var item =
          _batches[_currentBatch].firstWhere((item) => item['id'] == itemId);
      final itemName = isArabic ? item['nameAr'] : item['nameEn'];
      await speak(itemName);
      vibrate();
      _controller.forward().then((_) => _controller.reverse());

      bool batchDone = _batches[_currentBatch].every((item) => item['matched']);
      if (batchDone && _currentBatch + 1 < _batches.length) {
        Future.delayed(Duration(seconds: 1), () {
          setState(() => _currentBatch++);
        });
      }
    } else {
      await speak(isArabic ? 'خطأ' : 'Wrong');
      await vibrate(duration: 250);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isArabic ? "الحيوانات المفترسة" : "Predators",
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
                    children: _batches[_currentBatch].map((item) {
                      if (item['matched']) {
                        return SizedBox(width: 100, height: 100);
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
                          child: Container(
                              width: 100,
                              height: 100,
                              margin: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                border:
                                    Border.all(color: Colors.white, width: 2),
                              ),
                              child: Image.asset(item['image'],
                                  width: 100, height: 100, fit: BoxFit.cover)),
                        ),
                      );
                    }).toList(),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: _targetBatches[_currentBatch].map((target) {
                      bool isMatched = _batches[_currentBatch].any((item) =>
                          item['id'] == target['id'] && item['matched']);
                      return DragTarget<int>(
                        onAccept: (data) => _handleMatch(data, target['id']),
                        builder: (context, candidateData, rejectedData) {
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
                                      final matchedItem =
                                          _batches[_currentBatch].firstWhere(
                                              (item) =>
                                                  item['id'] == target['id']);
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
                                    opacity: const AlwaysStoppedAnimation(0.5)),
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
                    ? 'اسحب الحيوان المفترس إلى المكان المناسب'
                    : 'Drag the predator to the correct place',
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
                        ? 'التقدم: $_correctMatches/${_allItems.length}'
                        : 'Progress: $_correctMatches/${_allItems.length}',
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
