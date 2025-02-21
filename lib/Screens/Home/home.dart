import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:podly/CustomWidgets/gradient_containers.dart';
import 'dart:io';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:podly/CustomWidgets/snackbar.dart';
import 'package:podly/CustomWidgets/custom_physics.dart';
import 'package:podly/CustomWidgets/textinput_dialog.dart';
import 'package:podly/Helpers/extensions.dart';
// import 'package:podly/Screens/Home/saavn.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

import '../../CustomWidgets/miniplayer.dart';
import '../Library/library.dart';
import '../Settings/setting.dart';
import '../Top Charts/top.dart';
import '../YouTube/youtube_home.dart';
import 'package:podly/Screens/Home/saavn.dart';
//채팅 창 위에다가 배치


// import 'package:flutter_gen/gen_l10n/app_localizations.dart';


class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}


class _MyHomePageState extends State<MyHomePage> {

  // final ValueNotifier<int> _selectedIndex = ValueNotifier<int>(0);
  // bool checked = false;
  // String? appVersion;
  String name =
      Hive.box('settings').get('name', defaultValue: 'Guest') as String;
  // bool checkUpdate =
  //     Hive.box('settings').get('checkUpdate', defaultValue: false) as bool;
  // bool autoBackup =
  //     Hive.box('settings').get('autoBackup', defaultValue: false) as bool;
  // DateTime? backButtonPressTime;

  void callback() {
    setState(() {});
  }

  final ValueNotifier<int> _selectedIndex = ValueNotifier<int>(0);

  DateTime? backButtonPressTime;


  void _onItemTapped(int index) {
    _selectedIndex.value = index;
    _pageController.jumpToPage(
      index,
    );
  }

  void updateUserDetails(String key, dynamic value) {
    final userId = Hive.box('settings').get('userId') as String?;
    // SupaBase().updateUserDetails(userId, key, value);
  }

  Future<bool> handleWillPop(BuildContext context) async {
    final now = DateTime.now();
    final backButtonHasNotBeenPressedOrSnackBarHasBeenClosed =
        backButtonPressTime == null ||
            now.difference(backButtonPressTime!) > const Duration(seconds: 3);

    if (backButtonHasNotBeenPressedOrSnackBarHasBeenClosed) {
      backButtonPressTime = now;
      ShowSnackBar().showSnackBar(
        context,
        'exitConfirm',
        duration: const Duration(seconds: 2),
        noAction: true,
      );
      return false;
    }
    return true;
  }

  final ScrollController _scrollController = ScrollController();
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();

  }

  @override
  void dispose() {
    _pageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final bool rotated = MediaQuery.of(context).size.height < screenWidth;
    return GradientContainer(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.transparent,
        drawer: Drawer(
          child: GradientContainer(
            child: CustomScrollView(
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverAppBar(
                  backgroundColor: Colors.transparent,
                  automaticallyImplyLeading: false,
                  elevation: 0,
                  stretch: true,
                  expandedHeight: MediaQuery.of(context).size.height * 0.2,
                  flexibleSpace: FlexibleSpaceBar(
                    title: RichText(
                      text: const TextSpan(
                        text: 'Podly',
                        style: TextStyle(
                          fontSize: 30.0,
                          fontWeight: FontWeight.w500,
                        ),
                        // children: <TextSpan>[
                        //   TextSpan(
                        //     text: appVersion == null ? '' : '\nv$appVersion',
                        //     style: const TextStyle(
                        //       fontSize: 7.0,
                        //     ),
                        //   ),
                        // ],
                      ),
                      textAlign: TextAlign.end,
                    ),
                    titlePadding: const EdgeInsets.only(bottom: 40.0),
                    centerTitle: true,
                    background: ShaderMask(
                      shaderCallback: (rect) {
                        return LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withOpacity(0.8),
                            Colors.black.withOpacity(0.1),
                          ],
                        ).createShader(
                          Rect.fromLTRB(0, 0, rect.width, rect.height),
                        );
                      },
                      blendMode: BlendMode.dstIn,
                      child: Image(
                        fit: BoxFit.cover,
                        alignment: Alignment.topCenter,
                        image: AssetImage(
                          Theme.of(context).brightness == Brightness.dark
                              ? 'assets/header-dark.jpg'
                              : 'assets/header.jpg',
                        ),
                      ),
                    ),
                  ),
                ),
                SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      ListTile(
                        title: Text(
                          'Home',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                        contentPadding:
                        const EdgeInsets.symmetric(horizontal: 20.0),
                        leading: Icon(
                          Icons.home_rounded,
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                        selected: true,
                        onTap: () {
                          Navigator.pop(context);
                        },
                      ),
                      if (Platform.isAndroid)
                        ListTile(
                          title: const Text('myMusic'),
                          contentPadding:
                          const EdgeInsets.symmetric(horizontal: 20.0),
                          leading: Icon(
                            MdiIcons.folderMusic,
                            color: Theme.of(context).iconTheme.color,
                          ),
                          onTap: () {
                            Navigator.pop(context);
                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(
                            //     builder: (context) => const DownloadedSongs(
                            //       showPlaylists: true,
                            //     ),
                            //   ),
                            // );
                          },
                        ),
                      ListTile(
                        title: const Text('downs'),
                        contentPadding:
                        const EdgeInsets.symmetric(horizontal: 20.0),
                        leading: Icon(
                          Icons.download_done_rounded,
                          color: Theme.of(context).iconTheme.color,
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(context, '/downloads');
                        },
                      ),
                      ListTile(
                        title: const Text('playlists'),
                        contentPadding:
                        const EdgeInsets.symmetric(horizontal: 20.0),
                        leading: Icon(
                          Icons.playlist_play_rounded,
                          color: Theme.of(context).iconTheme.color,
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(context, '/playlists');
                        },
                      ),
                      ListTile(
                        title: const Text('settings'),
                        contentPadding:
                        const EdgeInsets.symmetric(horizontal: 20.0),
                        leading: Icon(
                          Icons
                              .settings_rounded, // miscellaneous_services_rounded,
                          color: Theme.of(context).iconTheme.color,
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  SettingPage(callback: callback),
                            ),
                          );
                        },
                      ),
                      ListTile(
                        title: const Text('about'),
                        contentPadding:
                        const EdgeInsets.symmetric(horizontal: 20.0),
                        leading: Icon(
                          Icons.info_outline_rounded,
                          color: Theme.of(context).iconTheme.color,
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.pushNamed(context, '/about');
                        },
                      ),
                    ],
                  ),
                ),
                const SliverFillRemaining(
                  hasScrollBody: false,
                  child: Column(
                    children: <Widget>[
                      Spacer(),
                      Padding(
                        padding: EdgeInsets.fromLTRB(5, 30, 5, 20),
                        child: Center(
                          child: Text(
                            'madeBy',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        body: WillPopScope(
          onWillPop: () => handleWillPop(context),
          child: SafeArea(
            child: Row(
              children: [
                if (rotated)
                  ValueListenableBuilder(
                    valueListenable: _selectedIndex,
                    builder:
                        (BuildContext context, int indexValue, Widget? child) {
                      return NavigationRail(
                        minWidth: 70.0,
                        groupAlignment: 0.0,
                        backgroundColor:
                        // Colors.transparent,
                        Theme.of(context).cardColor,
                        selectedIndex: indexValue,
                        onDestinationSelected: (int index) {
                          _onItemTapped(index);
                        },
                        labelType: screenWidth > 1050
                            ? NavigationRailLabelType.selected
                            : NavigationRailLabelType.none,
                        selectedLabelTextStyle: TextStyle(
                          color: Theme.of(context).colorScheme.secondary,
                          fontWeight: FontWeight.w600,
                        ),
                        unselectedLabelTextStyle: TextStyle(
                          color: Theme.of(context).iconTheme.color,
                        ),
                        selectedIconTheme: Theme.of(context).iconTheme.copyWith(
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                        unselectedIconTheme: Theme.of(context).iconTheme,
                        useIndicator: screenWidth < 1050,
                        indicatorColor: Theme.of(context)
                            .colorScheme
                            .secondary
                            .withOpacity(0.2),
                        leading: screenWidth > 1050
                            ? null
                            : Builder(
                          builder: (context) => Transform.rotate(
                            angle: 22 / 7 * 2,
                            child: IconButton(
                              icon: const Icon(
                                Icons.horizontal_split_rounded,
                              ),
                              // color: Theme.of(context).iconTheme.color,
                              onPressed: () {
                                Scaffold.of(context).openDrawer();
                              },
                              tooltip: MaterialLocalizations.of(context)
                                  .openAppDrawerTooltip,
                            ),
                          ),
                        ),
                        destinations: const [
                          NavigationRailDestination(
                            icon: Icon(Icons.home_rounded),
                            label: Text('Home'),
                          ),
                          NavigationRailDestination(
                            icon: Icon(Icons.trending_up_rounded),
                            label: Text(
                              'topCharts',
                            ),
                          ),
                          NavigationRailDestination(
                            icon: Icon(Icons.youtube_searched_for),
                            label: Text('youTube'),
                          ),
                          NavigationRailDestination(
                            icon: Icon(Icons.my_library_music_rounded),
                            label: Text('library'),
                          ),
                        ],
                      );
                    },
                  ),
                Expanded(
                  child: Column(
                    children: [
                      Expanded(
                        child: PageView(
                          physics: const CustomPhysics(),
                          onPageChanged: (indx) {
                            _selectedIndex.value = indx;
                          },
                          controller: _pageController,
                          children: [
                            Stack(
                              children: [
                                // checkVersion(),
                                NestedScrollView(
                                  physics: const BouncingScrollPhysics(),
                                  controller: _scrollController,
                                  headerSliverBuilder: (
                                      BuildContext context,
                                      bool innerBoxScrolled,
                                      ) {
                                    return <Widget>[
                                      SliverAppBar(
                                        expandedHeight: 135,
                                        backgroundColor: Colors.transparent,
                                        elevation: 0,
                                        // pinned: true,
                                        toolbarHeight: 65,
                                        // floating: true,
                                        automaticallyImplyLeading: false,
                                        flexibleSpace: LayoutBuilder(
                                          builder: (
                                              BuildContext context,
                                              BoxConstraints constraints,
                                              ) {
                                            return FlexibleSpaceBar(
                                              // collapseMode: CollapseMode.parallax,
                                              background: GestureDetector(
                                                onTap: () async {
                                                  await showTextInputDialog(
                                                    context: context,
                                                    title: 'Name',
                                                    initialText: name,
                                                    keyboardType:
                                                    TextInputType.name,
                                                    onSubmitted: (value) {
                                                      Hive.box('settings').put(
                                                        'name',
                                                        value.trim(),
                                                      );
                                                      name = value.trim();
                                                      Navigator.pop(context);
                                                      updateUserDetails(
                                                        'name',
                                                        value.trim(),
                                                      );
                                                    },
                                                  );
                                                  setState(() {});
                                                },
                                                child: Column(
                                                  mainAxisSize:
                                                  MainAxisSize.min,
                                                  children: <Widget>[
                                                    const SizedBox(
                                                      height: 60,
                                                    ),
                                                    Row(
                                                      children: [
                                                        Padding(
                                                          padding:
                                                          const EdgeInsets
                                                              .only(
                                                            left: 15.0,
                                                          ),
                                                          child: Text(
                                                            'Welcome to Podly',
                                                            style: TextStyle(
                                                              letterSpacing: 2,
                                                              color: Theme.of(
                                                                context,
                                                              )
                                                                  .colorScheme
                                                                  .secondary,
                                                              fontSize: 30,
                                                              fontWeight:
                                                              FontWeight
                                                                  .bold,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    Padding(
                                                      padding:
                                                      const EdgeInsets.only(
                                                        left: 15.0,
                                                      ),
                                                      child: Row(
                                                        crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .end,
                                                        children: [
                                                          ValueListenableBuilder(
                                                            valueListenable:
                                                            Hive.box(
                                                              'settings',
                                                            ).listenable(),
                                                            builder: (
                                                                BuildContext
                                                                context,
                                                                Box box,
                                                                Widget? child,
                                                                ) {
                                                              return Text(
                                                                (box.get('name') ==
                                                                    null ||
                                                                    box.get('name') ==
                                                                        '')
                                                                    ? '게스트'
                                                                    : box
                                                                    .get(
                                                                  'name',
                                                                )
                                                                    .split(
                                                                  ' ',
                                                                )[0]
                                                                    .toString()
                                                                    .capitalize(),
                                                                style:
                                                                const TextStyle(
                                                                  letterSpacing:
                                                                  2,
                                                                  fontSize: 20,
                                                                  fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                                ),
                                                              );
                                                            },
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                      SliverAppBar(
                                        automaticallyImplyLeading: false,
                                        pinned: true,
                                        backgroundColor: Colors.transparent,
                                        elevation: 0,
                                        stretch: true,
                                        toolbarHeight: 65,
                                        title: Align(
                                          alignment: Alignment.centerRight,
                                          child: AnimatedBuilder(
                                            animation: _scrollController,
                                            builder: (context, child) {
                                              return GestureDetector(
                                                child: AnimatedContainer(
                                                  width: (!_scrollController
                                                      .hasClients ||
                                                      _scrollController
                                                      // ignore: invalid_use_of_protected_member
                                                          .positions
                                                          .length >
                                                          1)
                                                      ? MediaQuery.of(context)
                                                      .size
                                                      .width
                                                      : max(
                                                    MediaQuery.of(context)
                                                        .size
                                                        .width -
                                                        _scrollController
                                                            .offset
                                                            .roundToDouble(),
                                                    MediaQuery.of(context)
                                                        .size
                                                        .width -
                                                        75,
                                                  ),
                                                  height: 52.0,
                                                  duration: const Duration(
                                                    milliseconds: 150,
                                                  ),
                                                  padding:
                                                  const EdgeInsets.all(2.0),
                                                  // margin: EdgeInsets.zero,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                    BorderRadius.circular(
                                                      10.0,
                                                    ),
                                                    color: Theme.of(context)
                                                        .cardColor,
                                                    boxShadow: const [
                                                      BoxShadow(
                                                        color: Colors.black26,
                                                        blurRadius: 5.0,
                                                        offset:
                                                        Offset(1.5, 1.5),
                                                        // shadow direction: bottom right
                                                      )
                                                    ],
                                                  ),
                                                  child:
                                                  Row(
                                                    children: [
                                                      const SizedBox(
                                                        width: 10.0,
                                                      ),
                                                      Icon(
                                                        CupertinoIcons.search,
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .secondary,
                                                      ),
                                                      const SizedBox(
                                                        width: 10.0,
                                                      ),
                                                      Text(
                                                        'searchText',
                                                        style: TextStyle(
                                                          fontSize: 16.0,
                                                          color:
                                                          Theme.of(context)
                                                              .textTheme
                                                              .bodySmall!
                                                              .color,
                                                          fontWeight:
                                                          FontWeight.normal,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                // onTap: () => Navigator.push(
                                                //   context,
                                                //   MaterialPageRoute(
                                                //     builder: (context) =>
                                                //     const SearchPage(
                                                //       query: '',
                                                //       fromHome: true,
                                                //       autofocus: true,
                                                //     ),
                                                //   ),
                                                // ),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                    ];
                                  },
                                  body: const SaavnHomePage(),
                                ),
                                if (!rotated || screenWidth > 1050)
                                  Builder(
                                    builder: (context) => Padding(
                                      padding: const EdgeInsets.only(
                                        top: 8.0,
                                        left: 4.0,
                                      ),
                                      child: Transform.rotate(
                                        angle: 22 / 7 * 2,
                                        child: IconButton(
                                          icon: const Icon(
                                            Icons.horizontal_split_rounded,
                                          ),
                                          // color: Theme.of(context).iconTheme.color,
                                          onPressed: () {
                                            Scaffold.of(context).openDrawer();
                                          },
                                          tooltip:
                                          MaterialLocalizations.of(context)
                                              .openAppDrawerTooltip,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            TopCharts(
                              pageController: _pageController,
                            ),
                            const YouTube(),
                            const LibraryPage(),
                          ],
                        ),
                      ),
                      const MiniPlayer()
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked, // 버튼을 중앙에 배치

        bottomNavigationBar: rotated
            ? null
            : SafeArea(
          child: ValueListenableBuilder(
            valueListenable: _selectedIndex,
            builder:
                (BuildContext context, int indexValue, Widget? child) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 100),
                height: 60,
                child: SalomonBottomBar(
                  currentIndex: indexValue,
                  onTap: (index) {
                    _onItemTapped(index);
                  },
                  items: [
                    SalomonBottomBarItem(
                      icon: const Icon(Icons.home_rounded),
                      title: const Text('홈'),
                      selectedColor:
                      Theme.of(context).colorScheme.secondary,
                    ),
                    SalomonBottomBarItem(
                      icon: const Icon(Icons.trending_up_rounded),
                      title: const Text(
                        '챗봇',
                      ),
                      selectedColor:
                      Theme.of(context).colorScheme.secondary,
                    ),
                    SalomonBottomBarItem(
                      icon: const Icon(Icons.youtube_searched_for),
                      title: const Text('유튜브'),
                      selectedColor:
                      Theme.of(context).colorScheme.secondary,
                    ),
                    SalomonBottomBarItem(
                      icon: const Icon(Icons.my_library_music_rounded),
                      title: const Text('라이브러리'),
                      selectedColor:
                      Theme.of(context).colorScheme.secondary,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

bool fetched = false;
List preferredLanguage = Hive.box('settings')
    .get('preferredLanguage', defaultValue: ['Hindi']) as List;
List likedRadio =
Hive.box('settings').get('likedRadio', defaultValue: []) as List;
Map data = Hive.box('cache').get('homepage', defaultValue: {}) as Map;
List lists = ['recent', 'playlist', ...?data['collections']];
