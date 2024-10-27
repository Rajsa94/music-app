import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:audio_service/audio_service.dart';
import '../handler/audio_player_handler.dart'; // Import the correct handler

class PlayerNotification extends StatelessWidget {
  final AudioPlayerHandler audioHandler;

  const PlayerNotification({Key? key, required this.audioHandler})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Now Playing'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: audioHandler.play,
              child: const Text('Play'),
            ),
            ElevatedButton(
              onPressed: audioHandler.pause,
              child: const Text('Pause'),
            ),
            ElevatedButton(
              onPressed: audioHandler.skipToNext,
              child: const Text('Next'),
            ),
          ],
        ),
      ),
    );
  }
}
