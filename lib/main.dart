import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:audio_service/audio_service.dart';
import './views/home.dart';
import './handler/audio_player_handler.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import "controller/player_controler.dart";

AudioPlayerHandler? audioHandler;
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> main() async {
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

  const MyApp({super.key, required this.audioHandler});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    Get.put(PlayerController(audioHandler: audioHandler));
    return GetMaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
          appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
      )),
      home: Home(audioHandler: audioHandler),
    );
  }
}
