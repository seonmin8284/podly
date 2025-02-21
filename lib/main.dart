import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path_provider_android/path_provider_android.dart';
// import 'package:path_provider_ios/path_provider_ios.dart';
import 'dart:io';
import 'package:get_it/get_it.dart';

import 'package:podly/theme/app_theme.dart';

import 'Helpers/config.dart';
import 'Library/recent.dart';
import 'Screens/Home/start.dart';
import 'Screens/Library/nowplaying.dart';
import 'Screens/Player/audioplayer.dart';
import 'Screens/Settings/setting.dart';
import 'Services/audio_service.dart';
import 'package:podly/Screens/Library/playlists.dart';

late AudioHandler _audioHandler;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();

  if (Platform.isAndroid) PathProviderAndroid.registerWith();
  // if (Platform.isIOS) PathProviderIOS.registerWith();

  await openHiveBox('settings');
  await openHiveBox('downloads');
  await openHiveBox('Favorite Songs');
  await openHiveBox('cache', limit: true);

  await startService();

  runApp(const MyApp());
}

class MyAudioHandler extends BaseAudioHandler
    with QueueHandler, // mix in default queue callback implementations
        SeekHandler { // mix in default seek callback implementations

  final _player = AudioPlayer(); // e.g. just_audio

  // The most common callbacks:
  @override
  Future<void> play() => _player.play();
  @override
  Future<void> pause() => _player.pause();
  @override
  Future<void> stop() => _player.stop();
  @override
  Future<void> seek(Duration position) => _player.seek(position);
  @override
  Future<void> skipToQueueItem(int i) => _player.seek(Duration.zero, index: i);
}
Future<void> startService() async {

  final AudioPlayerHandler audioHandler = await AudioService.init(
    builder: () => AudioPlayerHandlerImpl(),
    config: AudioServiceConfig(
      androidNotificationChannelId: 'com.example.podly.audio',
      androidNotificationChannelName: 'Podly',
      androidNotificationOngoing: true,
      // androidNotificationIcon: 'drawable/ic_stat_music_note',
      androidShowNotificationBadge: true,
      // androidStopForegroundOnPause: Hive.box('settings')
      // .get('stopServiceOnPause', defaultValue: true) as bool,
      notificationColor: Colors.grey[900],
    ),
  );

  GetIt.I.registerSingleton<AudioPlayerHandler>(audioHandler);
  GetIt.I.registerSingleton<MyTheme>(MyTheme());
}

Future<void> openHiveBox(String boxName, {bool limit = false}) async {
  final box = await Hive.openBox(boxName).onError((error, stackTrace) async {
    final Directory dir = await getApplicationDocumentsDirectory();
    final String dirPath = dir.path;
    File dbFile = File('$dirPath/$boxName.hive');
    File lockFile = File('$dirPath/$boxName.lock');

    await dbFile.delete();
    await lockFile.delete();
    await Hive.openBox(boxName);
    throw 'Failed to open $boxName Box\nError: $error';
  });
  // clear box if it grows large
  if (limit && box.length > 500) {
    box.clear();
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();

  static _MyAppState of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>()!;
}

class _MyAppState extends State<MyApp> {
  // Widget initialFuntion() {
  //   return Hive.box('settings').get('userId') != null
  //       ? MyHomePage(title: 'Flutter Demo Home Page')
  //   // : AuthScreen();
  //       : MyHomePage(title: 'Flutter Demo Home Page');
  // }

  @override
  void initState() {
    super.initState();
    AppTheme.currentTheme.addListener(() {
      setState(() {});
    });

    // For sharing or opening urls/text coming from outside the app while the app is in the memory
    // _intentDataStreamSubscription = ReceiveSharingIntent.getTextStream().listen(
    //       (String value) {
    //     handleSharedText(value, navigatorKey);
    //   },
    //   onError: (err) {
    //     // print("ERROR in getTextStream: $err");
    //   },
    // );

    // For sharing or opening urls/text coming from outside the app while the app is closed
    // ReceiveSharingIntent.getInitialText().then(
    //       (String? value) {
    //     if (value != null) handleSharedText(value, navigatorKey);
    //   },
    // );
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      title: 'podly',
      restorationScopeId: 'podly',
      theme: ThemeData(

        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        // '/': (context) => MyHomePage(title: 'Flutter Demo Home Page'),
        '/': (context) => const PodlyApp(title:'podly'),
        '/nowPlaying': (context) => const NowPlaying(),
        // '/pref': (context) => const PrefScreen(),
        '/setting': (context) => const SettingPage(),
        // '/about': (context) => AboutScreen(),
        '/playlists': (context) => const PlaylistScreen(),
        '/recent': (context) => const RecentlyPlayed(),
        // '/downloads': (context) => const Downloads(),
      },
    );
  }
}


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double _opacity = 0.0; // 초기 값을 0.0으로 설정하여 투명한 상태로 시작

  @override
  void initState() {
    super.initState();

    // 일정 시간 후에 화면을 서서히 하얗게 변하게 함
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _opacity = 1.0; // 1.0으로 변경하여 하얗게 변하게 함
        });
      }
    });

    // 화면이 완전히 하얗게 변한 후에 메인 화면으로 전환
    Future.delayed(const Duration(seconds: 4), () {
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 스플래시 이미지를 한 번만 표시
          Image.asset('assets/pod.png', fit: BoxFit.cover),
          AnimatedOpacity(
            opacity: _opacity,
            duration: const Duration(seconds: 2),
            child: Container(
              color: Colors.white,
              child: const Center(
                child: Text(
                  'PODLY',
                  style: TextStyle(
                    fontSize: 48.0, // 글씨 크기를 48로 설정
                    fontWeight: FontWeight.bold, // 글씨를 굵게 설정
                    color: Colors.black, // 글씨 색상 (필요에 따라 변경 가능)
                  ),
                  textAlign: TextAlign.center, // 텍스트를 중앙 정렬
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
