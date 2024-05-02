import 'package:flutter/material.dart';
import 'package:mobile_music_player_lyrics/models/music.dart';
import 'package:mobile_music_player_lyrics/views/music_player.dart';

class MyHomePage extends StatelessWidget {
  final List<Music> playlist;

  const MyHomePage({Key? key, required this.playlist}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Music Playlist'),
      ),
      body: ListView.builder(
        itemCount: playlist.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(playlist[index].songName ?? ''),
            subtitle: Text(playlist[index].artistName ?? ''),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MusicPlayer(
                    song: playlist[index],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}