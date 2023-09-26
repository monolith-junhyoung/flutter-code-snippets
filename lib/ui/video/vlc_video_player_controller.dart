import 'package:flutter/cupertino.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:video_player/video_player.dart';

/// VideoPlayerController를 인터페이스로 사용하고 내부적으로 VlcPlayerController 사용하는 video controller
class VlcVideoPlayerController extends VideoPlayerController {
  late VlcPlayerController _controller;

  VlcPlayerController get controller => _controller;

  VlcVideoPlayerController.network(
      String dataSource, {
        bool autoInitialize = true,
        HwAcc hwAcc = HwAcc.auto,
        bool autoPlay = true,
        VlcPlayerOptions? options,
      }) : super.network(dataSource) {
    _controller = VlcPlayerController.network(
      super.dataSource,
      autoInitialize: autoInitialize,
      hwAcc: hwAcc,
      autoPlay: autoPlay,
      options: options,
    );
  }

  @override
  set value(VideoPlayerValue newValue) {
    // TODO: implement value
    super.value = newValue;
  }

  @override
  Future<Duration> get position => _controller.getPosition();

  @override
  Future<void> initialize() => _controller.initialize();

  /// do not call suerp class as we rely on the current implementation which is vlc player.
  @override
  // ignore: must_call_super
  Future<void> dispose() => _controller.dispose();

  @override
  Future<void> play() => _controller.play();

  @override
  Future<void> setLooping(bool looping) => _controller.setLooping(looping);

  @override
  Future<void> pause() => _controller.pause();

  @override
  Future<void> seekTo(Duration position) => _controller.seekTo(position);

  /// Sets the audio volume of [this].
  ///
  /// [volume] indicates a value between 0.0 (silent) and 1.0 (full volume) on a
  /// linear scale.
  /// this will internally convert the range from 0 to 100.
  @override
  Future<void> setVolume(double volume) => _controller.setVolume((volume * 100).toInt());

  @override
  Future<void> setPlaybackSpeed(double speed) => _controller.setPlaybackSpeed(speed);

  @override
  void setCaptionOffset(Duration offset) {
    // TODO: implement setCaptionOffset
    super.setCaptionOffset(offset);
  }

  @override
  VideoPlayerValue get value => throw UnsupportedError(
      'VideoPlayerValue is not available as it uses VlcPlayerValue internally. use controller.value instead.');

  @override
  bool get hasListeners => _controller.hasListeners;

  @override
  void addListener(VoidCallback listener) => _controller.addListener(listener);

  @override
  void removeListener(VoidCallback listener) => _controller.removeListener(listener);

  @override
  void notifyListeners() => _controller.notifyListeners();

  @override
  String toString() => _controller.toString();

  bool get isInitialized => _controller.value.isInitialized;
}
