import 'package:flutter/material.dart';
import 'package:get/get.dart';
// import '../consts/colors.dart';
import '../controller/player_controler.dart'; // Adjusted controller import
import '../consts/text_style.dart'; // Adjust the import path
import './player.dart';
import '../loading/home_loading.dart';
import '../handler/audio_player_handler.dart';
// import '../layout/custom_navbar_curved.dart';

class Home extends StatelessWidget {
  final AudioPlayerHandler audioHandler;
  const Home({super.key, required this.audioHandler});

  @override
  Widget build(BuildContext context) {
    // Ensure you define the audioHandler before this line
    var controller = Get.put(PlayerController(audioHandler: audioHandler));

    return Scaffold(
      // backgroundColor: Colors.white, // Main background color
      appBar: AppBar(
        title: Text(
          'Local Storage Music',
          style: ourStyle(size: 18, color: Colors.white), // White text color
        ),
        backgroundColor: const Color(0xFF1A237E), // Dark blue color
        elevation: 4,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            color: Colors.white,
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
          return LoadingSkeleton(); // Display loading skeleton
        }

        if (songs.isEmpty) {
          return const Center(
            child: Text(
              'No Songs Found',
              style: TextStyle(color: Colors.black), // Improved visibility
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            await controller.refreshSongs(); // Refresh songs
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0), // Outer padding
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: songs.length,
              itemBuilder: (BuildContext context, int index) {
                var song = songs[index];
                return Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                  child: InkWell(
                    onTap: () {
                      controller.playAudioTwo(song, index);
                      Get.to(
                          () => Player(song: song, audioHandler: audioHandler));
                    },
                    child: Card(
                      elevation: 8, // Shadow effect
                      shadowColor: Colors.black26,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListTile(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        // tileColor:
                        //     const Color(0xfff0f0f0), // Light gray background
                        title: Text(
                          song.split('/').last,
                          style: ourStyle(
                              size: 16, color: Colors.black), // Darker text
                        ),
                        subtitle: Text(
                          'Unknown Artist',
                          style: ourStyle(
                              size: 14,
                              color: Colors.black54), // Lighter subtitle
                        ),
                        leading: const Icon(
                          Icons.music_note,
                          color:
                              Color(0xFF1A237E), // Match icon color with AppBar
                          size: 32,
                        ),
                        trailing: Obx(() {
                          return IconButton(
                            icon: Icon(
                              controller.isPlaying.value &&
                                      controller.songIndex.value == index
                                  ? Icons.pause
                                  : Icons.play_arrow,
                              color: Color(0xFF1A237E), // Match icon color
                              size: 26,
                            ),
                            onPressed: () async {
                              if (controller.isPlaying.value &&
                                  controller.songIndex.value == index) {
                                controller.pauseAudio();
                              } else {
                                if (controller.songIndex.value != index) {
                                  controller.songIndex.value =
                                      index; // Update song index
                                }
                                await controller.playAudioTwo(song, index);
                              }
                            },
                          );
                        }),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      }),
      // Uncomment if you have a custom navigation bar
      // bottomNavigationBar: CustomNavBarCurved(),
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
        backgroundColor:
            const Color(0xFF1A237E), // Darker background for the app bar
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
          tileColor: const Color.fromARGB(
              115, 228, 231, 231), // Background color for each item
          title: Text(
            song.split('/').last,
            style: const TextStyle(
              color: Colors.white70, // Text color
              fontSize: 16,
            ),
          ),
          leading: const Icon(Icons.music_note,
              color: Colors.white70), // Icon for songs
          onTap: () {
            close(context, song);
            controller.playAudio(song); // Play selected song
          },
          hoverColor: const Color.fromARGB(
              255, 105, 16, 98), // Highlight color on hover
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
              color: Color.fromARGB(
                  199, 241, 235, 235), // Darker color for suggestions
              fontSize: 16,
            ),
          ),
          leading: const Icon(Icons.music_note, color: Colors.black54),
          onTap: () {
            query = song.split('/').last;
            showResults(context);
          },
        );
      },
    );
  }
}
