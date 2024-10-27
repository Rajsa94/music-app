import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
// import 'package:flutter_local_notifications/src/platform_specifics/android/bitmap.dart';
import '../handler/audio_player_handler.dart';

class PlayerController extends GetxController {
  // final AudioPlayerHandler audioHandler = AudioPlayerHandler();
  final AudioPlayerHandler audioHandler;
  PlayerController({required this.audioHandler});
  final AudioPlayer audioPlayer = AudioPlayer(); // Audio player instance
  var songs = <String>[].obs; // Observable list of song paths
  var isPlaying = false.obs; // Observable for play/pause toggle
  var currentSongIndex = 0.obs;
  var currentSongPath = ''.obs;
  var songIndex = 0.obs;
  var currentPosition =
      Duration.zero.obs; // Observable for the current position of the song
  var songDuration = Duration.zero.obs;
  // var songDuration = Rx<Duration>(Duration.zero);
  var duration =
      Duration.zero.obs; // Observable for total duration of the audio
  var isLoading = true.obs;
  static const String iconFont =
      'YourIconFontFamily'; // Replace with your actual font family name

  @override
  void onInit() {
    super.onInit();
    checkPermissions();

    currentPosition.bindStream(
      audioHandler.currentPosition.stream
          .map((position) => position ?? Duration.zero),
    );

    songDuration.bindStream(
      audioHandler.songDuration.stream
          .map((duration) => duration ?? Duration.zero),
    );
    // audioHandler.currentSongPathStream.listen((path) {
    //   currentSongPath.value = path;
    // });
    ever(songDuration, (Duration duration) {
      print("Updated song duration in PlayerController: $duration");
    });
  }

  Future<void> checkPermissions() async {
    // Check for audio permission (for Android 13+)
    var audioPermission = await Permission.audio.status;
    // Check for storage permission (for Android versions < 13)
    var storagePermission = await Permission.storage.status;

    // Request media-specific audio permission for Android 13+ if it's denied
    if (audioPermission.isDenied || audioPermission.isRestricted) {
      audioPermission = await Permission.audio.request();
    }
    //    var microphonePermission = await Permission.microphone.status;
    // if (microphonePermission.isDenied) {
    //   microphonePermission = await Permission.microphone.request();
    // }
    if (await Permission.notification.isGranted) {
      print("Notification permission is already granted.");
    } else {
      // Request permission if not granted
      final status = await Permission.notification.request();

      if (status.isGranted) {
        print("Notification permission granted.");
        // You can now show notifications
      } else if (status.isDenied) {
        print("Notification permission denied.");
        // Optionally, show an explanation or redirect to settings
      } else if (status.isPermanentlyDenied) {
        print("Notification permission permanently denied.");
        // Open app settings so the user can enable permissions manually
        openAppSettings();
      }
    }

    // Request storage permission if needed (for devices below Android 13)
    if (storagePermission.isDenied || storagePermission.isRestricted) {
      storagePermission = await Permission.storage.request();
    }

    // If both permissions are granted, load the songs
    if (audioPermission.isGranted || storagePermission.isGranted) {
      loadAllSongs();
    } else {
      // Show a snackbar if permissions are not granted
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

    songs.clear(); // Clear existing songs
    songs.addAll(allSongs
        .map((file) => file.path)
        .toList()); // Add song paths to observable list

    isLoading.value = false;
  }

  // Recursive function to fetch all audio files from directories
  Future<List<FileSystemEntity>> getAudioFiles(Directory dir) async {
    List<FileSystemEntity> allFiles = [];

    try {
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
    audioHandler.seek(newDuration);
  }

  // Play selected song
  Future<void> playAudio(String songPath) async {
    try {
      currentSongPath.value = songPath;
      await audioHandler.setAudioSource(songPath);
      // songDuration.value = audioHandler.songDuration ?? Duration.zero;
      isPlaying.value = true; // Update the play state to true
      await audioHandler.playAudio(songPath);
    } catch (e) {
      Get.snackbar('Error', 'Unable to play the song: $e');
    }
  }

  void togglePlayPause(String songPath) async {
    currentSongPath.value = songPath;
    print("Updated song duration in PlayerController: ${isPlaying.value}");
    if (isPlaying.value) {
      isPlaying.value = false;
      await audioHandler.pauseAudio();
    } else {
      isPlaying.value = true;
      await audioHandler.setAudioSource(songPath);
      await audioHandler.playAudio(songPath);
    }
  }

  Future<void> playAudioTwo(String songPath, int index) async {
    try {
      songIndex.value = index;
      isPlaying.value = true; // Update the play state to true
      currentSongPath.value = songPath;
      await audioHandler.setAudioSource(songPath);
      await audioHandler.playAudio(songPath);
      // songDuration.value = audioHandler.songDuration ?? Duration.zero;
    } catch (e) {
      Get.snackbar('Error', 'Unable to play the song: $e');
    }
  }

  // Pause audio
  void pauseAudio() async {
    isPlaying.value = false;
    await audioHandler.pauseAudio();
  }

  // Seek forward (e.g., 10 seconds)
  void seekForward() {
    var newPosition = currentPosition.value + const Duration(seconds: 10);
    if (newPosition < songDuration.value) {
      audioHandler.seek(newPosition);
    } else {
      audioHandler.seek(songDuration.value);
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
