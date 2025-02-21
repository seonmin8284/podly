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


//
import 'package:audio_service/audio_service.dart';
import 'package:get_it/get_it.dart';
import 'package:podly/APIs/api.dart';
import 'package:podly/CustomWidgets/collage.dart';
import 'package:podly/CustomWidgets/horizontal_albumlist.dart';
import 'package:podly/CustomWidgets/on_hover.dart';
import 'package:podly/Helpers/extensions.dart';
import 'package:podly/Helpers/format.dart';
import 'package:podly/Screens/Library/liked.dart';
import 'package:podly/Screens/Player/audioplayer.dart';
import 'package:flutter/material.dart';

// import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:hive/hive.dart';

bool fetched = false;
List preferredLanguage = Hive.box('settings')
    .get('preferredLanguage', defaultValue: ['Hindi']) as List;
List likedRadio =
    Hive.box('settings').get('likedRadio', defaultValue: []) as List;
Map data = Hive.box('cache').get('homepage', defaultValue: {}) as Map;
List lists = ['recent', 'playlist', ...?data['collections']];

class SaavnHomePage extends StatefulWidget {
  const SaavnHomePage({super.key});

  @override
  _SaavnHomePageState createState() => _SaavnHomePageState();
}

class _SaavnHomePageState extends State<SaavnHomePage>
    with AutomaticKeepAliveClientMixin<SaavnHomePage> {
  Set<String> selectedButtons = {};

  Set<int> selectedIndices = {};

  final TextEditingController _textEditingController = TextEditingController();

  List recentList =
      Hive.box('cache').get('recentSongs', defaultValue: []) as List;
  Map likedArtists =
      Hive.box('settings').get('likedArtists', defaultValue: {}) as Map;
  List blacklistedHomeSections = Hive.box('settings')
      .get('blacklistedHomeSections', defaultValue: []) as List;
  List playlistNames =
      Hive.box('settings').get('playlistNames')?.toList() as List? ??
          ['Favorite Songs'];
  Map playlistDetails =
      Hive.box('settings').get('playlistDetails', defaultValue: {}) as Map;
  int recentIndex = 0;
  int playlistIndex = 1;

  Future<void> getHomePageData() async {
    Map recievedData = await SaavnAPI().fetchHomePageData();

    if (recievedData.isNotEmpty) {
      Hive.box('cache').put('homepage', recievedData);
      data = recievedData;
      lists = ['recent', 'playlist', ...?data['collections']];
      lists.insert((lists.length / 2).round(), 'likedArtists');
      print("Lists: $lists"); // 리스트 내용 출력

    }
    setState(() {});

    recievedData = await FormatResponse.formatPromoLists(data);
    if (recievedData.isNotEmpty) {
      Hive.box('cache').put('homepage', recievedData);
      data = recievedData;
      lists = ['recent', 'playlist', ...?data['collections']];
      lists.insert((lists.length / 2).round(), 'likedArtists');
    }
    setState(() {});
  }

  String getSubTitle(Map item) {
    final type = item['type'];
    switch (type) {
      case 'charts':
        return '';
      case 'radio_station':
        return 'Radio • ${item['subtitle']?.toString().unescape()}';
      case 'playlist':
        return 'Playlist • ${item['subtitle']?.toString().unescape() ?? 'JioSaavn'}';
      case 'song':
        return 'Single • ${item['artist']?.toString().unescape()}';
      case 'album':
        final artists = item['more_info']?['artistMap']?['artists']
            .map((artist) => artist['name'])
            .toList();
        if (artists != null) {
          return 'Album • ${artists?.join(', ')?.toString().unescape()}';
        } else if (item['subtitle'] != null && item['subtitle'] != '') {
          return 'Album • ${item['subtitle']?.toString().unescape()}';
        }
        return 'Album';
      default:
        final artists = item['more_info']?['artistMap']?['artists']
            .map((artist) => artist['name'])
            .toList();
        return artists?.join(', ')?.toString().unescape() ?? '';
    }
  }

  void onButtonPressed(String label) {
    setState(() {
      if (selectedButtons.contains(label)) {
        selectedButtons.remove(label);
      } else {
        selectedButtons.add(label);
      }
    });
    debugPrint('Button pressed: $label'); // print 대신 debugPrint 사용
  }




  Widget buildSelectableButton(String label) {
    print("buildSelectableButton called for: $label");  // 함수 호출 확인
    bool isSelected = selectedButtons.contains(label);
    return InkWell(
      onTap: () {
        onButtonPressed(label);
        print("InkWell tapped: $label");  // 이 부분이 출력되는지 확인
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          color: isSelected
              ? Colors.orange.withOpacity(0.5)
              : Theme.of(context).cardColor,
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 5.0,
              offset: Offset(1.5, 1.5),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Text(label),
      ),
    );
  }



  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    if (!fetched) {
      getHomePageData();
      fetched = true;
    }

    double boxSize =
    MediaQuery.of(context).size.height > MediaQuery.of(context).size.width
        ? MediaQuery.of(context).size.width / 2
        : MediaQuery.of(context).size.height / 2.5;
    if (boxSize > 250) boxSize = 250;
    if (recentList.length < playlistNames.length) {
      recentIndex = 1;
      playlistIndex = 0;
    } else {
      recentIndex = 0;
      playlistIndex = 1;
    }

    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Expanded(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              shrinkWrap: true,
              padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                  child: Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: [
                      ...selectedButtons.map((label) => buildSelectableButton(label)),
                      Container(
                        width: 140, // buildSelectableButton과 동일한 너비를 설정
                        height: 36, // SelectableButton과 동일한 높이로 설정
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10.0),
                          color: Theme.of(context).cardColor,
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 5.0,
                              offset: Offset(1.5, 1.5),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: _textEditingController,
                                style: const TextStyle(
                                  fontSize: 16.0, // SelectableButton의 텍스트 크기와 맞추기 위해
                                ),
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  hintText: '태그 추가',
                                  hintStyle: TextStyle(
                                    fontSize: 16.0, // 힌트 텍스트의 크기도 동일하게 맞춤
                                  ),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                if (_textEditingController.text.isNotEmpty) {
                                  setState(() {
                                    selectedButtons.add(_textEditingController.text);
                                    _textEditingController.clear(); // 텍스트 필드를 비웁니다.
                                  });
                                }
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 4), // 아이콘과의 패딩 설정
                                child: const Icon(
                                  Icons.add,
                                  size: 20, // 아이콘 크기를 조정
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                if (selectedButtons.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 5),
                    child: ElevatedButton(
                      onPressed: () {
                        print("Generate button pressed with selections: $selectedButtons");
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 5.0,
                      ),
                      child: const Text(
                        "Generate",
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                buildNewsSection(boxSize, "Today's Top News"),
                if (!(recentList.isEmpty ||
                    !(Hive.box('settings').get('showRecent', defaultValue: true)
                    as bool)))
                  buildHistorySection(boxSize),
                buildNewsSection(boxSize, 'Podly 인기 뉴스'),
                if (!(playlistNames.isEmpty ||
                    !(Hive.box('settings').get('showPlaylist', defaultValue: true)
                    as bool)))
                  buildPlaylistSection(boxSize),
              ],
            ),
          ),
        ],
      ),
    );
  }



// '인기 뉴스' 섹션 빌더 함수
  Widget buildNewsSection(double boxSize, String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(15, 10, 0, 5),
          child: Text(
            title,
            style: TextStyle(
              color: Theme.of(context).colorScheme.secondary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(
            height: boxSize + 15,
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              itemCount: 3,
              itemBuilder: (context, index) {
                String imagePath;
                String title;
                String subTitle;
                Widget child;

                switch (index) {
                  case 0:
                    imagePath = 'assets/asimg/anchor3.jpeg';
                    title = '우크라이나 vs 러시아 전쟁';
                    subTitle = '소제목1';
                    break;
                  case 1:
                    imagePath = 'assets/asimg/anchor2.jpg';
                    title = '코로나 확진자 증가';
                    subTitle = '소제목2';
                    break;
                  case 2:
                    imagePath = 'assets/asimg/anchor1.jpg';
                    title = '트럼프 유세';
                    subTitle = '소제목3';
                    break;
                  default:
                    imagePath = 'assets/asimg/default.jpg';
                    title = 'Default News';
                    subTitle = 'Default Subtitle';
                }

                // 선택된 경우와 선택되지 않은 경우의 child 정의
                if (selectedIndices.contains(index)) {
                  child = Stack(
                    children: [
                      ColorFiltered(
                        colorFilter: ColorFilter.mode(
                          Colors.black.withOpacity(0.5), // 투명도 조절
                          BlendMode.dstATop,
                        ),
                        child: Image.asset(
                          imagePath,
                          fit: BoxFit.cover,
                          width: boxSize - 30,
                          height: boxSize - 30,
                        ),
                      ),
                      const Center(
                        child: Icon(
                          Icons.check, // 체크 표시 아이콘
                          color: Colors.amber,
                          size: 80.0,
                        ),
                      ),
                    ],
                  );
                } else {
                  child = Image.asset(
                    imagePath,
                    fit: BoxFit.cover,
                    width: boxSize - 30,
                    height: boxSize - 30,
                  );
                }

                return GestureDetector(
                  onTap: () async {
                    imagePath = 'assets/asimg/anchor3.jpeg';
                    final AudioPlayerHandler audioHandler = GetIt.I<AudioPlayerHandler>();
                    var item = MediaItem(
                      id: 'assets/music.mp3', // 로컬 음악 파일 경로
                      album: '사회/문화',
                      title: title,
                      extras: {
                        'url': imagePath
                      },
                      artist: '포들경제',
                      genre: 'news',
                      displayTitle: title,
                      displaySubtitle: '부제목',
                      displayDescription: '설명',
                      rating: const Rating.newPercentageRating(85.0),
                      duration: const Duration(milliseconds: 123456),
                      artUri: Uri.parse(imagePath),
                    );
                    try {
                      await audioHandler.addQueueItem(item); // queue에 항목 추가
                      await audioHandler.play(); // 재생 시작

                      // Navigate to PlayScreen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PlayScreen(
                        songsList: recentList,
                        index: index,
                        offline: false,
                        fromDownloads: false,
                        fromMiniplayer: false,
                        recommend: true,
                      ),
                        ),
                      );
                    } catch (e) {
                      print("Error playing dummy data: $e");
                    }
                  },
                  child: SizedBox(
                    width: boxSize - 30,
                    child: HoverBox(
                      child: Card(
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: child,
                      ),
                      builder: (BuildContext context, bool isHover, Widget? child) {
                        return Card(
                          color: isHover ? null : Colors.transparent,
                          elevation: 0,
                          margin: EdgeInsets.zero,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Column(
                            children: [
                              Stack(
                                children: [
                                  SizedBox.square(
                                    dimension: isHover ? boxSize - 25 : boxSize - 30,
                                    child: child,
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10.0),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      title,
                                      textAlign: TextAlign.center,
                                      softWrap: false,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      subTitle,
                                      textAlign: TextAlign.center,
                                      softWrap: false,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Theme.of(context).textTheme.bodySmall!.color,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                )
                ;
              },
            ))
      ],
    );
  }

// '히스토리' 섹션 빌더 함수
  Widget buildHistorySection(double boxSize) {
    return Column(
      children: [
        Row(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 10, 0, 5),
              child: Text(
                '히스토리',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        HorizontalAlbumsList(
          songsList: recentList,
          onTap: (int idx) {
            Navigator.push(
              context,
              PageRouteBuilder(
                opaque: false,
                pageBuilder: (_, __, ___) => PlayScreen(
                  songsList: recentList,
                  index: idx,
                  offline: false,
                  fromDownloads: false,
                  fromMiniplayer: false,
                  recommend: true,
                ),
              ),
            );
          },
        ),
      ],
    );
  }

// '플레이리스트' 섹션 빌더 함수
  // '플레이리스트' 섹션 빌더 함수
  // '플레이리스트' 섹션 빌더 함수
  Widget buildPlaylistSection(double boxSize) {
    return Column(
      children: [
        Row(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(15, 10, 0, 5),
              child: Text(
                '플레이리스트',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        SizedBox(
          height: boxSize + 15,
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            itemCount: playlistNames.length,
            itemBuilder: (context, index) {
              final String name = playlistNames[index].toString();
              final String showName = playlistDetails.containsKey(name)
                  ? playlistDetails[name]['name']?.toString() ?? name
                  : name;
              final String? subtitle = playlistDetails[name] == null ||
                      playlistDetails[name]['count'] == null ||
                      playlistDetails[name]['count'] == 0
                  ? null
                  : '${playlistDetails[name]['count']} ${'songs'}';
              return GestureDetector(
                child: SizedBox(
                  width: boxSize - 30,
                  child: HoverBox(
                    child: (playlistDetails[name] == null ||
                            playlistDetails[name]['imagesList'] == null ||
                            (playlistDetails[name]['imagesList'] as List)
                                .isEmpty)
                        ? Card(
                            elevation: 5,
                            color: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(
                                10.0,
                              ),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: name == 'Favorite Songs'
                                ? const Image(
                                    image: AssetImage(
                                      'assets/cover.jpg',
                                    ),
                                  )
                                : const Image(
                                    image: AssetImage(
                                      'assets/album.png',
                                    ),
                                  ),
                          )
                        : Collage(
                            borderRadius: 10.0,
                            imageList:
                                playlistDetails[name]['imagesList'] as List,
                            showGrid: true,
                            placeholderImage: 'assets/cover.jpg',
                          ),
                    builder: (
                      BuildContext context,
                      bool isHover,
                      Widget? child,
                    ) {
                      return Card(
                        color: isHover ? null : Colors.transparent,
                        elevation: 0,
                        margin: EdgeInsets.zero,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            10.0,
                          ),
                        ),
                        clipBehavior: Clip.antiAlias,
                        child: Column(
                          children: [
                            SizedBox.square(
                              dimension: isHover ? boxSize - 25 : boxSize - 30,
                              child: child,
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10.0,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    showName,
                                    textAlign: TextAlign.center,
                                    softWrap: false,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  if (subtitle != null)
                                    Text(
                                      subtitle,
                                      textAlign: TextAlign.center,
                                      softWrap: false,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Theme.of(context)
                                            .textTheme
                                            .bodySmall!
                                            .color,
                                      ),
                                    )
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                onTap: () async {
                  await Hive.openBox(name);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => LikedSongs(
                        playlistName: name,
                        showName: playlistDetails.containsKey(name)
                            ? playlistDetails[name]['name']?.toString() ?? name
                            : name,
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
        // 추가된 라디오 섹션
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(15, 10, 0, 5),
            child: Text(
              '인기 DJ봇',
              style: TextStyle(
                color: Theme.of(context).colorScheme.secondary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(
              height: boxSize + 15,
              child: ListView.builder(
                physics: const BouncingScrollPhysics(),
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                itemCount: 3,
                // 3개의 아이템 표시
                itemBuilder: (context, index) {
                  // 더미 데이터 설정
                  Map<String, String> item;
                  switch (index) {
                    case 0:
                      item = {
                        'type': 'radio_station',
                        'title': '철수',
                        'subtitle': '아무거나 소제목',
                        'image': 'assets/asimg/human3.jpg'
                      };
                      break;
                    case 1:
                      item = {
                        'type': 'radio_station',
                        'title': '영희',
                        'subtitle': '아무거나 소제목',
                        'image': 'assets/asimg/human2.jpg'
                      };
                      break;
                    case 2:
                      item = {
                        'type': 'radio_station',
                        'title': '유리',
                        'subtitle': '아무거나 소제목',
                        'image': 'assets/asimg/human.png'
                      };
                      break;
                    default:
                      item = {
                        'type': 'radio_station',
                        'title': '아무거나',
                        'subtitle': '아무거나 소제목',
                        'image': 'assets/asimg/human.png'
                      };
                  }

                  final subTitle = item['subtitle'] ?? '';

                  return GestureDetector(
                    onLongPress: () {
                      Feedback.forLongPress(context);
                      showDialog(
                        context: context,
                        builder: (context) {
                          return InteractiveViewer(
                            child: Stack(
                              children: [
                                GestureDetector(
                                  onTap: () => Navigator.pop(context),
                                ),
                                AlertDialog(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15.0),
                                  ),
                                  backgroundColor: Colors.transparent,
                                  contentPadding: EdgeInsets.zero,
                                  content: Card(
                                    elevation: 5,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                        item['type'] == 'radio_station'
                                            ? 1000.0
                                            : 15.0,
                                      ),
                                    ),
                                    clipBehavior: Clip.antiAlias,
                                    child: Image.asset(
                                      item['image']!,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                    onTap: () {
                      // 여기에 onTap 동작 추가
                    },
                    child: SizedBox(
                      width: boxSize - 30,
                      child: HoverBox(
                        child: Card(
                          elevation: 5,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              item['type'] == 'radio_station' ? 1000.0 : 10.0,
                            ),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: Image.asset(
                            item['image']!,
                            fit: BoxFit.cover,
                          ),
                        ),
                        builder: (BuildContext context, bool isHover,
                            Widget? child) {
                          return Card(
                            color: isHover ? null : Colors.transparent,
                            elevation: 0,
                            margin: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: Column(
                              children: [
                                Stack(
                                  children: [
                                    SizedBox.square(
                                      dimension:
                                          isHover ? boxSize - 25 : boxSize - 30,
                                      child: child,
                                    ),
                                    if (isHover &&
                                        (item['type'] == 'song' ||
                                            item['type'] == 'radio_station'))
                                      Positioned.fill(
                                        child: Container(
                                          margin: const EdgeInsets.all(4.0),
                                          decoration: BoxDecoration(
                                            color: Colors.black54,
                                            borderRadius: BorderRadius.circular(
                                              item['type'] == 'radio_station'
                                                  ? 1000.0
                                                  : 10.0,
                                            ),
                                          ),
                                          child: Center(
                                            child: DecoratedBox(
                                              decoration: BoxDecoration(
                                                color: Colors.black87,
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        1000.0),
                                              ),
                                              child: const Icon(
                                                Icons.play_arrow_rounded,
                                                size: 50.0,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10.0),
                                  child: Column(
                                    children: [
                                      Text(
                                        item['title']!,
                                        textAlign: TextAlign.center,
                                        softWrap: false,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      if (subTitle.isNotEmpty)
                                        Text(
                                          subTitle,
                                          textAlign: TextAlign.center,
                                          softWrap: false,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Theme.of(context)
                                                .textTheme
                                                .bodySmall!
                                                .color,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  );
                },


              )
          ),
        ])
      ],
    );
  }
}

