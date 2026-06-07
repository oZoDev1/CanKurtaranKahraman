import 'package:audioplayers/audioplayers.dart';

/// Doğru ve yanlış cevap seslerini yöneten singleton servis.
class SoundService {
  SoundService._();
  static final SoundService instance = SoundService._();

  final AudioPlayer _correctPlayer = AudioPlayer();
  final AudioPlayer _wrongPlayer = AudioPlayer();
  final AudioPlayer _buttonClickPlayer = AudioPlayer();
  final AudioPlayer _transitionPlayer = AudioPlayer();
  final AudioPlayer _barFillingPlayer = AudioPlayer();
  final AudioPlayer _backgroundPlayer = AudioPlayer();

  bool _initialized = false;
  bool _isStartingBackground = false;

  /// Ses dosyalarını önceden hazırla. Uygulama başlangıcında çağrılmalı.
  Future<void> init() async {
    if (_initialized) return;

    // Ses kaynağını ayarla — audioplayers AssetSource Flutter assets klasörünü kullanır
    await _correctPlayer.setSource(AssetSource('sounds/Correct.mp3'));
    await _wrongPlayer.setSource(AssetSource('sounds/Wrong.mp3'));
    await _buttonClickPlayer.setSource(AssetSource('sounds/buttonClick.mp3'));
    await _transitionPlayer.setSource(AssetSource('sounds/ModullerArasiGecis.mp3'));
    await _barFillingPlayer.setSource(AssetSource('sounds/BarDoldurmaSesi.mp3'));
    await _backgroundPlayer.setSource(AssetSource('sounds/BackgroundLoop.mp3'));

    // Release modunu ayarla: çalma bittikten sonra tekrar çalmaya hazır olsun
    await _correctPlayer.setReleaseMode(ReleaseMode.stop);
    await _wrongPlayer.setReleaseMode(ReleaseMode.stop);
    await _buttonClickPlayer.setReleaseMode(ReleaseMode.stop);
    await _transitionPlayer.setReleaseMode(ReleaseMode.stop);
    await _barFillingPlayer.setReleaseMode(ReleaseMode.stop);
    await _backgroundPlayer.setReleaseMode(ReleaseMode.loop);

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

  /// Modüller arası geçiş sesini çal.
  Future<void> playTransition() async {
    await _transitionPlayer.stop();
    await _transitionPlayer.play(AssetSource('sounds/ModullerArasiGecis.mp3'));
  }

  /// Bar doldurma sesini çal.
  Future<void> playBarFilling() async {
    await _barFillingPlayer.stop();
    await _barFillingPlayer.play(AssetSource('sounds/BarDoldurmaSesi.mp3'));
  }

  /// Arka plan müzik döngüsünü başlat veya kaldığı yerden devam ettir.
  Future<void> playBackground({bool force = false}) async {
    if (!_initialized) return;
    if (!force && _backgroundPlayer.state == PlayerState.playing) return;
    if (_isStartingBackground) return;

    _isStartingBackground = true;
    try {
      if (_backgroundPlayer.state == PlayerState.paused || _backgroundPlayer.state == PlayerState.playing) {
        await _backgroundPlayer.resume();
      } else {
        await _backgroundPlayer.play(AssetSource('sounds/BackgroundLoop.mp3'));
      }
    } catch (e) {
      try {
        await _backgroundPlayer.play(AssetSource('sounds/BackgroundLoop.mp3'));
      } catch (_) {}
    } finally {
      _isStartingBackground = false;
    }
  }

  /// Arka plan müzik döngüsünü duraklat.
  Future<void> pauseBackground() async {
    await _backgroundPlayer.pause();
  }

  /// Kaynakları serbest bırak.
  Future<void> dispose() async {
    await _correctPlayer.dispose();
    await _wrongPlayer.dispose();
    await _buttonClickPlayer.dispose();
    await _transitionPlayer.dispose();
    await _barFillingPlayer.dispose();
    await _backgroundPlayer.dispose();
  }
}
