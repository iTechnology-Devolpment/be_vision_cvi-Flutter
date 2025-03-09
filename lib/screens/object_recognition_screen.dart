import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tflite_v2/tflite_v2.dart';
import 'package:vibration/vibration.dart';

class ObjectRecognitionScreen extends StatefulWidget {
  @override
  _ObjectRecognitionScreenState createState() =>
      _ObjectRecognitionScreenState();
}

class _ObjectRecognitionScreenState extends State<ObjectRecognitionScreen>
    with TickerProviderStateMixin {
  CameraController? _cameraController;
  FlutterTts _tts = FlutterTts();
  bool _isCameraReady = false;
  bool _isProcessing = false;
  bool _isArabic = true;
  List<dynamic>? _detections;
  String? _currentObject;
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;

  // خريطة الترجمة الثنائية (عربي, إنجليزي)
  final Map<String, String> _bilingualTranslations = {
    "person": "شخص,Person",
    "bicycle": "دراجة,Bicycle",
    "car": "سيارة,Car",
    "motorcycle": "دراجة نارية,Motorcycle",
    "airplane": "طائرة,Airplane",
    "bus": "حافلة,Bus",
    "train": "قطار,Train",
    "truck": "شاحنة,Truck",
    "boat": "قارب,Boat",
    "traffic light": "إشارة مرور,Traffic Light",
    "fire hydrant": "صنبور إطفاء,Fire Hydrant",
    "stop sign": "علامة توقف,Stop Sign",
    "parking meter": "عداد موقف,Parking Meter",
    "bench": "مقعد,Bench",
    "bird": "طائر,Bird",
    "cat": "قطة,Cat",
    "dog": "كلب,Dog",
    "horse": "حصان,Horse",
    "sheep": "خروف,Sheep",
    "cow": "بقرة,Cow",
    "elephant": "فيل,Elephant",
    "bear": "دب,Bear",
    "zebra": "حمار وحشي,Zebra",
    "giraffe": "زرافة,Giraffe",
    "backpack": "حقيبة ظهر,Backpack",
    "umbrella": "مظلة,Umbrella",
    "handbag": "حقيبة يد,Handbag",
    "tie": "ربطة عنق,Tie",
    "suitcase": "حقيبة سفر,Suitcase",
    "frisbee": "قرص طائر,Frisbee",
    "skis": "زلاجات,Skis",
    "snowboard": "لوح ثلج,Snowboard",
    "sports ball": "كرة رياضية,Sports Ball",
    "kite": "طائرة ورقية,Kite",
    "baseball bat": "مضرب بيسبول,Baseball Bat",
    "baseball glove": "قفاز بيسبول,Baseball Glove",
    "skateboard": "لوح تزلج,Skateboard",
    "surfboard": "لوح موج,Surfboard",
    "tennis racket": "مضرب تنس,Tennis Racket",
    "bottle": "زجاجة,Bottle",
    "wine glass": "كأس نبيذ,Wine Glass",
    "cup": "كوب,Cup",
    "fork": "شوكة,Fork",
    "knife": "سكين,Knife",
    "spoon": "ملعقة,Spoon",
    "bowl": "وعاء,Bowl",
    "banana": "موزة,Banana",
    "apple": "تفاحة,Apple",
    "sandwich": "ساندويتش,Sandwich",
    "orange": "برتقال,Orange",
    "broccoli": "بروكلي,Broccoli",
    "carrot": "جزر,Carrot",
    "hot dog": "هوت دوج,Hot Dog",
    "pizza": "بيتزا,Pizza",
    "donut": "دونات,Donut",
    "cake": "كعكة,Cake",
    "chair": "كرسي,Chair",
    "couch": "أريكة,Couch",
    "potted plant": "نبتة في أصيص,Potted Plant",
    "bed": "سرير,Bed",
    "dining table": "طاولة طعام,Dining Table",
    "toilet": "مرحاض,Toilet",
    "tv": "تلفاز,TV",
    "laptop": "حاسوب محمول,Laptop",
    "mouse": "فأرة,Mouse",
    "remote": "ريموت,Remote",
    "keyboard": "لوحة مفاتيح,Keyboard",
    "cell phone": "هاتف محمول,Cell Phone",
    "microwave": "ميكروويف,Microwave",
    "oven": "فرن,Oven",
    "toaster": "محمصة,Toaster",
    "sink": "حوض,Sink",
    "refrigerator": "ثلاجة,Refrigerator",
    "book": "كتاب,Book",
    "clock": "ساعة,Clock",
    "vase": "مزهرية,Vase",
    "scissors": "مقص,Scissors",
    "teddy bear": "دمية دب,Teddy Bear",
    "hair drier": "مجفف شعر,Hair Dryer",
    "toothbrush": "فرشاة أسنان,Toothbrush",
  };

  @override
  void initState() {
    super.initState();
    _initializeApp();
    _animController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
    _scaleAnimation = Tween(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOut),
    );
  }

  Future<void> _initializeApp() async {
    await _requestPermissions();
    await _setupCamera();
    await _configureTTS();
    await _loadMLModel();
  }

  Future<void> _requestPermissions() async {
    await [Permission.camera, Permission.microphone].request();
  }

  Future<void> _setupCamera() async {
    try {
      final cameras = await availableCameras();
      _cameraController = CameraController(cameras[0], ResolutionPreset.medium);
      await _cameraController!.initialize();
      if (!mounted) return;
      setState(() => _isCameraReady = true);
    } catch (e) {
      print('Camera Error: $e');
    }
  }

  Future<void> _configureTTS() async {
    await _tts.setLanguage(_isArabic ? "ar" : "en");
  }

  Future<void> _loadMLModel() async {
    try {
      await Tflite.loadModel(
        model: "assets/ssd_mobilenet.tflite",
        labels: "assets/ssd_mobilenet.txt",
      );
    } catch (e) {
      print('Model Loading Error: $e');
    }
  }

  void _toggleLanguage() {
    setState(() {
      _isArabic = !_isArabic;
      _configureTTS();
    });
    _speak(_isArabic ? "اللغة العربية مفعلة" : "English activated");
    _vibrate();
  }

  Future<void> _captureImage() async {
    if (_isProcessing) return;
    _vibrate();

    try {
      final image = await _cameraController!.takePicture();
      await _analyzeImage(image.path);
    } catch (e) {
      print('Capture Error: $e');
    }
  }

  Future<void> _analyzeImage(String imagePath) async {
    setState(() => _isProcessing = true);

    try {
      var results = await Tflite.detectObjectOnImage(
        path: imagePath,
        threshold: 0.4,
      );

      if (results != null && results.isNotEmpty) {
        String detectedClass = results[0]['detectedClass'];
        String localizedName = _localizeName(detectedClass);

        setState(() {
          _detections = results;
          _currentObject = localizedName;
        });

        _animController.forward().then((_) => _animController.reverse());
        await _speak(localizedName);
      }
    } catch (e) {
      print('Analysis Error: $e');
    }

    setState(() => _isProcessing = false);
  }

  String _localizeName(String className) {
    String? translations = _bilingualTranslations[className];
    return _isArabic
        ? translations?.split(',').first ?? className
        : translations?.split(',').last ?? className;
  }

  Future<void> _speak(String text) async {
    await _tts.speak(text);
  }

  void _vibrate({int duration = 250}) async {
    if (await Vibration.hasVibrator() ?? false) {
      Vibration.vibrate(duration: duration);
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    Tflite.close();
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
          _captureButton(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(
        _isArabic ? "التعرف على الأشياء" : "Object Recognition",
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
          if (_isCameraReady) CameraPreview(_cameraController!),
          if (_currentObject != null)
            AnimatedBuilder(
              animation: _animController,
              builder: (context, child) => Transform.scale(
                scale: _scaleAnimation.value,
                child: Container(
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.yellow[900]!,
                        spreadRadius: 3,
                        blurRadius: 10,
                      )
                    ],
                  ),
                  child: Text(
                    _currentObject!,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(
                          color: Colors.black,
                          blurRadius: 10,
                          offset: Offset(2, 2),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          if (_isProcessing)
            CircularProgressIndicator(
              color: Colors.yellow[900],
              strokeWidth: 5,
            ),
        ],
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
                ? (_isArabic ? 'جاري التحليل...' : 'Analyzing...')
                : (_isArabic ? 'التقاط صورة' : 'Capture'),
            style: TextStyle(
              fontSize: 24,
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          onPressed: _isProcessing ? null : _captureImage,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.amber[800],
            padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(40),
              side: BorderSide(color: Colors.white, width: 3),
            ),
          ),
        ));
  }
}
