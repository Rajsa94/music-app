import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';

class PlayerController extends GetxController {
  final AudioPlayer audioPlayer = AudioPlayer(); // Audio player instance
  var songs = <String>[].obs; // Observable list of song paths
  var isPlaying = false.obs; // Observable for play/pause toggle
  var currentSongIndex = 0.obs;
  var currentPosition =
      Duration.zero.obs; // Observable for the current position of the song
  var songDuration = Duration.zero.obs;
  var duration =
      Duration.zero.obs; // Observable for total duration of the audio
  var isLoading = true.obs;
  @override
  void onInit() {
    super.onInit();
    checkPermissions();
    audioPlayer.positionStream.listen((position) {
      currentPosition.value = position;
    });

    audioPlayer.durationStream.listen((duration) {
      this.duration.value = duration ?? Duration.zero;
      songDuration.value =
          duration ?? Duration.zero; // Ensuring song duration is updated
    });
  }

  // Request both audio and storage permissions
  Future<void> checkPermissions() async {
    // Check for audio permission and media-specific permissions
    var audioPermission = await Permission.audio.status;
    // var storagePermission = await Permission.storage.status;
    var audioMediaPermission = await Permission.audio.status; // For Android 13+

    // Request media-specific permission if needed (for Android 13+)
    if (audioMediaPermission.isDenied) {
      audioMediaPermission = await Permission.audio.request();
    }

    // Request storage permission if needed
    // if (storagePermission.isDenied) {
    //   storagePermission = await Permission.storage.request();
    // }

    // Log the permission statuses
    // print('Audio Permission: $audioPermission');
    // // print('Storage Permission: $storagePermission');
    // print('Media Audio Permission: $audioMediaPermission');

    // If all necessary permissions are granted, load the songs
    if (audioPermission.isGranted && audioMediaPermission.isGranted) {
      // print("All permissions granted, loading songs...");
      loadAllSongs();
    } else {
      Get.snackbar(
        'Permission Required',
        'Audio and storage permissions are needed to access songs.',
      );
    }
  }

  Future<bool> requestManageExternalStoragePermission() async {
    // Only for Android 11+
    if (await Permission.manageExternalStorage.isGranted) {
      return true;
    } else {
      return await Permission.manageExternalStorage.request().isGranted;
    }
  }

  // Load songs from the Music directory
  Future<void> loadAllSongs() async {
    isLoading.value = true;
    List<Directory> directories = [
      Directory('/storage/emulated/0/Download'),
      Directory('/storage/emulated/0/Music'),
    ];

    List<FileSystemEntity> allSongs = [];

    for (Directory dir in directories) {
      if (await dir.exists()) {
        try {
          List<FileSystemEntity> songs = await getAudioFiles(dir);
          allSongs.addAll(songs);
        } catch (e) {
          // print("Error accessing directory ${dir.path}: $e");
        }
      } else {
        // print("Directory ${dir.path} does not exist.");
      }
    }

    // print("Found ${allSongs.length} song(s)");

    // Clear the current songs and add the new ones to the observable list
    songs.clear(); // Clear existing songs
    songs.addAll(allSongs
        .map((file) => file.path)
        .toList()); // Add song paths to observable list

    // Log the songs after loading to verify
    // for (var song in allSongs) {
    //   print("Loaded song: ${song.path}"); // Log the song paths for verification
    // }

    // Log the updated songs list
    // print("Songs after loading: $songs");
    isLoading.value = false;
  }

  // Recursive function to fetch all audio files from directories
  Future<List<FileSystemEntity>> getAudioFiles(Directory dir) async {
    List<FileSystemEntity> allFiles = [];

    try {
      // Get all files and directories in the current directory
      List<FileSystemEntity> entities =
          dir.listSync(recursive: true, followLinks: false);

      for (FileSystemEntity entity in entities) {
        // If it's a file, check if it's an audio file
        if (entity is File) {
          String extension = entity.path.split('.').last.toLowerCase();
          if (['mp3', 'wav', 'aac', 'flac', 'm4a'].contains(extension)) {
            allFiles.add(entity); // Add to the list if it's an audio file
          }
        }
      }
    } catch (e) {
      // print("Error fetching audio files: $e");
    }

    return allFiles;
  }

  void stopAudio() async {
    await audioPlayer.stop(); // Stop the current audio
    isPlaying.value = false; // Update the isPlaying state
    currentPosition.value = Duration.zero; // Reset the current position
  }

  Future<void> refreshSongs() async {
    isLoading.value = true;
    // For example:
    // songs.clear(); // Clear the existing list if necessary
    await loadAllSongs(); // Method that loads songs into the list
    isLoading.value = false;
  }

  void seekTo(double seconds) {
    final newDuration = Duration(seconds: seconds.toInt());
    audioPlayer.seek(newDuration);
  }

  // Play selected song
  Future<void> playAudio(String songPath) async {
    try {
      await audioPlayer.setFilePath(songPath);
      await audioPlayer.play();
      isPlaying.value = true; // Update the play state to true
    } catch (e) {
      Get.snackbar('Error', 'Unable to play the song: $e');
    }
  }

  void togglePlayPause(String songPath) async {
    if (isPlaying.value) {
      await audioPlayer.pause(); // Pause the audio
      isPlaying.value = false; // Update the play state
    } else {
      await playAudio(songPath); // Play the audio
    }
  }

  // Pause audio
  void pauseAudio() async {
    await audioPlayer.pause();
    isPlaying.value = false;
  }

  // Seek forward (e.g., 10 seconds)
  void seekForward() {
    var newPosition = currentPosition.value + const Duration(seconds: 10);
    if (newPosition < songDuration.value) {
      audioPlayer.seek(newPosition);
    } else {
      audioPlayer.seek(songDuration.value);
    }
  }

  String formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  // Seek backward (e.g., 10 seconds)
  void seekBackward() {
    var newPosition = currentPosition.value - const Duration(seconds: 10);
    if (newPosition > Duration.zero) {
      audioPlayer.seek(newPosition);
    } else {
      audioPlayer.seek(Duration.zero);
    }
  }

  // Skip to the next song
  void skipNext() {
    if (currentSongIndex.value < songs.length - 1) {
      currentSongIndex.value++; // Increase the index to the next song
      playAudio(songs[currentSongIndex.value]); // Play the next song
    }
  }

  // Skip to the previous song
  void skipPrevious() {
    if (currentSongIndex.value > 0) {
      currentSongIndex.value--; // Decrease the index to the previous song
      playAudio(songs[currentSongIndex.value]); // Play the previous song
    }
  }

  @override
  void onClose() {
    audioPlayer.dispose();
    super.onClose();
  }
}
