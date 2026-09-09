import 'package:flutter/services.dart';
import 'package:vibration/vibration.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:masbhty/core/services/storage_service.dart';

class AudioService {
  final StorageService _storageService;
  final AudioPlayer _player = AudioPlayer();

  AudioService(this._storageService);

  Future<void> playClick() async {
    if (!_storageService.isSoundEnabled()) return;

    try {
      // First attempt to play system tap sound (ultra-fast, natively cached, zero assets needed)
      await SystemSound.play(SystemSoundType.click);
    } catch (_) {
      // Fallback to custom audio asset if system fails
      try {
        await _player.play(AssetSource('sounds/click.mp3'), volume: 0.8);
      } catch (_) {
        // Safe silent fail
      }
    }
  }

  Future<void> playSuccess() async {
    if (!_storageService.isSoundEnabled()) return;

    try {
      // Distinct beep/alert when target reached
      await SystemSound.play(SystemSoundType.alert);
    } catch (_) {
      try {
        await _player.play(AssetSource('sounds/success.mp3'), volume: 1.0);
      } catch (_) {
        // Safe silent fail
      }
    }
  }

  Future<void> vibrateTap() async {
    if (!_storageService.isVibrationEnabled()) return;

    try {
      final hasVibrator = await Vibration.hasVibrator();
      if (hasVibrator == true) {
        // Short subtle tap
        await Vibration.vibrate(duration: 35, amplitude: 128);
      } else {
        HapticFeedback.lightImpact();
      }
    } catch (_) {
      try {
        HapticFeedback.lightImpact();
      } catch (_) {}
    }
  }

  Future<void> vibrateTargetReached() async {
    if (!_storageService.isVibrationEnabled()) return;

    try {
      final hasVibrator = await Vibration.hasVibrator();
      if (hasVibrator == true) {
        // Triple distinct pulses on completing a loop / target
        await Vibration.vibrate(pattern: [0, 150, 100, 150, 100, 300]);
      } else {
        HapticFeedback.heavyImpact();
        await Future.delayed(const Duration(milliseconds: 150));
        HapticFeedback.heavyImpact();
      }
    } catch (_) {
      try {
        HapticFeedback.heavyImpact();
      } catch (_) {}
    }
  }

  void dispose() {
    _player.dispose();
  }
}
