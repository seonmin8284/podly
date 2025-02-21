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

import 'dart:convert';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:podly/CustomWidgets/custom_physics.dart';

// import 'package:blackhole/Helpers/countrycodes.dart';

// import 'package:blackhole/Screens/Settings/setting.dart';
import 'package:flutter/material.dart';

// import 'package:html_unescape/html_unescape_small.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';

List topSongs = [];
List viralSongs = [];
List cachedTopSongs = [];
List cachedViralSongs = [];
bool fetched = false;
bool emptyTop = false;
bool emptyViral = false;

final FlutterTts tts = FlutterTts();
final TextEditingController tts_controller = TextEditingController();

class TopCharts extends StatefulWidget {
  final PageController pageController;

  const TopCharts({super.key, required this.pageController});

  @override
  _TopChartsState createState() => _TopChartsState();
}

class _TopChartsState extends State<TopCharts>
    with AutomaticKeepAliveClientMixin<TopCharts> {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext cntxt) {
    super.build(context);
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool rotated = MediaQuery.of(context).size.height < screenWidth;

    return DefaultTabController(
        length: 2,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            // actions: [
            //   Padding(
            //     padding: const EdgeInsets.symmetric(horizontal: 8.0),
            //     child: IconButton(
            //       icon: const Icon(Icons.my_location_rounded),
            //       onPressed: () async {
            //         await SpotifyCountry().changeCountry(context: context);
            //       },
            //     ),
            //   ),
            // ],
            bottom: TabBar(
              indicatorSize: TabBarIndicatorSize.label,
              tabs: [
                Tab(
                  child: Text(
                    'top',
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodySmall!.color,
                    ),
                  ),
                ),
                Tab(
                  child: Text(
                    'viral',
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodySmall!.color,
                    ),
                  ),
                ),
              ],
            ),
            title: Text(
              '챗봇',
              style: TextStyle(
                fontSize: 18,
                color: Theme.of(context).textTheme.bodySmall!.color,
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
                            Scaffold.of(cntxt).openDrawer();
                          },
                          tooltip: MaterialLocalizations.of(cntxt)
                              .openAppDrawerTooltip,
                        ),
                      );
                    },
                  ),
          ),
          body: const TabBarView(
            physics: CustomPhysics(),
            children: [
              // ValueListenableBuilder(
              //   valueListenable: Hive.box('settings').listenable(),
              //   builder: (BuildContext context, Box box, Widget? widget) {
              //     return TopPage(
              //       region: CountryCodes
              //           .countryCodes[box.get('region', defaultValue: 'India')]
              //           .toString(),
              //     );
              //   },
              // ),
              TopPage(type: 'top'),
              TopPage(type: 'viral'),
            ],
          ),
        ));
  }
}

Future<List> scrapData(String type) async {
  const String authority = 'www.volt.fm';
  const String topPath = '/charts/spotify-top';
  const String viralPath = '/charts/spotify-viral';
  // const String weeklyPath = '/weekly';

  final String unencodedPath = type == 'top' ? topPath : viralPath;
  // if (isWeekly) unencodedPath += weeklyPath;

  final Response res = await get(
    Uri.https(authority, unencodedPath),
    headers: {
      'User-Agent':
          'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
    },
  );

  print('Response status: ${res.statusCode}');
  print('Response body: ${res.body}');

  if (res.statusCode != 200) {
    print('Error: ${res.statusCode} - ${res.body}');
    return List.empty();
  }

  if (res.statusCode != 200) return List.empty();
  final result = RegExp(r'<script.*>({\"context\".*})<\/script>', dotAll: true)
      .firstMatch(res.body)![1]!;
  final Map data = json.decode(result) as Map;
  return data['chart_ranking']['tracks'] as List;
}

class TopPage extends StatefulWidget {
  final String type;

  const TopPage({super.key, required this.type});

  @override
  _TopPageState createState() => _TopPageState();
}

class _TopPageState extends State<TopPage> {
  final TextEditingController _textController = TextEditingController();

  final ScrollController _scrollController = ScrollController();
  List<Map<String, String>> messages = [
    {"text": "안녕하세요. 김세진님!\n오늘은 무엇을 도와드릴까요?", "type": "system"}
  ];

  void _handleSubmitted(String text) async {
    setState(() {
      messages.add({"text": text, "type": "user"}); // 사용자 입력 추가
      messages.add({"text": "", "type": "system"}); // 챗봇 응답을 위한 빈 메시지 추가
      _textController.clear();
      _scrollToBottom();
    });

    final Uri apiUrl = Uri.parse('https://api.openai.com/v1/chat/completions');

    final request = http.Request("POST", apiUrl);
    request.headers.addAll({
      'Authorization': 'Bearer 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', // OpenAI API 키 입력
      'Content-Type': 'application/json',
    });

    // ✅ 기존 대화 이력을 포함하여 OpenAI API 요청 데이터 생성
    List<Map<String, String>> chatHistory = messages.map((msg) {
      return {
        "role": msg["type"] == "user" ? "user" : "assistant",
        "content": msg["text"]!,
      };
    }).toList();

    request.body = jsonEncode({
      "model": "gpt-3.5-turbo",
      "messages": chatHistory, // ✅ 기존 대화 이력 유지
      "temperature": 0.7, // 창의적이면서도 자연스러운 답변
      "max_tokens": 500, // 응답 길이 제한
      "stream": true // 스트리밍 활성화
    });

    try {
      final response = await request.send();

      if (response.statusCode == 200) {
        String replyText = "";
        int chatbotIndex = messages.length - 1; // 챗봇 메시지의 위치 저장

        response.stream.transform(utf8.decoder).listen(
              (chunk) {
            final List<String> lines = chunk.split("\n");
            for (var line in lines) {
              if (line.startsWith("data:")) {
                String jsonStr = line.substring(5).trim();
                if (jsonStr.isNotEmpty && jsonStr != "[DONE]") {
                  try {
                    final Map<String, dynamic> jsonData = jsonDecode(jsonStr);
                    final String? delta = jsonData['choices'][0]['delta']['content'];
                    if (delta != null) {
                      replyText += delta;
                      setState(() {
                        messages[chatbotIndex] = {"text": replyText, "type": "system"};
                      });
                      _scrollToBottom();
                    }
                  } catch (e) {
                    print("JSON 파싱 오류: $e");
                  }
                }
              }
            }
          },
          onDone: () {
            setState(() {});
            _scrollToBottom();
          },
          onError: (error) {
            setState(() {
              messages[chatbotIndex] = {"text": "네트워크 오류 발생: $error", "type": "system"};
            });
          },
        );
      } else {
        setState(() {
          messages.last = {"text": "Error: ${response.statusCode}", "type": "system"};
        });
      }
    } catch (e) {
      setState(() {
        messages.last = {"text": "네트워크 오류 발생: $e", "type": "system"};
      });
    }
  }


  void _speak(String text) async {
    await tts.setLanguage("ko-KR"); // 한국어 설정
    await tts.setSpeechRate(0.5); // 음성 속도 설정
    await tts.setVolume(1.0); // 볼륨 설정
    await tts.setPitch(1.0); // 음성 피치 설정
    await tts.speak(text); // 음성 출력
  }


  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // final String type;
  // @override
  // _TopPageState createState() => _TopPageState();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // appBar: AppBar(
        //   leading: Icon(Icons.arrow_back),
        //   title: Text('챗봇'),
        //   centerTitle: true,
        //   actions: [
        //     Icon(Icons.settings),
        //   ],
        // ),
        body: SingleChildScrollView(
          controller: _scrollController,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image at the top
                // Container(
                //   height: 200,
                //   width: double.infinity,
                //   child: Image.asset(
                //     'assets/your_image.jpg',
                //     fit: BoxFit.cover,
                //   ),
                // ),
                const SizedBox(height: 16),
                // Text and links
                const Text(
                  'How Topic News!',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '태풍 오면 시원해진다는데...이번 태풍 땐 더 무더워',
                ),
                const Text(
                  '<link>',
                  style: TextStyle(color: Colors.blue),
                ),
                const SizedBox(height: 8),
                const Text(
                  '‘대관식’ 앞둔 美민주 해리스, 트럼프에 앞서는 여론 조사 잇따라',
                ),
                const Text(
                  '<link>',
                  style: TextStyle(color: Colors.blue),
                ),
                Wrap(
                  spacing: 8.0,
                  children: [
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text('증시'),
                    ),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text('핫이슈'),
                    ),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
                      child: const Text('날씨'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                for (var message in messages)
                  Align(
                    alignment: message['type'] == 'user'
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
          child: GestureDetector(
            onTap: () {
              if (message['type'] == 'system') {
                _speak(message['text']!); // 🔹 답변 클릭 시 TTS 실행
              }
            },
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 5),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: message['type'] == 'user'
                    ? Colors.brown
                    : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                message['text']!,
                style: TextStyle(
                  color: message['type'] == 'user' ? Colors.white : Colors.black,
                ),
              ),
            ),),
                  ),
                // Buttons

                const SizedBox(height: 16),
                // Chat bubbles
                // Align(
                //   alignment: Alignment.centerLeft,
                //   child: Container(
                //     padding: EdgeInsets.all(10),
                //     decoration: BoxDecoration(
                //       color: Colors.grey.shade300,
                //       borderRadius: BorderRadius.circular(10),
                //     ),
                //     child: Text('안녕하세요. 김세진님!\n오늘은 무엇을 도와드릴까요?'),
                //   ),
                // ),
                const SizedBox(height: 8),
                // Align(
                //   alignment: Alignment.centerRight,
                //   child: Container(
                //     padding: EdgeInsets.all(10),
                //     decoration: BoxDecoration(
                //       color: Colors.brown,
                //       borderRadius: BorderRadius.circular(10),
                //     ),
                //     child: Text(
                //       '궁금한 것 있어?',
                //       style: TextStyle(color: Colors.white),
                //     ),
                //   ),
                // ),
                const SizedBox(height: 8),
                // Align(
                //   alignment: Alignment.centerRight,
                //   child: Container(
                //     padding: EdgeInsets.all(10),
                //     decoration: BoxDecoration(
                //       color: Colors.amber,
                //       borderRadius: BorderRadius.circular(10),
                //     ),
                //     child: Row(
                //       mainAxisSize: MainAxisSize.min,
                //       children: [
                //         Text('이번주 성수동에 열린 팝업스토어는?'),
                //         SizedBox(width: 8),
                //         ElevatedButton(
                //           onPressed: () {},
                //           child: Text('입력'),
                //           style: ElevatedButton.styleFrom(
                //             backgroundColor: Colors.brown,
                //             shape: RoundedRectangleBorder(
                //               borderRadius: BorderRadius.circular(10),
                //             ),
                //           ),
                //         ),
                //       ],
                //     ),
                //   ),
                // ),
              ],
            ),
          ),
        ),
        floatingActionButton: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Positioned(
              bottom: 5.0, // TextField를 화면 하단에서 10px 위로 올림
              left: 32, // 좌측 패딩
              right: 16, // 우측 패딩
              child: Container(
                height: 50, // TextField 높이 설정
                width: double.infinity, // 화면에 꽉 차게 설정
                decoration: BoxDecoration(
                  color: Colors.white, // TextField 배경색 설정
                  borderRadius: BorderRadius.circular(30), // 모서리를 둥글게 설정
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 5.0,
                      offset: Offset(1.5, 1.5), // 그림자 방향: 오른쪽 아래
                    ),
                  ],
                ),
                child: TextField(
                  controller: _textController,
                  decoration: InputDecoration(
                    hintText: '궁금한 것을 물어보세요',
                    hintStyle: const TextStyle(color: Colors.grey),
                    // 힌트 텍스트 스타일
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.send, color: Colors.amber),
                      onPressed: () {
                        if (_textController.text.isNotEmpty) {
                          _handleSubmitted(_textController.text);
                        }
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30), // 모서리를 둥글게 설정
                      borderSide: BorderSide.none, // 테두리를 없앰
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(30),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ));
  }
}

// class _TopPageState extends State<TopPage>
//     with AutomaticKeepAliveClientMixin<TopPage> {
//   Future<void> getData(String type) async {
//     fetched = true;
//     final List temp = await compute(scrapData, type);
//     setState(() {
//       if (type == 'top') {
//         topSongs = temp;
//         if (topSongs.isNotEmpty) {
//           cachedTopSongs = topSongs;
//           Hive.box('cache').put(type, topSongs);
//         }
//         emptyTop = topSongs.isEmpty && cachedTopSongs.isEmpty;
//       } else {
//         viralSongs = temp;
//         if (viralSongs.isNotEmpty) {
//           cachedViralSongs = viralSongs;
//           Hive.box('cache').put(type, viralSongs);
//         }
//         emptyViral = viralSongs.isEmpty && cachedViralSongs.isEmpty;
//       }
//     });
//   }
//
//   Future<void> getCachedData(String type) async {
//     fetched = true;
//     if (type == 'top') {
//       cachedTopSongs =
//           await Hive.box('cache').get(type, defaultValue: []) as List;
//     } else {
//       cachedViralSongs =
//           await Hive.box('cache').get(type, defaultValue: []) as List;
//     }
//     setState(() {});
//   }
//
//   @override
//   bool get wantKeepAlive => true;
//
//   @override
//   void initState() {
//     super.initState();
//     if (widget.type == 'top' && topSongs.isEmpty) {
//       getCachedData(widget.type);
//       getData(widget.type);
//     } else {
//       if (viralSongs.isEmpty) {
//         getCachedData(widget.type);
//         getData(widget.type);
//       }
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     super.build(context);
//     final bool isTop = widget.type == 'top';
//     if (!fetched) {
//       getCachedData(widget.type);
//       getData(widget.type);
//     }
//     final List showList = isTop ? cachedTopSongs : cachedViralSongs;
//     final bool isListEmpty = isTop ? emptyTop : emptyViral;
//     return Column(
//       children: [
//         if (showList.length <= 10)
//           Expanded(
//             child: isListEmpty
//                 ? emptyScreen(
//                     context,
//                     0,
//                     ':( ',
//                     100,
//                     'ERROR',
//                     60,
//                     'Service Unavailable',
//                     20,
//                   )
//                 : Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: const [
//                       CircularProgressIndicator(),
//                     ],
//                   ),
//           )
//         else
//           Expanded(
//             child: ListView.builder(
//               physics: const BouncingScrollPhysics(),
//               itemCount: showList.length,
//               itemExtent: 70.0,
//               itemBuilder: (context, index) {
//                 return ListTile(
//                   leading: Card(
//                     elevation: 5,
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(7.0),
//                     ),
//                     clipBehavior: Clip.antiAlias,
//                     child: Stack(
//                       children: [
//                         const Image(
//                           image: AssetImage('assets/cover.jpg'),
//                         ),
//                         if (showList[index]['image_url_small'] != '')
//                           CachedNetworkImage(
//                             fit: BoxFit.cover,
//                             imageUrl:
//                                 showList[index]['image_url_small'].toString(),
//                             errorWidget: (context, _, __) => const Image(
//                               fit: BoxFit.cover,
//                               image: AssetImage('assets/cover.jpg'),
//                             ),
//                             placeholder: (context, url) => const Image(
//                               fit: BoxFit.cover,
//                               image: AssetImage('assets/cover.jpg'),
//                             ),
//                           ),
//                       ],
//                     ),
//                   ),
//                   title: Text(
//                     '${index + 1}. ${showList[index]["name"]}',
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                   subtitle: Text(
//                     (showList[index]['artists'] as List)
//                         .map((e) => e['name'])
//                         .toList()
//                         .join(', '),
//                     overflow: TextOverflow.ellipsis,
//                   ),
//                   onTap: () {
//                     Navigator.push(
//                       context,
//                       MaterialPageRoute(
//                         builder: (context) => SearchPage(
//                           query: showList[index]['name'].toString(),
//                         ),
//                       ),
//                     );
//                   },
//                 );
//               },
//             ),
//           ),
//       ],
//     );
//   }
// }
