import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'By Микола Пилипчук'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late AudioPlayer _audioPlayer; //!
  Duration current = Duration.zero;
  Duration buffered = Duration.zero;
  Duration total = Duration.zero;
  String buttonState = '';
  late ConcatenatingAudioSource playlist;

  @override
  void initState() {
    super.initState();
    playlist = ConcatenatingAudioSource(
      //!
      useLazyPreparation: true,
      shuffleOrder: DefaultShuffleOrder(),
      children: [
        AudioSource.asset('audios/song1.mp3'),
        AudioSource.asset('audios/song2.mp3'),
        AudioSource.asset('audios/song4.mp3'),
        AudioSource.asset('audios/song5.mp3'),
        AudioSource.asset('audios/song6.mp3'),
        AudioSource.asset('audios/song7.mp3'),
      ],
    );
    _audioPlayer = AudioPlayer() //!
      ..setAudioSource(playlist,
          initialIndex: 0, initialPosition: Duration.zero);
    _audioPlayer.setLoopMode(LoopMode.all);

    _audioPlayer.positionStream.listen((position) {
      setState(() {
        current = position;
      });
    });

    _audioPlayer.bufferedPositionStream.listen((bufferedPosition) {
      setState(() {
        buffered = bufferedPosition;
      });
    });

    _audioPlayer.durationStream.listen((totalDuration) {
      setState(() {
        total = totalDuration ?? Duration.zero; //!
      });

      _audioPlayer.playerStateStream.listen((playerState) {
        final isPlaying = playerState.playing;
        final processingState = playerState.processingState;
        if (processingState == ProcessingState.loading ||
            processingState == ProcessingState.buffering) {
          buttonState = 'loading';
        } else if (!isPlaying) {
          buttonState = 'paused';
        } else {
          buttonState = 'playing';
        }
      });
    });
  }

  void seek(Duration position) {
    _audioPlayer.seek(position);
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: ProgressBar(
                  progress: current,
                  buffered: buffered,
                  total: total,
                  onSeek: seek)),
          Container(
            margin: const EdgeInsets.only(bottom: 40),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                    onPressed: () {
                      _audioPlayer.seek(Duration(
                          seconds: minus5(_audioPlayer.position.inSeconds)));
                    },
                    child: const Text('-5s')),
                IconButton(
                  onPressed: () => {_audioPlayer.seekToNext()},
                  icon: const Icon(Icons.skip_previous),
                  iconSize: 30,
                  color: Colors.lightBlue[800],
                ),
                playButton(context),
                IconButton(
                  onPressed: () => {_audioPlayer.seekToPrevious()}, //!
                  icon: const Icon(Icons.skip_next),
                  iconSize: 30,
                  color: Colors.lightBlue[800],
                ),
                ElevatedButton(
                    onPressed: () {
                      _audioPlayer.seek(Duration(
                          seconds: add5(_audioPlayer.position.inSeconds)));
                    },
                    child: const Text('+5s'))
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget playButton(BuildContext context) {
    if (buttonState == 'playing') {
      return IconButton(
        onPressed: () {
          _audioPlayer.pause();
        },
        icon: const Icon(Icons.pause),
        iconSize: 30,
        color: Colors.lightBlue[800],
      );
    } else if (buttonState == 'loading') {
      return Container(
        padding: const EdgeInsets.all(5.0),
        margin: const EdgeInsets.all(8),
        height: 30,
        width: 30,
        child: const CircularProgressIndicator(),
      );
    }

    return IconButton(
      onPressed: () {
        _audioPlayer.play();
      },
      icon: const Icon(Icons.play_arrow),
      iconSize: 30,
      color: Colors.lightBlue[800],
    );
  }
}

Function makeAdder(int addBy) {
  //!
  return (int i) => addBy + i;
}

var add5 = makeAdder(5);
var minus5 = makeAdder(-5);
