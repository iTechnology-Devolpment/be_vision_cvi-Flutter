import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class CVILearningScreen extends StatefulWidget {
  @override
  _CVILearningScreenState createState() => _CVILearningScreenState();
}

class _CVILearningScreenState extends State<CVILearningScreen> {
  final FlutterTts _tts = FlutterTts();
  final List<CviActivity> _activities = [
    CviActivity(
      title: 'الأشكال',
      items: [
        CviItem('مربع', Icons.crop_square, Colors.red),
        CviItem('دائرة', Icons.circle, Colors.blue),
        CviItem('مثلث', Icons.change_history, Colors.green),
        CviItem('نجمة', Icons.star, Colors.yellow),
      ],
    ),
    CviActivity(
      title: 'الألوان',
      items: [
        CviItem('أحمر', null, Colors.red),
        CviItem('أزرق', null, Colors.blue),
        CviItem('أخضر', null, Colors.green),
        CviItem('أصفر', null, Colors.yellow),
      ],
    ),
  ];

  int _currentActivityIndex = 0;
  int _currentItemIndex = 0;
  final double _itemSize = 200.0;

  @override
  void initState() {
    super.initState();
    _initTTS();
  }

  Future<void> _initTTS() async {
    await _tts.setLanguage('ar');
    await _tts.setSpeechRate(0.5);
  }

  void _changeItem(int direction) {
    setState(() {
      _currentItemIndex = (_currentItemIndex + direction).clamp(0, _currentActivity.items.length - 1);
    });
    _speakCurrentItem();
  }

  void _changeActivity() {
    setState(() {
      _currentActivityIndex = (_currentActivityIndex + 1) % _activities.length;
      _currentItemIndex = 0;
    });
    _speakCurrentActivity();
  }

  void _speakCurrentItem() => _tts.speak(_currentItem.name);
  void _speakCurrentActivity() => _tts.speak('نشاط ${_currentActivity.title}');

  CviActivity get _currentActivity => _activities[_currentActivityIndex];
  CviItem get _currentItem => _currentActivity.items[_currentItemIndex];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: GestureDetector(
                onHorizontalDragEnd: (details) => _handleHorizontalSwipe(details),
                onVerticalDragEnd: (details) => _handleVerticalSwipe(details),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      _buildMainVisual(),
                      const SizedBox(height: 40),
                      _buildItemName(),
                      const SizedBox(height: 30),
                      _buildProgressIndicator(),
                    ],
                  ),
                ),
              ),
            ),
            _buildControlButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildIconButton(Icons.volume_up, _speakCurrentItem),
          Text(
            _currentActivity.title,
            style: const TextStyle(
              fontSize: 36,
              color: Colors.yellow,
              fontWeight: FontWeight.bold,
              fontFamily: 'Cairo',
            ),
          ),
          _buildIconButton(Icons.refresh, _changeActivity),
        ],
      ),
    );
  }

  Widget _buildMainVisual() {
    return Container(
      width: _itemSize,
      height: _itemSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: Colors.yellow.withOpacity(0.5),
          width: 4,
        ),
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        child: _currentActivity.title == 'الأشكال'
            ? Icon(
          _currentItem.icon,
          size: _itemSize * 0.8,
          color: _currentItem.color,
        )
            : Container(
          decoration: BoxDecoration(
            color: _currentItem.color,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }

  Widget _buildItemName() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border.all(color: Colors.yellow, width: 3),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        _currentItem.name,
        style: TextStyle(
          fontSize: 48,
          color: Colors.yellow,
          fontWeight: FontWeight.bold,
          fontFamily: 'Cairo',
        ),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        _currentActivity.items.length,
            (index) => Container(
          width: 20,
          height: 20,
          margin: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: index == _currentItemIndex ? Colors.yellow : Colors.grey,
          ),
        ),
      ),
    );
  }

  Widget _buildControlButtons() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildControlButton(Icons.arrow_back_ios, () => _changeItem(-1)),
          const SizedBox(width: 40),
          _buildControlButton(Icons.arrow_forward_ios, () => _changeItem(1)),
        ],
      ),
    );
  }

  Widget _buildControlButton(IconData icon, VoidCallback onPressed) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.black, backgroundColor: Colors.yellow,
        padding: const EdgeInsets.all(20),
        shape: const CircleBorder(),
        elevation: 5,
      ),
      onPressed: onPressed,
      child: Icon(icon, size: 40),
    );
  }

  Widget _buildIconButton(IconData icon, VoidCallback onPressed) {
    return IconButton(
      icon: Icon(icon, size: 36),
      color: Colors.yellow,
      onPressed: onPressed,
    );
  }

  void _handleHorizontalSwipe(DragEndDetails details) {
    if (details.primaryVelocity! > 0) _changeItem(-1);
    if (details.primaryVelocity! < 0) _changeItem(1);
  }

  void _handleVerticalSwipe(DragEndDetails details) {
    if (details.primaryVelocity! > 0) _changeActivity();
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }
}

class CviActivity {
  final String title;
  final List<CviItem> items;

  CviActivity({required this.title, required this.items});
}

class CviItem {
  final String name;
  final IconData? icon;
  final Color color;

  CviItem(this.name, this.icon, this.color);
}