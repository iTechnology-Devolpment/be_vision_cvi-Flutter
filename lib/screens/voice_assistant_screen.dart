import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:vibration/vibration.dart';

class VoiceAssistantScreen extends StatefulWidget {
  @override
  _VoiceAssistantScreenState createState() => _VoiceAssistantScreenState();
}

class _VoiceAssistantScreenState extends State<VoiceAssistantScreen>
    with TickerProviderStateMixin {
  final FlutterTts _tts = FlutterTts();
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  bool _isArabic = true;
  String _recognizedText = '';
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;
  bool _ttsInitialized = false;
  bool _sttAvailable = false;

  @override
  void initState() {
    super.initState();
    _initializeServices();
    _animController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
    _scaleAnimation = Tween(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  Future<void> _initializeServices() async {
    await _initializeTTS();
    await _initializeSTT();
  }

  Future<void> _initializeTTS() async {
    try {
      await _tts.setLanguage(_isArabic ? "ar-EG" : "en-US");
      await _tts.setSpeechRate(0.4);
      _ttsInitialized = true;
    } catch (e) {
      print("TTS Error: $e");
    }
  }

  Future<void> _initializeSTT() async {
    try {
      _sttAvailable = await _speech.initialize();
      setState(() {});
    } catch (e) {
      print("STT Error: $e");
    }
  }

  void _toggleLanguage() {
    setState(() {
      _isArabic = !_isArabic;
      _initializeTTS();
    });
    _vibrate();
    _speak(_isArabic ? "اللغة العربية مفعلة" : "English activated");
  }

  Future<void> _startListening() async {
    if (!_sttAvailable || _isListening) return;

    _vibrate();
    _animController.repeat(reverse: true);
    setState(() {
      _isListening = true;
      _recognizedText = '';
    });

    _speech.listen(
      onResult: (result) => _handleSpeechResult(result),
      localeId: _isArabic ? "ar_EG" : "en_US",
      listenFor: Duration(seconds: 10),
      cancelOnError: true,
      partialResults: false,
    );
  }

  void _handleSpeechResult(SpeechRecognitionResult result) {
    if (!result.finalResult) return;

    setState(() => _recognizedText = result.recognizedWords);
    _respondToCommand(result.recognizedWords);
    _animController.stop();
  }

  Future<void> _stopListening() async {
    await _speech.stop();
    _animController.stop();
    if (mounted) {
      setState(() => _isListening = false);
    }
  }

  Future<void> _respondToCommand(String command) async {
    String response = _isArabic
        ? _getArabicResponse(command.toLowerCase())
        : _getEnglishResponse(command.toLowerCase());

    await _speak(response);
    if (mounted) _startListening();
  }

  String _getArabicResponse(String command) {
    if (command.contains('مرحبا') || command.contains('السلام عليكم')) {
      return 'مرحبا! كيف يمكنني مساعدتك اليوم؟';
    } else if (command.contains('ما هذا') || command.contains('شرح')) {
      return 'هذا تطبيق مساعد لمساعدة الأطفال على التعلم باستخدام الصوت';
    } else if (command.contains('شكرا') || command.contains('متشكر')) {
      return 'العفو، دائماً في خدمتك!';
    }
    return 'لم أفهم ما تقول. يمكنك إعادة المحاولة من فضلك؟';
  }

  String _getEnglishResponse(String command) {
    if (command.contains('hello') || command.contains('hi')) {
      return 'Hello! How can I assist you today?';
    } else if (command.contains('what is this') || command.contains('explain')) {
      return 'This is a voice assistant app for children\'s learning';
    } else if (command.contains('thank you') || command.contains('thanks')) {
      return 'You\'re welcome! Always happy to help!';
    }
    return 'I didn\'t understand that. Could you please repeat?';
  }

  Future<void> _speak(String text) async {
    if (!_ttsInitialized) return;
    await _tts.speak(text);
    await _tts.awaitSpeakCompletion(true);
  }

  void _vibrate({int duration = 100}) async {
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: duration);
    }
  }

  @override
  void dispose() {
    _speech.stop();
    _tts.stop();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center, // Added horizontal centering
            mainAxisSize: MainAxisSize.min, // Prevents column from expanding full height
            children: [
              AnimatedBuilder(
                animation: _scaleAnimation,
                builder: (context, child) => Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Icon(
                    _isListening ? Icons.mic : Icons.mic_off,
                    size: 100,
                    color: _isListening ? Colors.green : Colors.red,
                  ),
                ),
              ),
              SizedBox(height: 30),
              Text(
                _isArabic ? 'المساعد الصوتي' : 'Voice Assistant',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(color: Colors.black, blurRadius: 5)],
                ),
                textAlign: TextAlign.center, // Ensure text alignment
              ),
              SizedBox(height: 20),
              _buildControlButton(),
              SizedBox(height: 30),
              _buildRecognizedText(),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(
        _isArabic ? 'المساعد الصوتي' : 'Voice Assistant',
        style: TextStyle(
          fontSize: 26,
          fontWeight: FontWeight.bold,
          shadows: [Shadow(color: Colors.black, blurRadius: 3)],
        ),
      ),
      backgroundColor: Colors.yellow[900],
      centerTitle: true,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, size: 30),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.language, size: 30),
          onPressed: _toggleLanguage,
          tooltip: _isArabic ? "Switch to English" : "تبديل إلى العربية",
        ),
      ],
    );
  }

  Widget _buildControlButton() {
    return ElevatedButton.icon(
      icon: Icon(
        _isListening ? Icons.stop : Icons.mic,
        size: 30,
        color: Colors.black,
      ),
      label: Text(
        _isListening
            ? (_isArabic ? 'توقف عن الاستماع' : 'Stop Listening')
            : (_isArabic ? 'ابدأ الاستماع' : 'Start Listening'),
        style: TextStyle(
          fontSize: 20,
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.amber[800],
        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
          side: BorderSide(color: Colors.white, width: 2),
        ),
        elevation: 10,
        shadowColor: Colors.amber[200],
      ),
      onPressed: () => _isListening ? _stopListening() : _startListening(),
    );
  }

  Widget _buildRecognizedText() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Text(
        _recognizedText,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white70,
          fontSize: 18,
          shadows: [Shadow(color: Colors.black, blurRadius: 3)],
        ),
      ),
    );
  }
}