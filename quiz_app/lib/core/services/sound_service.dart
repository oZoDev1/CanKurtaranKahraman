import 'package:audioplayers/audioplayers.dart';

/// Doğru ve yanlış cevap seslerini yöneten singleton servis.
class SoundService {
  SoundService._();
  static final SoundService instance = SoundService._();

  final AudioPlayer _correctPlayer = AudioPlayer();
  final AudioPlayer _wrongPlayer = AudioPlayer();

  bool _initialized = false;

  /// Ses dosyalarını önceden hazırla. Uygulama başlangıcında çağrılmalı.
  Future<void> init() async {
    if (_initialized) return;

    // Ses kaynağını ayarla — audioplayers AssetSource Flutter assets klasörünü kullanır
    await _correctPlayer.setSource(AssetSource('sounds/Correct.mp3'));
    await _wrongPlayer.setSource(AssetSource('sounds/Wrong.mp3'));

    // Release modunu ayarla: çalma bittikten sonra tekrar çalmaya hazır olsun
    await _correctPlayer.setReleaseMode(ReleaseMode.stop);
    await _wrongPlayer.setReleaseMode(ReleaseMode.stop);

    _initialized = true;
  }

  /// Doğru cevap sesini çal.
  Future<void> playCorrect() async {
    await _correctPlayer.stop();
    await _correctPlayer.play(AssetSource('sounds/Correct.mp3'));
  }

  /// Yanlış cevap sesini çal.
  Future<void> playWrong() async {
    await _wrongPlayer.stop();
    await _wrongPlayer.play(AssetSource('sounds/Wrong.mp3'));
  }

  /// Kaynakları serbest bırak.
  Future<void> dispose() async {
    await _correctPlayer.dispose();
    await _wrongPlayer.dispose();
  }
}
