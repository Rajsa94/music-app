import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:audio_service/audio_service.dart';
import './views/home.dart';
import './handler/audio_player_handler.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import "controller/player_controler.dart";
import './views/splash_screen.dart';
import "./layout/bottom_navigation_bar.dart";
import "./views/live_music.dart";
import "./views/chat.dart";

AudioPlayerHandler? audioHandler;
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> main() async {
  // WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  // FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize the AudioService before requesting permissions
  audioHandler = await AudioService.init(
    builder: () => AudioPlayerHandler(),
    config: const AudioServiceConfig(
      androidNotificationChannelId: 'com.example.songs',
      androidNotificationChannelName: 'Music Playback',
      androidNotificationOngoing: true,
    ),
  );
  WidgetsFlutterBinding.ensureInitialized();
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  const InitializationSettings initializationSettings =
      InitializationSettings(android: initializationSettingsAndroid);

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  await checkPermissions();
  // FlutterNativeSplash.remove();
  runApp(MyApp(audioHandler: audioHandler!));
}

// Create a function to check permissions
Future<void> checkPermissions() async {
  var audioPermission = await Permission.audio.status;
  if (audioPermission.isDenied) {
    await Permission.audio.request();
  }
}

class MyApp extends StatelessWidget {
  final AudioPlayerHandler audioHandler;

  const MyApp({Key? key, required this.audioHandler}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Get.put(PlayerController(audioHandler: audioHandler));
    return GetMaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
      ),
      // Set SplashScreen as the initial screen
      home: SplashScreen(),
      getPages: [
        GetPage(name: '/', page: () => SplashScreen()),
        GetPage(
            name: '/home', page: () => MyHomePage(audioHandler: audioHandler)),
      ],
    );
  }
}

class MyHomePage extends StatefulWidget {
  final AudioPlayerHandler audioHandler;

  const MyHomePage({Key? key, required this.audioHandler}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;
  late final List<Widget> _pages;
  // final List<Widget> _pages =  [
  //   Home(audioHandler: audioHandler),
  //   LiveMusic(),
  // ];
  @override
  void initState() {
    super.initState();
    _pages = [
      Home(audioHandler: widget.audioHandler),
      LiveMusic(audioHandler: widget.audioHandler),
      ChatBotUI(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigation(
        selectedIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}
