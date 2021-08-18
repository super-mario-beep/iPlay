


import 'package:just_audio/just_audio.dart';
import 'package:newpipeextractor_dart/models/infoItems/video.dart';
import 'package:newpipeextractor_dart/models/video.dart';
import 'package:video_player/video_player.dart';

class AudioStreamPlayer {

  static AudioPlayer player;
  static bool isPlaying = false;
  static String _urlStream;
  static VideoPlayerController videoPlayerController;
  static bool isVideoPlaying = false;
  static bool isAudioPlayer = true;

  static String getUrlStream(){
    return _urlStream;
  }
  static void setUrlStream(YoutubeVideo video){
    _urlStream = video.audioWithHighestQuality.url;
    player.setUrl(video.audioWithHighestQuality.url).then((value) => {}).catchError((error){
      print(error);
      print("On 403 error AudioStreamPlayer");
      video.toStreamInfoItem().getVideo.then((value) => {
        setUrlStream(value),
      });
    });
  }

  static void play(){
    isPlaying = true;
    player.play();
  }

  static void restart(){
    stop();
    player.setUrl(_urlStream);
    play();
  }

  static void pause(){
    isPlaying = false;
    player.pause();
  }

  static void stop(){
    isPlaying = false;
    player.stop();
  }
  
  static void seekTo(Duration time){
    player.seek(time);
  }

  static void seekTimeSeconds(int seekTime){
    if(seekTime == -10){
      if(player.position.inSeconds <= 10){
        seekTo(Duration(seconds: 0));
      }else{
        seekTo(player.position - Duration(seconds: 10));
      }
    }else if(seekTime == 10){
      if((player.position + Duration(seconds: 10)) >= player.duration){
        seekTo(player.duration);
      }else{
        seekTo(player.position + Duration(seconds: 10));
      }
    }
  }



}