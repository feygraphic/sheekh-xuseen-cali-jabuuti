import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:audio_service/audio_service.dart';
import 'package:just_audio/just_audio.dart';
import 'package:permission_handler/permission_handler.dart';

import '../models/lecture_model.dart';
import '../models/surah_model.dart';
import '../models/adkhar_model.dart';
import '../models/reciter_model.dart';
import '../models/audio_category.dart';
import '../models/ramadan_lecture.dart';
import '../data/sample_data.dart';
import '../data/quran_data.dart';
import '../data/adhkar_data.dart';
import '../data/ramadan_data.dart';
import '../services/storage_service.dart';
import '../services/quran_audio_service.dart';
import '../services/app_audio_handler.dart';
import '../services/artwork_cache_service.dart';

enum PlayerState {
  stopped,
  playing,
  paused,
  completed,
}

class AudioPlayerProvider extends ChangeNotifier {
  final StorageService _storage;
  final AppAudioHandler _audioHandler;
  late final QuranAudioService _quranAudioService;

  LectureModel? _currentLecture;
  SurahModel? _currentSurah;
  AdkharModel? _currentAdhkar;
  RamadanLecture? _currentRamadanLecture;
  RamadanScholar? _currentRamadanScholar;

  // Quran Online Streaming State
  SurahModel? _currentQuranSurah;
  ReciterModel? _currentReciter;
  bool _isQuranStreaming = false;
  bool _autoPlayNextSurah = true;
  String? _errorMessage;

  PlayerState _playerState = PlayerState.stopped;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  double _playbackSpeed = 1.0;
  bool _isShuffle = false;
  bool _isRepeat = false;
  bool _isMiniPlayerVisible = true;
  bool _isLoading = false;

  Timer? _sleepTimer;
  int? _sleepTimerRemainingMinutes;

  List<LectureModel> _playlist = [];
  List<AdkharModel> _adhkarPlaylist = [];
  List<RamadanLecture> _ramadanPlaylist = [];
  int _currentIndex = 0;

  AudioPlayerProvider(this._storage, {AppAudioHandler? audioHandler})
      : _audioHandler = audioHandler ?? AppAudioHandler.instance ?? AppAudioHandler(isFallback: true) {
    _quranAudioService = QuranAudioService(_storage);
    _initAudio();
  }

  // Getters
  AudioPlayer? get player => _audioHandler.player;
  AppAudioHandler get audioHandler => _audioHandler;

  AudioCategory get currentCategory {
    if (_currentAdhkar != null) return AudioCategory.adhkar;
    if ((_isQuranStreaming && _currentQuranSurah != null) || _currentSurah != null) {
      return AudioCategory.quran;
    }
    if (_currentRamadanLecture != null) return AudioCategory.ramadan;
    return AudioCategory.lecture;
  }

  PlayerState get playerState => _playerState;
  bool get isPlaying => _playerState == PlayerState.playing;
  bool get isPaused => _playerState == PlayerState.paused;
  bool get isLoading => _isLoading;
  Duration get position => _position;
  Duration get duration => _duration;
  double get playbackSpeed => _playbackSpeed;
  bool get isShuffle => _isShuffle;
  bool get isRepeat => _isRepeat;
  bool get isMiniPlayerVisible =>
      _isMiniPlayerVisible &&
      (_currentLecture != null ||
          _currentSurah != null ||
          _currentAdhkar != null ||
          _currentRamadanLecture != null ||
          (_isQuranStreaming && _currentQuranSurah != null));
  int? get sleepTimerRemainingMinutes => _sleepTimerRemainingMinutes;

  LectureModel? get currentLecture => _currentLecture;
  SurahModel? get currentSurah => _currentSurah;
  AdkharModel? get currentAdhkar => _currentAdhkar;
  RamadanLecture? get currentRamadanLecture => _currentRamadanLecture;
  RamadanScholar? get currentRamadanScholar => _currentRamadanScholar;
  SurahModel? get currentQuranSurah => _currentQuranSurah;
  ReciterModel get currentReciter => _currentReciter ?? ReciterModel.defaultReciter;
  List<ReciterModel> get availableReciters => _quranAudioService.cachedReciters;
  bool get isQuranStreaming => _isQuranStreaming;
  bool get autoPlayNextSurah => _autoPlayNextSurah;
  String? get errorMessage => _errorMessage;
  List<LectureModel> get playlist => _playlist;
  List<AdkharModel> get adhkarPlaylist => _adhkarPlaylist;
  List<RamadanLecture> get ramadanPlaylist => _ramadanPlaylist;

  bool isAdhkarPlaying(String id) => isPlaying && _currentAdhkar?.id == id;

  bool isSurahStreaming(int surahNumber) =>
      isPlaying && _isQuranStreaming && _currentQuranSurah?.number == surahNumber;

  bool isSurahBuffering(int surahNumber) =>
      _isLoading && _isQuranStreaming && _currentQuranSurah?.number == surahNumber;

  String get currentTitle {
    switch (currentCategory) {
      case AudioCategory.adhkar:
        return _currentAdhkar?.title ?? 'Duco & Adkaar';
      case AudioCategory.quran:
        if (_isQuranStreaming && _currentQuranSurah != null) {
          return 'Suurada ${_currentQuranSurah!.somaliName}';
        }
        if (_currentSurah != null) {
          return 'Suurada ${_currentSurah!.somaliName}';
        }
        return 'Qur\'aanka Kariimka';
      case AudioCategory.ramadan:
        return _currentRamadanLecture?.displayTitle ?? 'Muxaadaro Ramadaan';
      case AudioCategory.lecture:
        return _currentLecture?.somaliTitle ?? 'Sharaxa Riyaadu Saalixiina';
    }
  }

  String get currentSubtitle {
    switch (currentCategory) {
      case AudioCategory.adhkar:
        if (_currentAdhkar != null) {
          return '${_currentAdhkar!.category} • ${_currentAdhkar!.reference}';
        }
        return 'Xuska Alle & Ducooyinka';
      case AudioCategory.quran:
        if (_isQuranStreaming && _currentQuranSurah != null) {
          return '${_currentQuranSurah!.arabicName} • ${currentReciter.nameAr}';
        }
        if (_currentSurah != null) {
          return '${_currentSurah!.arabicName} • ${_currentSurah!.audioTafsiirTitle}';
        }
        return 'Qur\'aanka Kariimka';
      case AudioCategory.ramadan:
        if (_currentRamadanScholar != null) {
          return '${_currentRamadanScholar!.name} • ${_currentRamadanScholar!.arabicTitle}';
        }
        return 'Taxanaha Ramadaanka';
      case AudioCategory.lecture:
        if (_currentLecture != null) {
          return '${_currentLecture!.arabicTitle} • ${_currentLecture!.seriesName}';
        }
        return 'شرح رياض الصالحين • Dersi 24';
    }
  }

  String get currentImage {
    switch (currentCategory) {
      case AudioCategory.adhkar:
        return 'assets/images/adhkar_artwork.png';
      case AudioCategory.quran:
        if (_isQuranStreaming) return currentReciter.displayImage;
        return 'assets/images/quran_artwork.jpg';
      case AudioCategory.ramadan:
        return _currentRamadanScholar?.imageAsset ?? 'assets/images/sheikh_player.jpg';
      case AudioCategory.lecture:
        return _currentLecture?.imageUrl ?? 'assets/images/sheikh_player.jpg';
    }
  }

  double get progressFraction {
    if (_duration.inMilliseconds > 0) {
      return (_position.inMilliseconds / _duration.inMilliseconds).clamp(0.0, 1.0);
    }
    return 0.0;
  }

  void _initAudio() {
    _currentLecture = SampleData.lectures.isNotEmpty ? SampleData.lectures.first : SampleData.track01Lecture;
    _playlist = List.from(SampleData.lectures);
    _position = Duration.zero;
    _duration = _currentLecture?.duration ?? const Duration(minutes: 45);

    _playbackSpeed = _storage.getPlaybackSpeed();
    _autoPlayNextSurah = _storage.getAutoPlayNextSurah();
    _currentReciter = _quranAudioService.getReciterById(_storage.getSelectedReciterId());

    // Connect notification and lock-screen hardware callbacks to provider
    _audioHandler.onSkipToNextCallback = () async => await playNext();
    _audioHandler.onSkipToPreviousCallback = () async => await playPrevious();
    _audioHandler.onPlaybackCompletedCallback = _onTrackCompleted;

    // Fetch dynamic reciters in background
    _quranAudioService.fetchReciters().then((_) {
      notifyListeners();
    });

    // Synchronize player state from the underlying audio handler / ExoPlayer
    final p = _audioHandler.player;
    if (!_audioHandler.isFallback && p != null) {
      p.playerStateStream.listen((state) {
        if (state.playing) {
          _playerState = PlayerState.playing;
        } else if (state.processingState == ProcessingState.completed) {
          _playerState = PlayerState.completed;
        } else if (state.processingState == ProcessingState.idle) {
          _playerState = PlayerState.stopped;
        } else {
          _playerState = PlayerState.paused;
        }
        _isLoading = state.processingState == ProcessingState.buffering ||
            state.processingState == ProcessingState.loading;
        notifyListeners();
      });

      p.positionStream.listen((pos) {
        _position = pos;
        notifyListeners();
      });

      p.durationStream.listen((dur) {
        if (dur != null && dur > Duration.zero) {
          _duration = dur;
          notifyListeners();
        }
      });
    }
  }

  Future<void> _ensureNotificationPermission() async {
    if (kIsWeb) return;
    try {
      if (defaultTargetPlatform == TargetPlatform.android) {
        final status = await Permission.notification.status;
        if (status.isDenied) {
          await Permission.notification.request();
        }
      }
    } catch (e) {
      debugPrint('Notification permission check: $e');
    }
  }

  Future<MediaItem> _buildMediaItem({
    required String id,
    required String title,
    required String artist,
    required String album,
    required String? artworkPath,
    Duration? duration,
  }) async {
    final artUri = await ArtworkCacheService.getArtUri(artworkPath);
    return MediaItem(
      id: id,
      title: title,
      artist: artist,
      album: album,
      duration: duration ?? _duration,
      artUri: artUri,
      extras: {
        'category': currentCategory.name,
      },
    );
  }

  void _onTrackCompleted() {
    if (_isRepeat) {
      seekTo(Duration.zero);
      resume();
    } else if (currentCategory == AudioCategory.quran) {
      if (_autoPlayNextSurah) {
        playNextSurah();
      } else {
        _playerState = PlayerState.completed;
        notifyListeners();
      }
    } else if (currentCategory == AudioCategory.adhkar) {
      playNextAdhkar();
    } else if (currentCategory == AudioCategory.ramadan) {
      playNextRamadan();
    } else {
      playNext();
    }
  }

  // 1. Quran Full-Surah Online Streaming from MP3Quran API
  Future<void> playQuranSurah(SurahModel surah, {ReciterModel? reciter}) async {
    await _ensureNotificationPermission();

    if (_isQuranStreaming &&
        _currentQuranSurah?.number == surah.number &&
        (reciter == null || reciter.id == currentReciter.id)) {
      await togglePlayPause();
      return;
    }

    if (reciter != null) {
      _currentReciter = reciter;
      await _storage.setSelectedReciterId(reciter.id);
    } else {
      _currentReciter ??= _quranAudioService.getReciterById(_storage.getSelectedReciterId());
    }

    _isQuranStreaming = true;
    _currentQuranSurah = surah;
    _currentLecture = null;
    _currentSurah = null;
    _currentAdhkar = null;
    _currentRamadanLecture = null;
    _currentRamadanScholar = null;
    _errorMessage = null;
    _isMiniPlayerVisible = true;
    _isLoading = true;
    _position = Duration.zero;
    notifyListeners();

    await _storage.setLastPlayedSurah(surah.number);

    final rawUrl = currentReciter.getSurahAudioUrl(surah.number);
    String streamUrl = rawUrl;
    if (kIsWeb && streamUrl.startsWith('http')) {
      streamUrl = '/audio-proxy?url=${Uri.encodeComponent(streamUrl)}';
    }

    try {
      final mediaItem = await _buildMediaItem(
        id: 'quran_${surah.number}',
        title: 'Suurada ${surah.somaliName}',
        artist: currentReciter.nameAr,
        album: 'Qur\'aanka Kariimka • ${surah.arabicName}',
        artworkPath: currentReciter.displayImage,
        duration: _duration,
      );

      await _audioHandler.stop();
      final source = AudioSource.uri(Uri.parse(streamUrl), tag: mediaItem);
      await _audioHandler.loadSource(source, item: mediaItem);
      await _audioHandler.play();
      await _audioHandler.setSpeed(_playbackSpeed);
      _playerState = PlayerState.playing;
    } catch (e) {
      _errorMessage = 'Codka suuradda lama heli karo ama xiriirka internet-ka ayaa xadidan.';
      debugPrint('Error streaming Quran audio: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> playNextSurah() async {
    if (_currentQuranSurah == null) return;
    final all = QuranData.allSurahs;
    final currentIdx = all.indexWhere((s) => s.number == _currentQuranSurah!.number);
    if (currentIdx != -1) {
      final nextIdx = (currentIdx + 1) % all.length;
      await playQuranSurah(all[nextIdx]);
    }
  }

  Future<void> playPreviousSurah() async {
    if (_currentQuranSurah == null) return;
    final all = QuranData.allSurahs;
    final currentIdx = all.indexWhere((s) => s.number == _currentQuranSurah!.number);
    if (currentIdx != -1) {
      final prevIdx = (currentIdx - 1 + all.length) % all.length;
      await playQuranSurah(all[prevIdx]);
    }
  }

  Future<void> setReciter(ReciterModel reciter) async {
    _currentReciter = reciter;
    await _storage.setSelectedReciterId(reciter.id);
    notifyListeners();

    if (_isQuranStreaming && _currentQuranSurah != null && isPlaying) {
      await playQuranSurah(_currentQuranSurah!, reciter: reciter);
    }
  }

  void setAutoPlayNextSurah(bool value) {
    _autoPlayNextSurah = value;
    _storage.setAutoPlayNextSurah(value);
    notifyListeners();
  }

  // 2. Sheikh Xuseen Cali Jabuuti Lectures Playback
  Future<void> playLecture(LectureModel lecture, {List<LectureModel>? playlist}) async {
    await _ensureNotificationPermission();

    _isQuranStreaming = false;
    _currentQuranSurah = null;
    _currentLecture = lecture;
    _currentSurah = null;
    _currentAdhkar = null;
    _currentRamadanLecture = null;
    _currentRamadanScholar = null;
    _isMiniPlayerVisible = true;
    _isLoading = true;
    _position = Duration.zero;
    _duration = lecture.duration;

    if (playlist != null && playlist.isNotEmpty) {
      _playlist = List.from(playlist);
    } else if (_playlist.isEmpty || _playlist.length < SampleData.lectures.length) {
      _playlist = List.from(SampleData.lectures);
    }
    final foundIdx = _playlist.indexWhere((l) => l.id == lecture.id);
    if (foundIdx != -1) {
      _currentIndex = foundIdx;
    }

    notifyListeners();

    await _storage.addRecentlyPlayed(lecture.id);

    try {
      final mediaItem = await _buildMediaItem(
        id: lecture.id,
        title: lecture.somaliTitle,
        artist: 'Sheekh Xuseen Cali Jabuuti',
        album: '${lecture.arabicTitle} • ${lecture.seriesName}',
        artworkPath: lecture.imageUrl.isNotEmpty ? lecture.imageUrl : 'assets/images/sheikh_player.jpg',
        duration: lecture.duration,
      );

      await _audioHandler.stop();
      AudioSource source;
      if (lecture.isLocalAsset) {
        final cleanPath = lecture.audioUrl.startsWith('assets/')
            ? lecture.audioUrl
            : 'assets/${lecture.audioUrl}';
        source = AudioSource.asset(cleanPath, tag: mediaItem);
      } else {
        String streamUrl = lecture.audioUrl;
        if (kIsWeb && streamUrl.startsWith('http')) {
          streamUrl = '/audio-proxy?url=${Uri.encodeComponent(streamUrl)}';
        }
        source = AudioSource.uri(Uri.parse(streamUrl), tag: mediaItem);
      }

      await _audioHandler.loadSource(source, item: mediaItem);
      await _audioHandler.play();
      await _audioHandler.setSpeed(_playbackSpeed);
      _playerState = PlayerState.playing;
    } catch (e) {
      debugPrint('Error playing lecture audio: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 3. Surah Audio Tafsiir (Sheekh Xuseen)
  Future<void> playSurahTafsiir(SurahModel surah) async {
    await _ensureNotificationPermission();

    _isQuranStreaming = false;
    _currentQuranSurah = null;
    _currentSurah = surah;
    _currentLecture = null;
    _currentAdhkar = null;
    _currentRamadanLecture = null;
    _currentRamadanScholar = null;
    _isMiniPlayerVisible = true;
    _isLoading = true;
    notifyListeners();

    try {
      final mediaItem = await _buildMediaItem(
        id: 'tafsiir_${surah.number}',
        title: 'Suurada ${surah.somaliName}',
        artist: 'Sheekh Xuseen Cali Jabuuti',
        album: '${surah.arabicName} • ${surah.audioTafsiirTitle}',
        artworkPath: 'assets/images/quran_artwork.jpg',
        duration: _duration,
      );

      await _audioHandler.stop();
      AudioSource source;
      if (surah.isLocalAsset) {
        final cleanPath = surah.audioUrl.startsWith('assets/')
            ? surah.audioUrl
            : 'assets/${surah.audioUrl}';
        source = AudioSource.asset(cleanPath, tag: mediaItem);
      } else {
        String streamUrl = surah.audioUrl;
        if (kIsWeb && streamUrl.startsWith('http')) {
          streamUrl = '/audio-proxy?url=${Uri.encodeComponent(streamUrl)}';
        }
        source = AudioSource.uri(Uri.parse(streamUrl), tag: mediaItem);
      }

      await _audioHandler.loadSource(source, item: mediaItem);
      await _audioHandler.play();
      await _audioHandler.setSpeed(_playbackSpeed);
      _playerState = PlayerState.playing;
    } catch (e) {
      debugPrint('Error playing surah audio: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 4. Adhkar Audio Playback
  Future<void> playAdhkar(AdkharModel adhkar, {List<AdkharModel>? playlist}) async {
    await _ensureNotificationPermission();

    if (playlist != null && playlist.isNotEmpty) {
      _adhkarPlaylist = List.from(playlist);
    } else if (_adhkarPlaylist.isEmpty) {
      _adhkarPlaylist = List.from(AdhkarData.allAdhkar);
    }

    if (isPlaying && _currentAdhkar?.id == adhkar.id) {
      await pause();
      return;
    }

    _isQuranStreaming = false;
    _currentQuranSurah = null;
    _currentAdhkar = adhkar;
    _currentLecture = null;
    _currentSurah = null;
    _currentRamadanLecture = null;
    _currentRamadanScholar = null;
    _isMiniPlayerVisible = true;
    _isLoading = true;
    _position = Duration.zero;
    notifyListeners();

    try {
      final mediaItem = await _buildMediaItem(
        id: adhkar.id,
        title: adhkar.title,
        artist: 'Xuska Alle & Ducooyinka',
        album: '${adhkar.category} • ${adhkar.reference}',
        artworkPath: 'assets/images/adhkar_artwork.png',
        duration: _duration,
      );

      await _audioHandler.stop();
      AudioSource source;
      if (adhkar.isLocalAudio && adhkar.audioUrl != null && adhkar.audioUrl!.isNotEmpty) {
        final cleanPath = adhkar.audioUrl!.startsWith('assets/')
            ? adhkar.audioUrl!
            : 'assets/${adhkar.audioUrl!}';
        source = AudioSource.asset(cleanPath, tag: mediaItem);
      } else if (adhkar.audioUrl != null && adhkar.audioUrl!.isNotEmpty) {
        String streamUrl = adhkar.audioUrl!;
        if (kIsWeb && streamUrl.startsWith('http')) {
          streamUrl = '/audio-proxy?url=${Uri.encodeComponent(streamUrl)}';
        }
        source = AudioSource.uri(Uri.parse(streamUrl), tag: mediaItem);
      } else {
        source = AudioSource.asset('assets/audio/sample_dhikr.mp3', tag: mediaItem);
      }

      await _audioHandler.loadSource(source, item: mediaItem);
      await _audioHandler.play();
      await _audioHandler.setSpeed(_playbackSpeed);
      _playerState = PlayerState.playing;
    } catch (e) {
      debugPrint('Error playing adhkar audio: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 5. Ramadan Audio Playback
  Future<void> playRamadanLecture(
    RamadanLecture lecture, {
    RamadanScholar? scholar,
    List<RamadanLecture>? playlist,
  }) async {
    await _ensureNotificationPermission();

    final effectiveScholar = scholar ?? _currentRamadanScholar ?? RamadanData.scholars.first;
    _isQuranStreaming = false;
    _currentQuranSurah = null;
    _currentRamadanLecture = lecture;
    _currentRamadanScholar = effectiveScholar;
    _currentLecture = null;
    _currentSurah = null;
    _currentAdhkar = null;
    _isMiniPlayerVisible = true;
    _isLoading = true;
    _position = Duration.zero;

    if (playlist != null && playlist.isNotEmpty) {
      _ramadanPlaylist = List.from(playlist);
    } else {
      _ramadanPlaylist = RamadanData.getLecturesByScholar(effectiveScholar.id);
    }

    notifyListeners();

    try {
      final mediaItem = await _buildMediaItem(
        id: lecture.id,
        title: lecture.displayTitle,
        artist: effectiveScholar.name,
        album: '${effectiveScholar.arabicTitle} • Taxanaha Ramadaanka',
        artworkPath: effectiveScholar.imageAsset,
        duration: _duration,
      );

      await _audioHandler.stop();
      final source = AudioSource.asset('assets/audio/sample_dhikr.mp3', tag: mediaItem);
      await _audioHandler.loadSource(source, item: mediaItem);
      await _audioHandler.play();
      await _audioHandler.setSpeed(_playbackSpeed);
      _playerState = PlayerState.playing;
    } catch (e) {
      debugPrint('Error playing ramadan audio: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> pause() async {
    await _audioHandler.pause();
    _playerState = PlayerState.paused;
    notifyListeners();
  }

  Future<void> resume() async {
    if (_playerState == PlayerState.paused) {
      await _audioHandler.play();
      _playerState = PlayerState.playing;
    } else {
      switch (currentCategory) {
        case AudioCategory.adhkar:
          if (_currentAdhkar != null) await playAdhkar(_currentAdhkar!);
          break;
        case AudioCategory.quran:
          if (_isQuranStreaming && _currentQuranSurah != null) {
            await playQuranSurah(_currentQuranSurah!);
          } else if (_currentSurah != null) {
            await playSurahTafsiir(_currentSurah!);
          }
          break;
        case AudioCategory.ramadan:
          if (_currentRamadanLecture != null) {
            await playRamadanLecture(_currentRamadanLecture!, scholar: _currentRamadanScholar);
          }
          break;
        case AudioCategory.lecture:
          if (_currentLecture != null) {
            await playLecture(_currentLecture!);
          }
          break;
      }
    }
    notifyListeners();
  }

  Future<void> togglePlayPause() async {
    if (isPlaying) {
      await pause();
    } else {
      await resume();
    }
  }

  Future<void> stop() async {
    await _audioHandler.stop();
    _playerState = PlayerState.stopped;
    _position = Duration.zero;
    notifyListeners();
  }

  Future<void> seekTo(Duration targetPosition) async {
    await _audioHandler.seek(targetPosition);
    _position = targetPosition;
    notifyListeners();
  }

  Future<void> skipForward(int seconds) async {
    final newPos = _position + Duration(seconds: seconds);
    if (newPos < _duration) {
      await seekTo(newPos);
    } else {
      await seekTo(_duration);
    }
  }

  Future<void> skipBackward(int seconds) async {
    final newPos = _position - Duration(seconds: seconds);
    if (newPos > Duration.zero) {
      await seekTo(newPos);
    } else {
      await seekTo(Duration.zero);
    }
  }

  Future<void> setPlaybackSpeed(double speed) async {
    _playbackSpeed = speed;
    await _audioHandler.setSpeed(speed);
    await _storage.setPlaybackSpeed(speed);
    notifyListeners();
  }

  Future<void> setSpeed(double speed) => setPlaybackSpeed(speed);

  void toggleSpeed() {
    const speeds = [0.75, 1.0, 1.25, 1.5, 2.0];
    int nextIdx = (speeds.indexOf(_playbackSpeed) + 1) % speeds.length;
    if (nextIdx < 0) nextIdx = 1;
    setPlaybackSpeed(speeds[nextIdx]);
  }

  void toggleShuffle() {
    _isShuffle = !_isShuffle;
    notifyListeners();
  }

  void toggleRepeat() {
    _isRepeat = !_isRepeat;
    _audioHandler.setLoopMode(_isRepeat);
    notifyListeners();
  }

  void hideMiniPlayer() {
    _isMiniPlayerVisible = false;
    notifyListeners();
  }

  void showMiniPlayer() {
    _isMiniPlayerVisible = true;
    notifyListeners();
  }

  Future<void> playNext() async {
    switch (currentCategory) {
      case AudioCategory.quran:
        await playNextSurah();
        break;
      case AudioCategory.adhkar:
        await playNextAdhkar();
        break;
      case AudioCategory.ramadan:
        await playNextRamadan();
        break;
      case AudioCategory.lecture:
        if (_playlist.isEmpty) return;
        if (_isShuffle) {
          _currentIndex = (_currentIndex + 2) % _playlist.length;
        } else {
          _currentIndex = (_currentIndex + 1) % _playlist.length;
        }
        await playLecture(_playlist[_currentIndex], playlist: _playlist);
        break;
    }
  }

  Future<void> playPrevious() async {
    switch (currentCategory) {
      case AudioCategory.quran:
        await playPreviousSurah();
        break;
      case AudioCategory.adhkar:
        await playPreviousAdhkar();
        break;
      case AudioCategory.ramadan:
        await playPreviousRamadan();
        break;
      case AudioCategory.lecture:
        if (_playlist.isEmpty) return;
        _currentIndex = (_currentIndex - 1 + _playlist.length) % _playlist.length;
        await playLecture(_playlist[_currentIndex], playlist: _playlist);
        break;
    }
  }

  Future<void> playNextAdhkar() async {
    if (_currentAdhkar == null) return;
    if (_adhkarPlaylist.isEmpty) {
      _adhkarPlaylist = List.from(AdhkarData.allAdhkar);
    }
    final idx = _adhkarPlaylist.indexWhere((a) => a.id == _currentAdhkar!.id);
    if (idx != -1 && idx < _adhkarPlaylist.length - 1) {
      await playAdhkar(_adhkarPlaylist[idx + 1], playlist: _adhkarPlaylist);
    } else {
      _playerState = PlayerState.completed;
      notifyListeners();
    }
  }

  Future<void> playPreviousAdhkar() async {
    if (_currentAdhkar == null) return;
    if (_adhkarPlaylist.isEmpty) {
      _adhkarPlaylist = List.from(AdhkarData.allAdhkar);
    }
    final idx = _adhkarPlaylist.indexWhere((a) => a.id == _currentAdhkar!.id);
    if (idx > 0) {
      await playAdhkar(_adhkarPlaylist[idx - 1], playlist: _adhkarPlaylist);
    }
  }

  Future<void> playNextRamadan() async {
    if (_currentRamadanLecture == null || _ramadanPlaylist.isEmpty) return;
    final idx = _ramadanPlaylist.indexWhere((l) => l.id == _currentRamadanLecture!.id);
    if (idx != -1 && idx < _ramadanPlaylist.length - 1) {
      await playRamadanLecture(
        _ramadanPlaylist[idx + 1],
        scholar: _currentRamadanScholar,
        playlist: _ramadanPlaylist,
      );
    } else {
      _playerState = PlayerState.completed;
      notifyListeners();
    }
  }

  Future<void> playPreviousRamadan() async {
    if (_currentRamadanLecture == null || _ramadanPlaylist.isEmpty) return;
    final idx = _ramadanPlaylist.indexWhere((l) => l.id == _currentRamadanLecture!.id);
    if (idx > 0) {
      await playRamadanLecture(
        _ramadanPlaylist[idx - 1],
        scholar: _currentRamadanScholar,
        playlist: _ramadanPlaylist,
      );
    }
  }

  // Sleep Timer
  void setSleepTimer(int minutes) {
    _sleepTimer?.cancel();
    if (minutes <= 0) {
      _sleepTimerRemainingMinutes = null;
      notifyListeners();
      return;
    }

    _sleepTimerRemainingMinutes = minutes;
    notifyListeners();

    _sleepTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      if (_sleepTimerRemainingMinutes != null && _sleepTimerRemainingMinutes! > 1) {
        _sleepTimerRemainingMinutes = _sleepTimerRemainingMinutes! - 1;
        notifyListeners();
      } else {
        _sleepTimer?.cancel();
        _sleepTimerRemainingMinutes = null;
        pause();
        notifyListeners();
      }
    });
  }

  void cancelSleepTimer() {
    _sleepTimer?.cancel();
    _sleepTimerRemainingMinutes = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _sleepTimer?.cancel();
    _audioHandler.disposeHandler();
    super.dispose();
  }
}
