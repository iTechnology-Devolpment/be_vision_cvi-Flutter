import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:vibration/vibration.dart';
import 'package:audioplayers/audioplayers.dart';

class JoinColorsScreen extends StatefulWidget {
  @override
  _JoinColorsScreenState createState() => _JoinColorsScreenState();
}

class _JoinColorsScreenState extends State<JoinColorsScreen>
    with TickerProviderStateMixin {
  int _correctMatches = 0;
  final FlutterTts flutterTts = FlutterTts();
  bool isArabic = true;
  int _currentBatchIndex = 0;
  final int _batchSize = 3;
  late AnimationController _controller;
  late Animation<double> _animation;
  late final AudioPlayer _audioPlayer;

  final Map<Color, String> colorNameMapArabic = {
    Colors.black: 'أسود',
    Colors.white: 'أبيض',
    Colors.red[900]!: 'أحمر',
    Colors.green[900]!: 'أخضر',
    Colors.yellow[700]!: 'أصفر',
    Colors.blue[900]!: 'أزرق',
    Colors.orange[800]!: 'برتقالي',
    Colors.purple[800]!: 'بنفسجي',
  };

  final Map<Color, String> colorNameMapEnglish = {
    Colors.black: 'Black',
    Colors.white: 'White',
    Colors.red[900]!: 'Red',
    Colors.green[900]!: 'Green',
    Colors.yellow[700]!: 'Yellow',
    Colors.blue[900]!: 'Blue',
    Colors.orange[800]!: 'Orange',
    Colors.purple[800]!: 'Purple',
  };

  final List<Map<String, dynamic>> _items = [
    {'id': 1, 'color': Colors.black, 'shape': Icons.square, 'matched': false},
    {'id': 2, 'color': Colors.white, 'shape': Icons.square, 'matched': false},
    {
      'id': 3,
      'color': Colors.red[900]!,
      'shape': Icons.square,
      'matched': false
    },
    {
      'id': 4,
      'color': Colors.green[900]!,
      'shape': Icons.square,
      'matched': false
    },
    {
      'id': 5,
      'color': Colors.yellow[700]!,
      'shape': Icons.square,
      'matched': false
    },
    {
      'id': 6,
      'color': Colors.blue[900]!,
      'shape': Icons.square,
      'matched': false
    },
    {
      'id': 7,
      'color': Colors.orange[800]!,
      'shape': Icons.square,
      'matched': false
    },
    {
      'id': 8,
      'color': Colors.purple[800]!,
      'shape': Icons.square,
      'matched': false
    },
  ];

  late final List<Map<String, dynamic>> _targets = _items
      .map((item) => {
            'id': item['id'],
            'color': item['color'],
            'shape': item['shape'],
          })
      .toList();

  List<Map<String, dynamic>> get _currentItems {
    final start = _currentBatchIndex * _batchSize;
    final end = (_currentBatchIndex + 1) * _batchSize;
    return _items
        .where((item) => item['id'] > start && item['id'] <= end)
        .toList();
  }

  List<Map<String, dynamic>> get _currentTargets {
    final start = _currentBatchIndex * _batchSize;
    final end = (_currentBatchIndex + 1) * _batchSize;
    return _targets
        .where((target) => target['id'] > start && target['id'] <= end)
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
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

  Future<void> playClapSound() async {
    await _audioPlayer.play(AssetSource('sounds/clap.mp3'));
  }

  Future<void> playWrongSound() async {
    await _audioPlayer.play(AssetSource('sounds/wrong.mp3'));
  }

  void _resetGame() {
    setState(() {
      _correctMatches = 0;
      _currentBatchIndex = 0;
      _items.forEach((item) => item['matched'] = false);
      _items.shuffle();
      _targets.shuffle();
    });
  }

  Future<void> speak(String text) async {
    await flutterTts.speak(text);
  }

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
        _items.firstWhere((item) => item['id'] == itemId)['matched'] = true;

        final matchedInBatch =
            _currentItems.where((item) => item['matched']).length;
        if (matchedInBatch == _currentItems.length) {
          Future.delayed(Duration(milliseconds: 500), () {
            if ((_currentBatchIndex + 1) * _batchSize < _items.length) {
              setState(() {
                _currentBatchIndex++;
              });
            } else {
              speak(isArabic
                  ? "أحسنت، أنهيت اللعبة!"
                  : "Well done! You finished the game!");
            }
          });
        }
      });

      final matchedItem = _items.firstWhere((item) => item['id'] == itemId);
      final itemName = isArabic
          ? colorNameMapArabic[matchedItem['color']]!
          : colorNameMapEnglish[matchedItem['color']]!;
      await vibrate();
      await speak(itemName);
      await playClapSound();
      _controller.forward().then((_) => _controller.reverse());
    } else {
      await vibrate(duration: 250);
      await speak(isArabic ? 'خطأ' : 'Wrong');
      await playWrongSound();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isArabic ? "الألوان" : "Colors",
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
                      children: _currentItems.map((item) {
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
                            speak('$colorName');
                            vibrate();
                          },
                          child:
                              item['matched'] ? Container() : _buildShape(item),
                        );
                      }).toList(),
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: _currentTargets.map((target) {
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
                                        ? target['color']
                                        : target['color'].withOpacity(0.7),
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
                    ? 'اسحب اللون إلى المكان المناسب'
                    : 'Drag the color to the correct place',
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
        ),
      ),
    );
  }
}
