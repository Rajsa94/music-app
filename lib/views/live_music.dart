import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/music_controler.dart';
import '../consts/text_style.dart';
import '../handler/audio_player_handler.dart';
import '../controller/player_controler.dart';
import './player.dart';

class LiveMusic extends StatelessWidget {
  final AudioPlayerHandler audioHandler;
  const LiveMusic({super.key, required this.audioHandler});

  @override
  Widget build(BuildContext context) {
    final MusicController controller = Get.put(MusicController());
    final PlayerController controllerTwo =
        Get.put(PlayerController(audioHandler: audioHandler));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Live Music',
          style: ourStyle(size: 18, color: Colors.white), // Adjust text color
        ),
        backgroundColor: const Color(0xFF1A237E),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        } else if (controller.musicList.isEmpty) {
          return const Center(
            child: Text('No music found', style: TextStyle(fontSize: 18)),
          );
        } else {
          return RefreshIndicator(
            onRefresh: () async {
              controller.loadMusic();
            },
            child: ListView.builder(
              itemCount: controller.musicList.length,
              itemBuilder: (context, index) {
                final music = controller.musicList[index];
                return InkWell(
                  onTap: () {
                    controllerTwo.playAudioTwo(music.songUrl, index);
                    Get.to(() => Player(
                        song: music.songUrl, audioHandler: audioHandler));
                  },
                  child: Card(
                    elevation: 12, // Enhanced shadow effect
                    margin:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(12), // Rounded corners
                    ),
                    child: ListTile(
                      contentPadding:
                          const EdgeInsets.all(16), // Padding inside the tile
                      leading: ClipRRect(
                        borderRadius:
                            BorderRadius.circular(8), // Rounded image corners
                        child: Image.network(
                          music.albumImageUrl,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              width: 50,
                              height: 50,
                              color: Colors.grey[300], // Placeholder color
                              child: const Icon(Icons.music_note,
                                  size: 30, color: Colors.white),
                            );
                          },
                        ),
                      ),
                      title: Text(
                        music.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      subtitle: Text(
                        '${music.genre} - Plays: ${music.noOfPlays}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.play_arrow, color: Colors.blue),
                        onPressed: () {
                          // Play music using music.songUrl
                          controller.playMusic(music.songUrl);
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        }
      }),
    );
  }
}
