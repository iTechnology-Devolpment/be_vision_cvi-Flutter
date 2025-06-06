import 'package:be_vision_cvi/screens/about_project_screen.dart';
import 'package:be_vision_cvi/screens/items_recognition/pet_recognition_screen.dart';
import 'package:be_vision_cvi/screens/items_recognition/recognition_screen.dart';
import 'package:be_vision_cvi/screens/join_items/join_pets_screen.dart';
import 'package:be_vision_cvi/screens/join_items/join_screen.dart';
import 'package:be_vision_cvi/screens/join_items/join_shapes_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'screens/learning_activities_screen.dart';
import 'screens/items_recognition/shape_recognition_screen.dart';
import 'screens/items_recognition/color_recognition_screen.dart';
import 'screens/object_recognition_screen.dart';
import 'screens/spatial_navigation_screen.dart';
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
        primarySwatch: Colors.blue,
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
              color: Colors.blue[900],
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
                    Colors.blue[900]!,
                    RecognitionScreen(),
                  ),
                  _buildActivityButton(
                    'التوصيل',
                    Icons.line_axis,
                    Colors.blue[900]!,
                    JoinScreen(),
                  ),
                  _buildActivityButton(
                    'التعرف على الأشياء',
                    Icons.category,
                    Colors.blue[900]!,
                    ObjectRecognitionScreen(),
                  ),
                  _buildActivityButton(
                    'التوجيه المكاني',
                    Icons.navigation,
                    Colors.blue[900]!,
                    SpatialNavigationScreen(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SizedBox(
          height: 60,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[900],
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 5,
            ),
            onPressed: () {
              speak('عن المشروع');
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AboutProjectScreen(),
                ),
              );
            },
            icon: Icon(Icons.info, color: Colors.white),
            label: Text(
              'عن المشروع',
              style: TextStyle(
                fontSize: 20,
                fontFamily: 'Cairo',
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
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