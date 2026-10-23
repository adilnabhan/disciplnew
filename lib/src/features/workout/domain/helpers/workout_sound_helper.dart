import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';

/// Helper for playing celebratory audio effect when completing/finishing workouts.
class WorkoutSoundHelper {
  static AudioPlayer? _player;

  /// The finish sound asset file path relative to `assets/`.
  static const String _finishSoundAsset =
      'Sounds/discipl_finish_button_premium.wav';

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

  /// Plays the workout finish sound (`discipl_finish_button_premium.wav`).
  static Future<void> playFinishSound() async {
    try {
      final p = player;
      await _configurePlayer(p);
      await p.stop();

      debugPrint('🔊 [WorkoutSoundHelper] Attempting to play: $_finishSoundAsset');
      try {
        await p.play(AssetSource(_finishSoundAsset));
        debugPrint(
          '🔊 [WorkoutSoundHelper] Successfully started: $_finishSoundAsset',
        );
      } catch (innerErr) {
        debugPrint(
          '⚠️ [WorkoutSoundHelper] Error with primary asset path $_finishSoundAsset: $innerErr',
        );
        await p.play(AssetSource('assets/$_finishSoundAsset'));
      }
    } catch (e, stack) {
      debugPrint(
        '❌ [WorkoutSoundHelper] Error playing workout finish sound: $e\n$stack',
      );
    }
  }

  /// Plays the workout finish sound (kept for backward compatibility).
  static Future<void> playRandomFinishSound() => playFinishSound();

  /// Disposes the underlying player resources.
  static Future<void> dispose() async {
    try {
      await _player?.dispose();
      _player = null;
    } catch (_) {}
  }
}
