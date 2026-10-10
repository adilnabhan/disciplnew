import 'dart:math' as math;
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

/// Helper for playing random celebratory audio effects when completing/finishing workouts.
class WorkoutSoundHelper {
  static AudioPlayer? _player;
  static final math.Random _random = math.Random();

  // Primary clean filenames in assets/Sounds/
  static const List<String> _soundAssets = [
    'Sounds/anime_wow.mp3',
    'Sounds/children_yay.mp3',
    'Sounds/faaah.mp3',
    'Sounds/meme.mp3',
    'Sounds/yt1s.mp3',
  ];

  // Original uploaded filenames fallback
  static const List<String> _fallbackSoundAssets = [
    'Sounds/anime-wow-sound-effect-mp3cut.mp3 (2).mpeg',
    'Sounds/children-yaysound-effect.mp3 (1).mpeg',
    'Sounds/faaah.mp3.mpeg',
    'Sounds/meme_lgkJmX6.mp3.mpeg',
    'Sounds/yt1s_wU4BGgD.mp3 (1).mpeg',
  ];

  static AudioPlayer get player {
    if (_player == null) {
      _player = AudioPlayer();
      _configurePlayer(_player!);
    }
    return _player!;
  }

  static Future<void> _configurePlayer(AudioPlayer p) async {
    try {
      await p.setAudioContext(
        AudioContext(
          iOS: AudioContextIOS(
            options: const {
              AVAudioSessionOptions.mixWithOthers,
            },
          ),
          android: const AudioContextAndroid(
            isSpeakerphoneOn: true,
            audioFocus: AndroidAudioFocus.gainTransientMayDuck,
          ),
        ),
      );
      await p.setReleaseMode(ReleaseMode.stop);
      await p.setVolume(1);
    } catch (e) {
      debugPrint('⚠️ [WorkoutSoundHelper] Error configuring player: $e');
    }
  }

  /// Plays a random finish sound from `assets/Sounds/`.
  static Future<void> playRandomFinishSound() async {
    try {
      final index = _random.nextInt(_soundAssets.length);
      final primarySound = _soundAssets[index];

      final p = player;
      await _configurePlayer(p);
      await p.stop();

      debugPrint('🔊 [WorkoutSoundHelper] Attempting to play: $primarySound');
      try {
        await p.play(AssetSource(primarySound));
        debugPrint('🔊 [WorkoutSoundHelper] Successfully started: $primarySound');
      } catch (innerErr) {
        debugPrint('⚠️ [WorkoutSoundHelper] Error with primary sound $primarySound: $innerErr');
        final fallbackSound = _fallbackSoundAssets[index];
        debugPrint('🔊 [WorkoutSoundHelper] Trying fallback: $fallbackSound');
        await p.play(AssetSource(fallbackSound));
      }
    } catch (e, stack) {
      debugPrint('❌ [WorkoutSoundHelper] Error playing workout finish sound: $e\n$stack');
    }
  }

  /// Disposes the underlying player resources.
  static Future<void> dispose() async {
    try {
      await _player?.dispose();
      _player = null;
    } catch (_) {}
  }
}
