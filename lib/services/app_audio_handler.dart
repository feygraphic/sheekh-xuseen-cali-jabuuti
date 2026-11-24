import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:audio_service/audio_service.dart';
import 'package:audio_session/audio_session.dart';
import 'package:just_audio/just_audio.dart';

/// Central Background AudioHandler powering Android Media3 ExoPlayer & MediaSession.
///
/// Features:
/// - Background playback while app is minimized, closed, or screen is off.
/// - Native Android MediaStyle notification with scrubbable progress bar.
/// - Samsung One UI / Android lock-screen controls and media information.
/// - Dynamic metadata updates across Sheikh lectures, Quran, Adhkar, and Ramadan.
/// - Audio focus management (call interruptions, navigation ducking, headphone unplug).
/// - Synchronized Previous, Next, Rewind (-10s), Fast Forward (+10s), Seek, and Speed.
class AppAudioHandler extends BaseAudioHandler with SeekHandler {
  static AppAudioHandler? _instance;
  static AppAudioHandler? get instance => _instance;

  final AudioPlayer? _player;
  final bool isFallback;

  Future<void> Function()? onSkipToNextCallback;
  Future<void> Function()? onSkipToPreviousCallback;
  void Function()? onPlaybackCompletedCallback;

  StreamSubscription? _playerStateSubscription;
  StreamSubscription? _positionSubscription;
  StreamSubscription? _bufferedPositionSubscription;
  StreamSubscription? _durationSubscription;

  AppAudioHandler({AudioPlayer? player, this.isFallback = false})
      : _player = isFallback ? player : (player ?? AudioPlayer()) {
    _instance = this;
    if (!isFallback && _player != null) {
      _initAudioSession();
      _initPlayerStreams();
    }
  }

  AudioPlayer? get player => _player;

  Future<void> _initAudioSession() async {
    try {
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.music());

      // Audio focus interruptions (e.g. phone call, alarm, other media)
      session.interruptionEventStream.listen((event) {
        if (event.begin) {
          switch (event.type) {
            case AudioInterruptionType.duck:
              _player?.setVolume(0.3);
              break;
            case AudioInterruptionType.pause:
            case AudioInterruptionType.unknown:
              pause();
              break;
          }
        } else {
          switch (event.type) {
            case AudioInterruptionType.duck:
              _player?.setVolume(1.0);
              break;
            case AudioInterruptionType.pause:
              play();
              break;
            case AudioInterruptionType.unknown:
              break;
          }
        }
      });

      // Becoming noisy: auto-pause when headphones unplugged or Bluetooth disconnected
      session.becomingNoisyEventStream.listen((_) {
        pause();
      });
    } catch (e) {
      debugPrint('AppAudioHandler: AudioSession initialization error: $e');
    }
  }

  void _initPlayerStreams() {
    final p = _player;
    if (p == null) return;

    // 1. Player State (playing, buffering, completed)
    _playerStateSubscription = p.playerStateStream.listen((state) {
      _broadcastPlaybackState();
      if (state.processingState == ProcessingState.completed) {
        onPlaybackCompletedCallback?.call();
      }
    });

    // 2. Position
    _positionSubscription = p.positionStream.listen((pos) {
      _broadcastPlaybackState();
    });

    // 3. Buffered Position
    _bufferedPositionSubscription = p.bufferedPositionStream.listen((buf) {
      _broadcastPlaybackState();
    });

    // 4. Duration
    _durationSubscription = p.durationStream.listen((dur) {
      final currentItem = mediaItem.value;
      if (currentItem != null && dur != null) {
        mediaItem.add(currentItem.copyWith(duration: dur));
      }
      _broadcastPlaybackState();
    });
  }

  AudioProcessingState _transformProcessingState(ProcessingState state) {
    switch (state) {
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
    }
  }

  void _broadcastPlaybackState() {
    final player = _player;
    if (isFallback || player == null) return;

    final isPlaying = player.playing;
    final processingState = _transformProcessingState(player.processingState);

    // On startup, if no media has been selected/loaded and the player is idle,
    // do not force a premature foreground media notification into Android.
    if (mediaItem.value == null && !isPlaying && processingState == AudioProcessingState.idle) {
      return;
    }

    playbackState.add(
      PlaybackState(
        controls: [
          MediaControl.skipToPrevious,
          MediaControl.rewind,
          if (isPlaying) MediaControl.pause else MediaControl.play,
          MediaControl.fastForward,
          MediaControl.skipToNext,
        ],
        systemActions: const {
          MediaAction.seek,
          MediaAction.seekForward,
          MediaAction.seekBackward,
          MediaAction.skipToNext,
          MediaAction.skipToPrevious,
          MediaAction.playPause,
          MediaAction.play,
          MediaAction.pause,
          MediaAction.stop,
          MediaAction.fastForward,
          MediaAction.rewind,
          MediaAction.setSpeed,
        },
        androidCompactActionIndices: const [0, 2, 4], // Previous, Play/Pause, Next
        processingState: processingState,
        playing: isPlaying,
        updatePosition: player.position,
        bufferedPosition: player.bufferedPosition,
        speed: player.speed,
      ),
    );
  }

  /// Sets the active media item (updates notification, lock-screen, and Android Auto).
  @override
  Future<void> updateMediaItem(MediaItem item) async {
    mediaItem.add(item);
    _broadcastPlaybackState();
  }

  /// Loads an audio source with associated metadata.
  Future<void> loadSource(AudioSource source, {MediaItem? item}) async {
    if (item != null) {
      mediaItem.add(item);
    }
    if (!isFallback && _player != null) {
      await _player.setAudioSource(source);
    }
    _broadcastPlaybackState();
  }

  @override
  Future<void> play() async {
    if (!isFallback && _player != null) {
      await _player.play();
    }
    _broadcastPlaybackState();
  }

  @override
  Future<void> pause() async {
    if (!isFallback && _player != null) {
      await _player.pause();
    }
    _broadcastPlaybackState();
  }

  @override
  Future<void> stop() async {
    if (!isFallback && _player != null) {
      await _player.stop();
    }
    _broadcastPlaybackState();
  }

  @override
  Future<void> seek(Duration position) async {
    if (!isFallback && _player != null) {
      await _player.seek(position);
    }
    _broadcastPlaybackState();
  }

  @override
  Future<void> skipToNext() async {
    if (onSkipToNextCallback != null) {
      await onSkipToNextCallback!();
    }
  }

  @override
  Future<void> skipToPrevious() async {
    if (onSkipToPreviousCallback != null) {
      await onSkipToPreviousCallback!();
    }
  }

  @override
  Future<void> fastForward() async {
    final currentPos = _player?.position ?? Duration.zero;
    final maxDur = _player?.duration ?? currentPos + const Duration(seconds: 10);
    final target = currentPos + const Duration(seconds: 10);
    await seek(target > maxDur ? maxDur : target);
  }

  @override
  Future<void> rewind() async {
    final currentPos = _player?.position ?? Duration.zero;
    final target = currentPos - const Duration(seconds: 10);
    await seek(target < Duration.zero ? Duration.zero : target);
  }

  @override
  Future<void> setSpeed(double speed) async {
    if (!isFallback && _player != null) {
      await _player.setSpeed(speed);
    }
    _broadcastPlaybackState();
  }

  Future<void> setLoopMode(bool isRepeat) async {
    if (!isFallback && _player != null) {
      await _player.setLoopMode(isRepeat ? LoopMode.one : LoopMode.off);
    }
  }

  Future<void> disposeHandler() async {
    await _playerStateSubscription?.cancel();
    await _positionSubscription?.cancel();
    await _bufferedPositionSubscription?.cancel();
    await _durationSubscription?.cancel();
    await _player?.dispose();
  }
}
