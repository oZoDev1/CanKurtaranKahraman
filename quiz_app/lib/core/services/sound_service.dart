import 'package:audioplayers/audioplayers.dart';

/// Doğru ve yanlış cevap seslerini yöneten singleton servis.
class SoundService {
  SoundService._();
  static final SoundService instance = SoundService._();

  final AudioPlayer _correctPlayer = AudioPlayer();
  final AudioPlayer _wrongPlayer = AudioPlayer();
  final AudioPlayer _buttonClickPlayer = AudioPlayer();

  bool _initialized = false;

  /// Ses dosyalarını önceden hazırla. Uygulama başlangıcında çağrılmalı.
  Future<void> init() async {
    if (_initialized) return;

    // Ses kaynağını ayarla — audioplayers AssetSource Flutter assets klasörünü kullanır
    await _correctPlayer.setSource(AssetSource('sounds/Correct.mp3'));
    await _wrongPlayer.setSource(AssetSource('sounds/Wrong.mp3'));
    await _buttonClickPlayer.setSource(AssetSource('sounds/buttonClick.mp3'));

    // Release modunu ayarla: çalma bittikten sonra tekrar çalmaya hazır olsun
    await _correctPlayer.setReleaseMode(ReleaseMode.stop);
    await _wrongPlayer.setReleaseMode(ReleaseMode.stop);
    await _buttonClickPlayer.setReleaseMode(ReleaseMode.stop);

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

  /// Buton tıklama sesini çal.
  Future<void> playButtonClick() async {
    await _buttonClickPlayer.stop();
    await _buttonClickPlayer.play(AssetSource('sounds/buttonClick.mp3'));
  }

  /// Kaynakları serbest bırak.
  Future<void> dispose() async {
    await _correctPlayer.dispose();
    await _wrongPlayer.dispose();
    await _buttonClickPlayer.dispose();
  }
}
