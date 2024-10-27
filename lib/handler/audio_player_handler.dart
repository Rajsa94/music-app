import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:get/get.dart';
// import '../controller//player_controler.dart';

class AudioPlayerHandler extends BaseAudioHandler with SeekHandler {
  // var controller = Get.put(PlayerController(audioHandler: audioHandler));
  final AudioPlayer _player = AudioPlayer();
  Rx<Duration?> currentPosition =
      Rx<Duration?>(Duration.zero); // Nullable Rx for current position
  Rx<Duration?> songDuration = Rx<Duration?>(Duration.zero);
  Rx<String?> currentSongPath = Rx<String?>(null);
  bool isPlaying = false;
  Duration? lastPausedPosition;

  AudioPlayerHandler() {
    _player.playerStateStream.listen((playerState) {
      final playing = playerState.playing;
      isPlaying = playing;
      // print("Player is ${playing ? "playing" : "paused"}"); // Debug print
      playbackState.add(playbackState.value.copyWith(
        controls: [
          MediaControl.skipToPrevious,
          playing ? MediaControl.pause : MediaControl.play,
          MediaControl.stop,
          MediaControl.skipToNext,
        ],
        playing: playing,
        processingState: _mapProcessingState(playerState.processingState),
      ));
    });
    _player.positionStream.listen((position) {
      currentPosition.value = position;
    });
    _player.durationStream.listen((duration) {
      songDuration.value = duration ?? Duration.zero;
      print("Duration updated: ${songDuration.value}");
    });
  }

  void _updatePlaybackState() {
    playbackState.add(playbackState.value.copyWith(
      controls: [
        MediaControl.skipToPrevious,
        isPlaying ? MediaControl.pause : MediaControl.play,
        MediaControl.stop,
        MediaControl.skipToNext,
      ],
      playing: isPlaying,
      processingState: _mapProcessingState(_player.processingState),
      // updateTime: DateTime.now().millisecondsSinceEpoch,
      // position: _player.position,
    ));
  }

  AudioProcessingState _mapProcessingState(ProcessingState processingState) {
    switch (processingState) {
      case ProcessingState.idle:
        return AudioProcessingState.idle;
      case ProcessingState.loading:
        return AudioProcessingState.loading;
      case ProcessingState.buffering:
        return AudioProcessingState.buffering;
      case ProcessingState.ready:
        return AudioProcessingState.ready;
      case ProcessingState.completed:
        return AudioProcessingState.completed;
      default:
        return AudioProcessingState.idle;
    }
  }

  Future<void> stop() async {
    await _player.stop();
    playbackState.add(playbackState.value.copyWith(playing: false));
  }

  @override
  Future<void> play() async {
    await _player.play();
    isPlaying = true;
    _updatePlaybackState();
  }

  @override
  Future<void> pause() async {
    await _player.pause();
    isPlaying = false;
    _updatePlaybackState();
  }

  @override
  Future<void> skipToNext() async {
    // constrcontroller.songs
    await _player.seekToNext();
  }

  @override
  Future<void> skipToPrevious() async {
    await _player.seekToPrevious();
  }

  @override
  // Future<void> skipToPrevious() => _player.seekToPrevious();
  @override
  Future<void> playAudio(String songPath) async {
    try {
      if (currentSongPath.value != songPath) {
        // If switching to a new song, reset position and update the song path
        await _player.seek(Duration.zero);
        currentSongPath.value = songPath;
        await _player.setFilePath(songPath);
        await _player.play();
        isPlaying = true;
      } else {
        await _player.seek(lastPausedPosition);
        await _player.play();
        isPlaying = true;
      }
    } catch (e) {
      print("Error playing audio: $e");
      Get.snackbar('Error', 'Unable to play the song: $e');
    }
  }

  Future<void> pauseAudio() async {
    lastPausedPosition = currentPosition.value;
    isPlaying = false;
    await _player.pause();
  }

  Future<void> setAudioSource(String filePath) async {
    try {
      await _player.setFilePath(filePath);
      print("Audio source set to $filePath");
    } catch (e) {
      print("Error setting audio source: $e");
    }
  }

  Future<void> seek(Duration position) async {
    await _player.seek(position);
    print("Seeked to position: $position"); // Debug print
  }
}
