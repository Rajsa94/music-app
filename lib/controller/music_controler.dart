import 'package:get/get.dart';
import '../controller/music_fatch.dart';
import '../models/music_model.dart';

class MusicController extends GetxController {
  final MusicService musicService = Get.put(MusicService());
  var musicList = <Music>[].obs;
  var isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadMusic();
  }

  void loadMusic() async {
    isLoading.value = true;
    try {
      musicList.value = await musicService.fetchMusic();
    } catch (e) {
      Get.snackbar('Error', 'Failed to load music: $e',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  void playMusic(String url) {
    // Implement your music playback logic here
    // For example, using an audio player package:
    // audioPlayer.setUrl(url);
    // audioPlayer.play();
    Get.snackbar('Playing', 'Now playing music from: $url');
  }
}
