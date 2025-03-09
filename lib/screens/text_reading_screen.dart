import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:vibration/vibration.dart';

class TextReadingScreen extends StatefulWidget {
  @override
  _TextReadingScreenState createState() => _TextReadingScreenState();
}

class _TextReadingScreenState extends State<TextReadingScreen>
    with TickerProviderStateMixin {
  CameraController? _cameraController;
  FlutterTts _tts = FlutterTts();
  bool _isProcessing = false;
  bool _isArabic = true;
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;
  String _detectedText = '';

  @override
  void initState() {
    super.initState();
    _initializeCamera();
    _setupTTS();
    _animController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
    _scaleAnimation = Tween(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    _cameraController = CameraController(cameras[0], ResolutionPreset.medium);
    await _cameraController!.initialize();
    if (!mounted) return;
    setState(() {});
  }

  Future<void> _setupTTS() async {
    await _tts.setLanguage(_isArabic ? "ar" : "en");
  }

  void _toggleLanguage() {
    setState(() {
      _isArabic = !_isArabic;
      _setupTTS();
    });
    _speak(_isArabic ? "اللغة العربية مفعلة" : "English activated");
    _vibrate();
  }

  Future<void> _captureAndRead() async {
    if (_isProcessing) return;
    _vibrate();
    setState(() => _isProcessing = true);

    try {
      final image = await _cameraController!.takePicture();
      final inputImage = InputImage.fromFilePath(image.path);
      final textRecognizer = TextRecognizer();

      final recognizedText = await textRecognizer.processImage(inputImage);
      await textRecognizer.close();

      if (recognizedText.text.isEmpty) {
        _showMessage(_isArabic ? 'لم يتم العثور على نص' : 'No text detected');
      } else {
        setState(() => _detectedText = recognizedText.text);
        _animController.forward().then((_) => _animController.reverse());
        await _speak(recognizedText.text);
      }
    } catch (e) {
      _showMessage(_isArabic ? 'خطأ في المعالجة: $e' : 'Processing error: $e');
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  Future<void> _speak(String text) async {
    await _tts.speak(text);
  }

  void _vibrate({int duration = 250}) async {
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: duration);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.amber[800],
        )
    );
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      backgroundColor: Colors.black,
      body: Column(
        children: [
          _cameraPreview(),
          _detectionResult(),
          _captureButton(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(
        _isArabic ? "قراءة النص" : "Text Reader",
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

  Widget _cameraPreview() {
    return Expanded(
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (_cameraController != null && _cameraController!.value.isInitialized)
            CameraPreview(_cameraController!),
          if (_isProcessing)
            CircularProgressIndicator(
              color: Colors.yellow[900],
              strokeWidth: 5,
            ),
        ],
      ),
    );
  }

  Widget _detectionResult() {
    return AnimatedBuilder(
      animation: _animController,
      builder: (context, child) => Transform.scale(
        scale: _scaleAnimation.value,
        child: Container(
          padding: EdgeInsets.all(10),
          margin: EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.black54,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            _detectedText,
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              shadows: [Shadow(color: Colors.black, blurRadius: 5)],
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  Widget _captureButton() {
    return Padding(
      padding: EdgeInsets.all(20),
      child: ElevatedButton.icon(
        icon: Icon(
          _isProcessing ? Icons.hourglass_top : Icons.camera_alt,
          color: Colors.black,
          size: 30,
        ),
        label: Text(
          _isProcessing
              ? (_isArabic ? 'جاري القراءة...' : 'Reading...')
              : (_isArabic ? 'قراءة النص' : 'Read Text'),
          style: TextStyle(
            fontSize: 24,
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        onPressed: _isProcessing ? null : _captureAndRead,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.amber[800],
          padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(40),
            side: BorderSide(color: Colors.white, width: 3),
          ),
          elevation: 10,
          shadowColor: Colors.amber[200],
        ),
      ),
    );
  }
}