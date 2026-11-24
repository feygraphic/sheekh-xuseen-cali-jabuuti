import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:audio_service/audio_service.dart';
import 'package:sheekh_xuseen_cali_jabuuti/services/app_audio_handler.dart';
import 'package:sheekh_xuseen_cali_jabuuti/services/artwork_cache_service.dart';
import 'package:sheekh_xuseen_cali_jabuuti/services/storage_service.dart';
import 'package:sheekh_xuseen_cali_jabuuti/providers/audio_player_provider.dart';
import 'package:sheekh_xuseen_cali_jabuuti/data/sample_data.dart';
import 'package:sheekh_xuseen_cali_jabuuti/data/quran_data.dart';
import 'package:sheekh_xuseen_cali_jabuuti/data/adhkar_data.dart';
import 'package:sheekh_xuseen_cali_jabuuti/data/ramadan_data.dart';
import 'package:sheekh_xuseen_cali_jabuuti/models/audio_category.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Background Audio Playback & MediaSession Tests', () {
    late StorageService storage;
    late AppAudioHandler audioHandler;
    late AudioPlayerProvider provider;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      StorageService.resetForTesting();
      storage = await StorageService.getInstance();
      audioHandler = AppAudioHandler(isFallback: true);
      provider = AudioPlayerProvider(storage, audioHandler: audioHandler);
    });

    test('ArtworkCacheService handles remote and local URLs safely', () async {
      final remoteUri = await ArtworkCacheService.getArtUri('https://example.com/art.jpg');
      expect(remoteUri, isNotNull);
      expect(remoteUri.toString(), 'https://example.com/art.jpg');

      final nullUri = await ArtworkCacheService.getArtUri(null);
      expect(nullUri, isNull);

      final emptyUri = await ArtworkCacheService.getArtUri('');
      expect(emptyUri, isNull);
    });

    test('AppAudioHandler initializes and dispatches MediaItem and PlaybackState', () async {
      const testItem = MediaItem(
        id: 'test_track',
        title: 'Dacwada iyo Tabliiqa',
        artist: 'Sheekh Xuseen Cali Jabuuti',
        album: 'Muxaadarooyin Qaybta 1aad',
        duration: Duration(minutes: 45),
      );

      await audioHandler.updateMediaItem(testItem);
      expect(audioHandler.mediaItem.value?.id, 'test_track');
      expect(audioHandler.mediaItem.value?.artist, 'Sheekh Xuseen Cali Jabuuti');
    });

    test('Lecture audio dynamically updates MediaItem with Sheikh Xuseen branding', () async {
      final lecture = SampleData.lectures.first;
      await provider.playLecture(lecture);

      expect(provider.currentCategory, AudioCategory.lecture);
      expect(provider.currentTitle, lecture.somaliTitle);
      expect(provider.currentSubtitle, contains(lecture.arabicTitle));
      expect(provider.isPlaying, isTrue);
    });

    test('Quran audio dynamically updates MediaItem with Reciter and Surah details', () async {
      final surah = QuranData.allSurahs.first;
      await provider.playQuranSurah(surah);

      expect(provider.currentCategory, AudioCategory.quran);
      expect(provider.currentTitle, 'Suurada ${surah.somaliName}');
      expect(provider.currentSubtitle, contains(surah.arabicName));
      expect(provider.isPlaying, isTrue);
    });

    test('Adhkar audio dynamically updates MediaItem with Dua title and Islamic artwork', () async {
      final adhkar = AdhkarData.allAdhkar.first;
      await provider.playAdhkar(adhkar);

      expect(provider.currentCategory, AudioCategory.adhkar);
      expect(provider.currentTitle, adhkar.title);
      expect(provider.currentSubtitle, contains(adhkar.category));
      expect(provider.currentImage, 'assets/images/adhkar_artwork.png');
      expect(provider.isPlaying, isTrue);
    });

    test('Ramadan audio dynamically updates MediaItem with Scholar name and series title', () async {
      final scholar = RamadanData.scholars.first;
      final lectures = RamadanData.getLecturesByScholar(scholar.id);
      final lecture = lectures.first;

      await provider.playRamadanLecture(lecture, scholar: scholar);

      expect(provider.currentCategory, AudioCategory.ramadan);
      expect(provider.currentTitle, lecture.displayTitle);
      expect(provider.currentSubtitle, contains(scholar.name));
      expect(provider.isPlaying, isTrue);
    });

    test('Notification Next and Previous controls dispatch to category-aware playlist navigation', () async {
      // 1. Setup lecture playlist with known tracks
      final playlist = [SampleData.track01Lecture, SampleData.track02Lecture];
      await provider.playLecture(playlist[0], playlist: playlist);
      expect(provider.currentLecture?.id, playlist[0].id);

      // Trigger SkipToNext from Android MediaSession / Lock screen
      await audioHandler.skipToNext();
      expect(provider.currentLecture?.id, playlist[1].id);

      // Trigger SkipToPrevious from Android MediaSession / Lock screen
      await audioHandler.skipToPrevious();
      expect(provider.currentLecture?.id, playlist[0].id);
    });

    test('Seeking and speed remain synchronized across lock-screen and in-app state', () async {
      final lecture = SampleData.lectures.first;
      await provider.playLecture(lecture);

      await provider.seekTo(const Duration(minutes: 5, seconds: 30));
      expect(provider.position, const Duration(minutes: 5, seconds: 30));

      await provider.setPlaybackSpeed(1.5);
      expect(provider.playbackSpeed, 1.5);

      await provider.pause();
      expect(provider.isPaused, isTrue);
      expect(provider.isPlaying, isFalse);

      await provider.resume();
      expect(provider.isPlaying, isTrue);
    });
  });
}
