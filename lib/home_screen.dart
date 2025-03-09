import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'screens/learning_activities_screen.dart';
import 'screens/shape_recognition_screen.dart';
import 'screens/color_recognition_screen.dart';
import 'screens/object_recognition_screen.dart';
import 'screens/text_reading_screen.dart';
import 'screens/spatial_navigation_screen.dart';
import 'screens/voice_assistant_screen.dart';
import 'screens/join_items_screen.dart';
import 'screens/customization_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VISION CVI',
      theme: ThemeData(
        fontFamily: 'Cairo',
        primarySwatch: Colors.teal,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FlutterTts flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _initializeTts();
  }

  Future<void> _initializeTts() async {
    await flutterTts.setLanguage("ar");
    await flutterTts.speak('مرحبًا بك في تطبيق BE VISION CVI');
  }

  Future<void> speak(String text) async {
    await flutterTts.stop();
    await flutterTts.speak(text);
  }

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: Column(
        children: [
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.teal[700],
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.visibility, size: 50, color: Colors.white),
                  const SizedBox(height: 10),
                  Text(
                    'BE VISION CVI',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Cairo',
                    ),
                  ),
                  Text(
                    'مرحبًا بك',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontFamily: 'Cairo',
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: GridView.count(
                crossAxisCount: 2,
                childAspectRatio: 0.9,
                crossAxisSpacing: 15,
                mainAxisSpacing: 15,
                children: [
                  _buildActivityButton(
                    'أنشطة التعلم',
                    Icons.school,
                    Colors.teal,
                    CVILearningScreen(),
                  ),
                  _buildActivityButton(
                    'تمييز الأشكال',
                    Icons.shape_line,
                    Colors.orange,
                    ShapeRecognitionScreen(),
                  ),
                  _buildActivityButton(
                    'تمييز الألوان',
                    Icons.color_lens,
                    Colors.pink,
                    ColorRecognitionScreen(),
                  ),
                  _buildActivityButton(
                    'التعرف على الأشياء',
                    Icons.category,
                    Colors.purple,
                    ObjectRecognitionScreen(),
                  ),
                  _buildActivityButton(
                    'قراءة النصوص',
                    Icons.text_fields,
                    Colors.blue,
                    TextReadingScreen(),
                  ),
                  _buildActivityButton(
                    'التوجيه المكاني',
                    Icons.navigation,
                    Colors.green,
                    SpatialNavigationScreen(),
                  ),
                  _buildActivityButton(
                    'المساعد الصوتي',
                    Icons.mic,
                    Colors.red,
                    VoiceAssistantScreen(),
                  ),
                  _buildActivityButton(
                    'التوصيل',
                    Icons.line_axis,
                    Colors.amber,
                    JoinItemsScreen(),
                  ),
                  _buildActivityButton(
                    'التخصيص',
                    Icons.settings,
                    Colors.indigo,
                    CustomizationScreen(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityButton(
      String title, IconData icon, Color color, Widget screen) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          speak(title);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => screen),
          );
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            color: color.withOpacity(0.9),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 40, color: Colors.white),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Cairo',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}