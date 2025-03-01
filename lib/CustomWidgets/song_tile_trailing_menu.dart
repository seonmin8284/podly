/*
 *  This file is part of BlackHole (https://github.com/Sangwan5688/BlackHole).
 * 
 * BlackHole is free software: you can redistribute it and/or modify
 * it under the terms of the GNU Lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * BlackHole is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with BlackHole.  If not, see <http://www.gnu.org/licenses/>.
 * 
 * Copyright (c) 2021-2022, Wali Ullah Shuvo
 */

import 'package:audio_service/audio_service.dart';
import 'package:podly/CustomWidgets/add_playlist.dart';
import 'package:podly/Helpers/add_mediaitem_to_queue.dart';
import 'package:podly/Helpers/mediaitem_converter.dart';
import 'package:podly/Screens/Common/song_list.dart';
import 'package:podly/Screens/Search/albums.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// import 'package:share_plus/share_plus.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class SongTileTrailingMenu extends StatefulWidget {
  final Map data;
  final bool isPlaylist;
  final Function(Map)? deleteLiked;
  const SongTileTrailingMenu({
    super.key,
    required this.data,
    this.isPlaylist = false,
    this.deleteLiked,
  });

  @override
  _SongTileTrailingMenuState createState() => _SongTileTrailingMenuState();
}

class _SongTileTrailingMenuState extends State<SongTileTrailingMenu> {
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      icon: Icon(
        Icons.more_vert_rounded,
        color: Theme.of(context).iconTheme.color,
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(15.0),
        ),
      ),
      itemBuilder: (context) => [
        if (widget.isPlaylist)
          const PopupMenuItem(
            value: 6,
            child: Row(
              children: [
                Icon(
                  Icons.delete_rounded,
                ),
                SizedBox(
                  width: 10.0,
                ),
                Text(
                  'remove',
                ),
              ],
            ),
          ),
        PopupMenuItem(
          value: 2,
          child: Row(
            children: [
              Icon(
                Icons.queue_music_rounded,
                color: Theme.of(context).iconTheme.color,
              ),
              const SizedBox(width: 10.0),
              const Text('playNext'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 1,
          child: Row(
            children: [
              Icon(
                Icons.playlist_add_rounded,
                color: Theme.of(context).iconTheme.color,
              ),
              const SizedBox(width: 10.0),
              const Text('addToQueue'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 0,
          child: Row(
            children: [
              Icon(
                Icons.playlist_add_rounded,
                color: Theme.of(context).iconTheme.color,
              ),
              const SizedBox(width: 10.0),
              const Text('addToPlaylist'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 4,
          child: Row(
            children: [
              Icon(
                Icons.album_rounded,
                color: Theme.of(context).iconTheme.color,
              ),
              const SizedBox(width: 10.0),
              const Text('viewAlbum'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 5,
          child: Row(
            children: [
              Icon(
                Icons.person_rounded,
                color: Theme.of(context).iconTheme.color,
              ),
              const SizedBox(width: 10.0),
              const Text('viewArtist'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 3,
          child: Row(
            children: [
              Icon(
                Icons.share_rounded,
                color: Theme.of(context).iconTheme.color,
              ),
              const SizedBox(width: 10.0),
              const Text('share'),
            ],
          ),
        ),
      ],
      onSelected: (int? value) {
        final MediaItem mediaItem =
            MediaItemConverter.mapToMediaItem(widget.data);
        if (value == 3) {
          // Share.share(widget.data['perma_url'].toString());
        }
        if (value == 4) {
          Navigator.push(
            context,
            PageRouteBuilder(
              opaque: false,
              pageBuilder: (_, __, ___) => SongsListPage(
                listItem: {
                  'type': 'album',
                  'id': mediaItem.extras?['album_id'],
                  'title': mediaItem.album,
                  'image': mediaItem.artUri,
                },
              ),
            ),
          );
        }
        if (value == 5) {
          Navigator.push(
            context,
            PageRouteBuilder(
              opaque: false,
              pageBuilder: (_, __, ___) => AlbumSearchPage(
                query: mediaItem.artist.toString().split(', ').first,
                type: 'Artists',
              ),
            ),
          );
        }
        if (value == 6) {
          widget.deleteLiked!(widget.data);
        }
        if (value == 0) {
          AddToPlaylist().addToPlaylist(context, mediaItem);
        }
        if (value == 1) {
          addToNowPlaying(context: context, mediaItem: mediaItem);
        }
        if (value == 2) {
          playNext(mediaItem, context);
        }
      },
    );
  }
}

class YtSongTileTrailingMenu extends StatefulWidget {
  final Video data;
  const YtSongTileTrailingMenu({super.key, required this.data});

  @override
  _YtSongTileTrailingMenuState createState() => _YtSongTileTrailingMenuState();
}

class _YtSongTileTrailingMenuState extends State<YtSongTileTrailingMenu> {
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton(
      icon: Icon(
        Icons.more_vert_rounded,
        color: Theme.of(context).iconTheme.color,
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(15.0),
        ),
      ),
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 0,
          child: Row(
            children: [
              Icon(
                CupertinoIcons.search,
                color: Theme.of(context).iconTheme.color,
              ),
              const SizedBox(
                width: 10.0,
              ),
              const Text(
                'searchHome',
              ),
            ],
          ),
        ),
        PopupMenuItem(
          value: 1,
          child: Row(
            children: [
              Icon(
                Icons.queue_music_rounded,
                color: Theme.of(context).iconTheme.color,
              ),
              const SizedBox(width: 10.0),
              const Text('playNext'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 2,
          child: Row(
            children: [
              Icon(
                Icons.playlist_add_rounded,
                color: Theme.of(context).iconTheme.color,
              ),
              const SizedBox(width: 10.0),
              const Text('addToQueue'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 3,
          child: Row(
            children: [
              Icon(
                Icons.playlist_add_rounded,
                color: Theme.of(context).iconTheme.color,
              ),
              const SizedBox(width: 10.0),
              const Text('addToPlaylist'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 4,
          child: Row(
            children: [
              Icon(
                Icons.video_library_rounded,
                color: Theme.of(context).iconTheme.color,
              ),
              const SizedBox(width: 10.0),
              const Text('watchVideo'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 5,
          child: Row(
            children: [
              Icon(
                Icons.share_rounded,
                color: Theme.of(context).iconTheme.color,
              ),
              const SizedBox(width: 10.0),
              const Text('share'),
            ],
          ),
        ),
      ],
      onSelected: (int? value) {
        // if (value == 0) {
        //   Navigator.push(
        //     context,
        //     MaterialPageRoute(
        //       builder: (context) => SearchPage(
        //         query: widget.data.title.split('|')[0].split('(')[0],
        //       ),
        //     ),
        //   );
        // }
        // if (value == 1 || value == 2 || value == 3) {
        //   YouTubeServices()
        //       .formatVideo(
        //     video: widget.data,
        //     quality: Hive.box('settings')
        //         .get(
        //           'ytQuality',
        //           defaultValue: 'Low',
        //         )
        //         .toString(),
        //   )
        //       .then((songMap) {
        //     final MediaItem mediaItem =
        //         MediaItemConverter.mapToMediaItem(songMap!);
        //     if (value == 1) {
        //       playNext(mediaItem, context);
        //     }
        //     if (value == 2) {
        //       addToNowPlaying(context: context, mediaItem: mediaItem);
        //     }
        //     if (value == 3) {
        //       AddToPlaylist().addToPlaylist(context, mediaItem);
        //     }
        //   });
        // }
        // if (value == 4) {
        //   launchUrl(
        //     Uri.parse(widget.data.url),
        //     mode: LaunchMode.externalApplication,
        //   );
        // }
        // if (value == 5) {
        //   Share.share(widget.data.url);
        // }
      },
    );
  }
}
