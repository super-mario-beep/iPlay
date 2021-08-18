import 'package:flutter/material.dart';

class PlayPauseButton extends StatelessWidget {
  final bool isBuffering;
  final bool isPlaying;
  final Function onPlayPause;
  final bool isRepeat;
  final Function onRepeat;

  PlayPauseButton({
    @required this.isBuffering,
    @required this.isPlaying,
    @required this.onPlayPause,
    @required this.isRepeat,
    @required this.onRepeat,
  });

  @override
  Widget build(BuildContext context) {
    if (isRepeat) {
      return GestureDetector(
        onTap: onRepeat,
        child: Icon(
          Icons.refresh,
          size: 42,
          color: Colors.white,
        ),
      );
    }
    return GestureDetector(
      onTap: onPlayPause,
      child: isBuffering
          ? CircularProgressIndicator(
              value: null,
              valueColor: AlwaysStoppedAnimation(Colors.white),
            )
          : isPlaying
              ? Icon(
                  Icons.pause,
                  size: 42,
                  color: Colors.white,
                )
              : Icon(
                  Icons.play_arrow,
                  size: 42,
                  color: Colors.white,
                ),
    );
  }
}
