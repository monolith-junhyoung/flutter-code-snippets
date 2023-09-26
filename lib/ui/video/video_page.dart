import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:video_player/video_player.dart';

class VideoPage extends StatefulWidget {
  const VideoPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return VideoPageState();
  }
}

class VideoPageState extends State<VideoPage> {
  late ChewieController _chewieController;

  @override
  void initState() {
    super.initState();

    // final vlcVideoPlayerController = VlcVideoPlayerController.network('https://media.w3.org/2010/05/sintel/trailer.mp4');
    final videoPlayerController = VideoPlayerController.network(
      'https://media.w3.org/2010/05/sintel/trailer.mp4',
      videoPlayerOptions: VideoPlayerOptions(mixWithOthers: false),
    );


    // final _chewieController = ChewieController(
    //     videoPlayerController: vlcVideoPlayerController,
    // );
    _chewieController = ChewieController(
      videoPlayerController: videoPlayerController,
    );
    videoPlayerController.initialize().then((value) => _chewieController.play());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Video'),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 255, 255, 0),
              ),
              child: Center(
                child: Chewie(
                  controller: _chewieController,
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // no need to run AudioSession
          // final isPlaying = _chewieController.videoPlayerController.value.isPlaying;
          // if (isPlaying) {
          //   AudioSession.instance.then((session) => session.setActive(false)).then((_) {
          //     setState(() {
          //       _chewieController.pause();
          //     });
          //   });
          // } else {
          //   AudioSession.instance
          //       .then((session) =>
          //           session.setActive(true, androidAudioFocusGainType: AndroidAudioFocusGainType.gainTransient))
          //       .then((value) {
          //     if (value) {
          //       setState(() {
          //         _chewieController.play();
          //       });
          //     }
          //   });
          // }
        },
        child: const Icon(Icons.movie),
      ),
    );
  }
}
