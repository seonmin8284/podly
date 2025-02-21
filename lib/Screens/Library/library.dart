
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

import 'dart:io';

import 'package:podly/Screens/Library/liked.dart';
// import 'package:podly/Screens/LocalMusic/downed_songs.dart';
// import 'package:podly/Screens/LocalMusic/downed_songs_desktop.dart';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});

  @override
  _LibraryPageState createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool rotated = MediaQuery.of(context).size.height < screenWidth;
    return ListView(
      physics: const BouncingScrollPhysics(),
      children: [
        AppBar(
          title: Text(
            'library',
            style: TextStyle(
              color: Theme.of(context).iconTheme.color,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
          leading: (rotated && screenWidth < 1050)
              ? null
              : Builder(
                  builder: (BuildContext context) {
                    return Transform.rotate(
                      angle: 22 / 7 * 2,
                      child: IconButton(
                        color: Theme.of(context).iconTheme.color,
                        icon: const Icon(
                          Icons.horizontal_split_rounded,
                        ),
                        onPressed: () {
                          Scaffold.of(context).openDrawer();
                        },
                        tooltip: MaterialLocalizations.of(context)
                            .openAppDrawerTooltip,
                      ),
                    );
                  },
                ),
        ),
        LibraryTile(
          title: 'nowPlaying',
          icon: Icons.queue_music_rounded,
          onTap: () {
            Navigator.pushNamed(context, '/nowPlaying');
          },
        ),
        LibraryTile(
          title: 'lastSession',
          icon: Icons.history_rounded,
          onTap: () {
            Navigator.pushNamed(context, '/recent');
          },
        ),
        LibraryTile(
          title: 'favorites',
          icon: Icons.favorite_rounded,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const LikedSongs(
                  playlistName: 'Favorite Songs',
                  showName: 'favSongs',
                ),
              ),
            );
          },
        ),
        if (!Platform.isIOS)
          LibraryTile(
            title: 'myMusic',
            icon: MdiIcons.folderMusic,
            onTap: () {
              // Navigator.push(
              //   context,
              //   MaterialPageRoute(
              //     builder: (context) => (Platform.isWindows || Platform.isLinux)
              //         ? const DownloadedSongsDesktop()
              //         : const DownloadedSongs(
              //             showPlaylists: true,
              //           ),
              //   ),
              // );
            },
          ),
        LibraryTile(
          title: 'downs',
          icon: Icons.download_done_rounded,
          onTap: () {
            Navigator.pushNamed(context, '/downloads');
          },
        ),
        LibraryTile(
          title: 'playlists',
          icon: Icons.playlist_play_rounded,
          onTap: () {
            Navigator.pushNamed(context, '/playlists');
          },
        ),
      ],
    );
  }
}

class LibraryTile extends StatelessWidget {
  const LibraryTile({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final String title;
  final IconData icon;
  final Function() onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(
          color: Theme.of(context).iconTheme.color,
        ),
      ),
      leading: Icon(
        icon,
        color: Theme.of(context).iconTheme.color,
      ),
      onTap: onTap,
    );
  }
}
