import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../consts/colors.dart';
import '../controller/player_controler.dart'; // Adjusted controller import
import '../consts/text_style.dart'; // Adjust the import path
import './player.dart';
import '../loading//home_loading.dart';

class Home extends StatelessWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context) {
    var controller = Get.put(PlayerController());

    return Scaffold(
      backgroundColor: textColor,
      appBar: AppBar(
        title: Text(
          'Beats',
          style: ourStyle(size: 18),
        ),
        backgroundColor: const Color.fromARGB(224, 0, 0, 0),
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
                      if (controller.isPlaying.value) {
                        controller.stopAudio();
                      }

                      controller.playAudio(song);
                      Get.to(() => Player(song: song));
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
                                    controller.currentPosition.value == song
                                ? Icons.pause
                                : Icons.play_arrow,
                            color: bgColor,
                            size: 26,
                          ),
                          onPressed: () {
                            if (controller.isPlaying.value &&
                                controller.currentPosition.value == song) {
                              controller.pauseAudio();
                            } else {
                              controller.playAudio(song);
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
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = ''; // Clear search input
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
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
          title: Text(song.split('/').last), // Display song name only
          onTap: () {
            close(context, song);
            controller.playAudio(song); // Play selected song
          },
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
          title: Text(song.split('/').last), // Display song name only
          onTap: () {
            query = song.split('/').last;
            showResults(context);
          },
        );
      },
    );
  }
}
