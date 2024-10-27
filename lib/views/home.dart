import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../consts/colors.dart';
import '../controller/player_controler.dart'; // Adjusted controller import
import '../consts/text_style.dart'; // Adjust the import path
import './player.dart';
import '../loading//home_loading.dart';
import 'package:audio_service/audio_service.dart';
import '../handler/audio_player_handler.dart';

class Home extends StatelessWidget {
  final AudioPlayerHandler audioHandler;

  const Home({super.key, required this.audioHandler});

  @override
  Widget build(BuildContext context) {
    var controller = Get.put(PlayerController(audioHandler: audioHandler));

    return Scaffold(
      backgroundColor: textColor,
      appBar: AppBar(
        title: Text(
          'Rathore Songs',
          style: ourStyle(size: 18),
        ),
        backgroundColor: const Color.fromARGB(255, 33, 45, 113),
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            color: bgColor,
            onPressed: () {
              showSearch(
                context: context,
                delegate: CustomSearchDelegate(controller: controller),
              );
            },
          ),
        ],
      ),
      body: Obx(() {
        var songs = controller.songs;

        if (controller.isLoading.value) {
          // Check if loading
          return LoadingSkeleton(); // Show loading skeleton
        }

        if (songs.isEmpty) {
          return const Center(
            child: Text(
              'No Songs Found',
              style: TextStyle(color: Colors.white),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            await controller.refreshSongs(); // Call your refresh method
          },
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: songs.length,
              itemBuilder: (BuildContext context, int index) {
                var song = songs[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 4),
                  child: InkWell(
                    onTap: () {
                      // if (controller.isPlaying.value) {
                      //   controller.stopAudio();
                      // }

                      controller.playAudioTwo(song, index);
                      Get.to(
                          () => Player(song: song, audioHandler: audioHandler));
                    },
                    child: ListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      tileColor: const Color(0xff1F212C),
                      title: Text(
                        song.split('/').last,
                        style: ourStyle(size: 15),
                      ),
                      subtitle: Text(
                        'Unknown Artist',
                        style: ourStyle(size: 12),
                      ),
                      leading: const Icon(
                        Icons.music_note,
                        color: bgColor,
                        size: 32,
                      ),
                      trailing: Obx(() {
                        return IconButton(
                          icon: Icon(
                            controller.isPlaying.value &&
                                    controller.songIndex.value == index
                                ? Icons.pause
                                : Icons.play_arrow,
                            color: bgColor,
                            size: 26,
                          ),
                          onPressed: () async {
                            if (controller.isPlaying.value &&
                                controller.songIndex.value == index) {
                              controller.pauseAudio();
                            } else {
                              if (controller.songIndex.value != index) {
                                // Set the source with the song file path.
                                controller.songIndex.value =
                                    index; // Update the current song index.
                              }
                              // await audioHandler.setAudioSource(song);
                              // await audioHandler.playAudio(song);
                              await controller.playAudioTwo(
                                song,
                                index,
                              );
                            }
                          },
                        );
                      }),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      }),
    );
  }
}

class CustomSearchDelegate extends SearchDelegate {
  final PlayerController controller;

  CustomSearchDelegate({required this.controller});

  @override
  ThemeData appBarTheme(BuildContext context) {
    return ThemeData.dark().copyWith(
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.black87, // Darker background for the app bar
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      inputDecorationTheme: const InputDecorationTheme(
        hintStyle: TextStyle(color: Colors.grey), // Text style for the hint
        border: InputBorder.none, // Removing the default border
      ),
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear, color: Colors.white),
        onPressed: () {
          query = ''; // Clear search input
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back, color: Colors.white),
      onPressed: () {
        close(context, null); // Close search
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    var results = controller.songs
        .where((song) => song.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        var song = results[index];
        return ListTile(
          tileColor: Colors.black45, // Background color for each item
          title: Text(
            song.split('/').last,
            style: const TextStyle(
              color: Colors.white, // Text color
              fontSize: 16,
            ),
          ),
          leading: const Icon(Icons.music_note,
              color: Colors.white70), // Icon for songs
          onTap: () {
            close(context, song);
            controller.playAudio(song); // Play selected song
          },
          hoverColor: Colors.grey.shade800, // Highlight color on hover
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    var suggestions = controller.songs
        .where((song) => song.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (context, index) {
        var song = suggestions[index];
        return ListTile(
          title: Text(
            song.split('/').last,
            style: const TextStyle(
              color: Colors.white70, // Lighter color for suggestions
              fontSize: 16,
            ),
          ),
          leading: const Icon(Icons.music_note, color: Colors.white70),
          onTap: () {
            query = song.split('/').last;
            showResults(context);
          },
        );
      },
    );
  }
}
