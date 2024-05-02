import 'package:audio_video_progress_bar/audio_video_progress_bar.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:mobile_music_player_lyrics/models/music.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:spotify/spotify.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

import 'widgets/art_work_image.dart';

class MusicPlayer extends StatefulWidget {
  final int initialSongIndex;
  final List<Music> playlist;

  const MusicPlayer({
    Key? key,
    required this.initialSongIndex,
    required this.playlist,
  }) : super(key: key);

  @override
  State<MusicPlayer> createState() => _MusicPlayerState();
}

class _MusicPlayerState extends State<MusicPlayer> {
  final player = AudioPlayer();

  int currentSongIndex = 0;

  List<Music> playlist = [
    Music(trackId: '7MXVkk9YMctZqd1Srtv4MB'), // Add more songs here
    Music(trackId: '3WOiSsqfXPZAtGTr2PFj6S'),
    Music(trackId: '11dFghVXANMlKmJXsNCbNl'),
  ];

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

 @override
void initState() {
  currentSongIndex = widget.initialSongIndex;
  loadSong(widget.playlist[currentSongIndex]);
  super.initState();
}

  void loadSong(Music music) async {
    final credentials =
        SpotifyApiCredentials('e9eb2816d1944d4d82a595c4d0380b17', '405cb15f21a0431ca584f94a8de45e47');
    final spotify = SpotifyApi(credentials);
    spotify.tracks.get(music.trackId).then((track) async {
      String? tempSongName = track.name;
      if (tempSongName != null) {
        music.songName = tempSongName;
        music.artistName = track.artists?.first.name ?? "";
        String? image = track.album?.images?.first.url;
        if (image != null) {
          music.songImage = image;
          final tempSongColor = await getImagePalette(NetworkImage(image));
          if (tempSongColor != null) {
            music.songColor = tempSongColor;
          }
        }
        music.artistImage = track.artists?.first.images?.first.url;
        final yt = YoutubeExplode();
        final video = (await yt.search.search("$tempSongName ${music.artistName ?? ""}")).first;
        final videoId = video.id.value;
        music.duration = video.duration;
        setState(() {});
        var manifest = await yt.videos.streamsClient.getManifest(videoId);
        var audioUrl = manifest.audioOnly.last.url;
        player.play(UrlSource(audioUrl.toString()));
      }
    });
  }

  Future<Color?> getImagePalette(ImageProvider imageProvider) async {
    final PaletteGenerator paletteGenerator = await PaletteGenerator.fromImageProvider(imageProvider);
    return paletteGenerator.dominantColor?.color;
  }

  void switchSong(int index) {
    if (index >= 0 && index < playlist.length) {
      currentSongIndex = index;
      player.stop();
      loadSong(playlist[currentSongIndex]);
    } else {
      currentSongIndex = 0;
      player.stop();
      loadSong(playlist[currentSongIndex]);
    }
  }
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      backgroundColor: playlist[currentSongIndex].songColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 26),
          child: Column(
            children: [
              const SizedBox(height: 16),
              Expanded(
                flex: 2,
                child: Center(
                  child: ArtWorkImage(image: playlist[currentSongIndex].songImage),
                ),
              ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      playlist[currentSongIndex].songName ?? '',
                      style: textTheme.headline5?.copyWith(color: Colors.white),
                    ),
                    Text(
                      playlist[currentSongIndex].artistName ?? '-',
                      style: textTheme.subtitle1?.copyWith(color: Colors.white60),
                    ),
                    StreamBuilder(
                      stream: player.onPositionChanged,
                      builder: (context, data) {
                        return ProgressBar(
                          progress: data.data ?? const Duration(seconds: 0),
                          total: playlist[currentSongIndex].duration ?? const Duration(minutes: 4),
                          bufferedBarColor: Colors.white38,
                          baseBarColor: Colors.white10,
                          thumbColor: Colors.white,
                          timeLabelTextStyle: const TextStyle(color: Colors.white),
                          progressBarColor: Colors.white,
                          onSeek: (duration) {
                            player.seek(duration);
                          },
                        );
                      },
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          onPressed: () {
                            switchSong(currentSongIndex - 1);
                          },
                          icon: const Icon(Icons.skip_previous, color: Colors.white, size: 36),
                        ),
                        IconButton(
                          onPressed: () {
                            if (player.state == PlayerState.playing) {
                              player.pause();
                            } else {
                              player.resume();
                            }
                            setState(() {});
                          },
                          icon: Icon(
                            player.state == PlayerState.playing ? Icons.pause : Icons.play_circle,
                            color: Colors.white,
                            size: 60,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            switchSong(currentSongIndex + 1);
                          },
                          icon: const Icon(Icons.skip_next, color: Colors.white, size: 36),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: playlist.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text(playlist[index].songName ?? ''),
                      subtitle: Text(playlist[index].artistName ?? ''),
                      onTap: () {
                        switchSong(index);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
