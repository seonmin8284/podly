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

import 'package:audio_service/audio_service.dart';
import 'package:flutter/services.dart';
import 'package:podly/CustomWidgets/bouncy_sliver_scroll_view.dart';
import 'package:podly/CustomWidgets/empty_screen.dart';
import 'package:podly/CustomWidgets/gradient_containers.dart';
import 'package:podly/CustomWidgets/miniplayer.dart';
import 'package:podly/Screens/Player/audioplayer.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:path_provider/path_provider.dart';

class NowPlaying extends StatefulWidget {
  const NowPlaying({super.key});

  @override
  _NowPlayingState createState() => _NowPlayingState();
}

class _NowPlayingState extends State<NowPlaying> {
  final AudioPlayerHandler audioHandler = GetIt.I<AudioPlayerHandler>();

  @override
  void initState() {
    super.initState();
    _playDummyData();
  }

  Future<String> saveAssetImageToLocalPath(String assetPath) async {
    // 1. Assets에서 파일을 로드합니다.
    final ByteData data = await rootBundle.load(assetPath);

    // 2. 앱의 내부 저장소 경로를 가져옵니다.
    final directory = await getApplicationDocumentsDirectory();

    // 3. 파일을 저장할 경로를 설정합니다.
    final file = File('${directory.path}/${assetPath.split('/').last}');

    // 4. ByteData를 파일로 저장합니다.
    await file.writeAsBytes(data.buffer.asUint8List());

    // 5. 파일의 경로를 반환합니다.
    return file.path;
  }

  Future<void> _playDummyData() async {
    String localImagePath = await saveAssetImageToLocalPath('assets/podly.png');
    // // Assets에서 파일을 로드합니다.
    // final ByteData data = await rootBundle.load('assets/music.mp3');
    // final buffer = data.buffer;
    //
    // // 파일을 디스크에 저장합니다.
    // final directory = await getApplicationDocumentsDirectory();
    // final file = File('${directory.path}/music.mp3');
    // await file.writeAsBytes(buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
    // print(file.uri.toString());
    double percent = 85.0;
    // 재생할 더미 데이터 설정
    var item = MediaItem(
      id: 'assets/news.mp4', // 로컬 음악 파일 경로
      album: '사회/문화',
      title: '문화재 도난',
      extras: {
        'url': 'https://m.theneighbor.co.kr/upload/Editor/Editor_2019122712189_756848.jpg' // 필수 URL 설정
      },
      artist: '포들경제',
      genre: 'news',
      displayTitle: '문화재 도난',
      displaySubtitle: '부제목',
      displayDescription: '설명',
      rating : Rating.newPercentageRating(percent),
      duration: const Duration(milliseconds: 1234560),
      artUri: Uri.parse('https://m.theneighbor.co.kr/upload/Editor/Editor_2019122712189_756848.jpg'), // 올바르게 파싱된 원격 이미지 URL
    );


    print(item);

    try {
      await audioHandler.addQueueItem(item); // queue에 항목 추가
      await audioHandler.play(); // 재생 시작
    } catch (e) {
      print("Error playing dummy data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return GradientContainer(
      child: Column(
        children: [
          Expanded(
            child: StreamBuilder<PlaybackState>(
              stream: audioHandler.playbackState,
              builder: (context, snapshot) {
                final playbackState = snapshot.data;
                final processingState = playbackState?.processingState;
                return Scaffold(
                  backgroundColor: Colors.transparent,
                  appBar: processingState != AudioProcessingState.idle
                      ? null
                      : AppBar(
                          title: const Text('nowPlaying'),
                          centerTitle: true,
                          backgroundColor:
                              Theme.of(context).brightness == Brightness.dark
                                  ? Colors.transparent
                                  : Theme.of(context).colorScheme.secondary,
                          elevation: 0,
                        ),
                  body: processingState == AudioProcessingState.idle
                      ? emptyScreen(
                          context,
                          3,
                          'nothingIs',
                          18.0,
                          'playingCap',
                          60,
                          'playSomething',
                          23.0,
                        )
                      : StreamBuilder<MediaItem?>(
                          stream: audioHandler.mediaItem,
                          builder: (context, snapshot) {
                            final mediaItem = snapshot.data;
                            return mediaItem == null
                                ? const SizedBox()
                                : BouncyImageSliverScrollView(
                                    title: 'nowPlaying',
                                    localImage: mediaItem.artUri!
                                        .toString()
                                        .startsWith('file:'),
                                    imageUrl: mediaItem.artUri!
                                            .toString()
                                            .startsWith('file:')
                                        ? mediaItem.artUri!.toFilePath()
                                        : mediaItem.artUri!.toString(),
                                    sliverList: SliverList(
                                      delegate: SliverChildListDelegate(
                                        [
                                          NowPlayingStream(
                                            audioHandler: audioHandler,
                                          )
                                        ],
                                      ),
                                    ),
                                  );
                          },
                        ),
                );
              },
            ),
          ),
          const MiniPlayer(),
        ],
      ),
    );
  }
}
