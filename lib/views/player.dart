import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/player_controler.dart'; // Adjusted controller import

class Player extends StatelessWidget {
  final String song; // Pass the song information to the player page

  const Player({super.key, required this.song});

  @override
  Widget build(BuildContext context) {
    var controller = Get.put(PlayerController());

    return Scaffold(
      appBar: AppBar(
        title: const Text('Now Playing'),
        backgroundColor:
            const Color.fromARGB(255, 33, 45, 113), // Matches the tile color
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Display the song name
            Text(
              song.split('/').last, // Extract the song name from the path
              style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // Placeholder for album art or song thumbnail
            Icon(
              Icons.music_note,
              size: 150,
              color: Colors.grey[400],
            ),

            const SizedBox(height: 40),

            // Play/Pause and other controls
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.skip_previous, size: 48),
                  onPressed: () {
                    controller
                        .skipPrevious(); // Function to skip to previous song
                  },
                ),
                IconButton(
                  icon: Obx(() => Icon(
                        controller.isPlaying.value
                            ? Icons.pause
                            : Icons.play_arrow,
                        size: 64,
                      )),
                  onPressed: () {
                    controller.togglePlayPause(
                        song); // Toggle play/pause for the current song
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.skip_next, size: 48),
                  onPressed: () {
                    controller.skipNext(); // Function to skip to the next song
                  },
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Seek bar (progress bar)
            Obx(() {
              return Slider(
                value: controller.currentPosition.value.inSeconds.toDouble(),
                onChanged: (value) {
                  controller.seekTo(value); // Pass Duration
                },
                min: 0,
                max: controller.duration.value.inSeconds.toDouble() > 0
                    ? controller.duration.value.inSeconds.toDouble()
                    : 1, // Ensure max is > 0
                activeColor: Colors.blue,
                inactiveColor: Colors.grey,
              );
            }),

            const SizedBox(height: 20),

            // Display current position
            Obx(() => Text(
                  'Current Position: ${controller.currentPosition.value.inMinutes}:${(controller.currentPosition.value.inSeconds % 60).toString().padLeft(2, '0')}',
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                )),

            // Display total song duration
            Obx(() => Text(
                  'Duration: ${controller.duration.value.inMinutes}:${(controller.duration.value.inSeconds % 60).toString().padLeft(2, '0')}',
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                )),
          ],
        ),
      ),
      backgroundColor: const Color(0xff1F212C), // Match theme color
    );
  }
}
