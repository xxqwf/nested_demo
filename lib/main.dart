import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

void main() {
  runApp(MaterialApp(home: NativeScrollWithCollapseAppBar()));
}

class NativeScrollWithCollapseAppBar extends StatefulWidget {
  @override
  State<NativeScrollWithCollapseAppBar> createState() =>
      _NativeScrollWithCollapseAppBarState();
}

class _NativeScrollWithCollapseAppBarState
    extends State<NativeScrollWithCollapseAppBar>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late TabController _tabController2;
  final tabs = ['Booking 1', 'Booking 2'];
  final tabs2 = ['Request 1', 'Request 2'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: tabs.length, vsync: this);
    _tabController2 = TabController(length: tabs.length, vsync: this);
  }

  ValueNotifier<int> currentIndex = ValueNotifier(0);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: currentIndex,
      builder: (BuildContext context, int value, Widget? child) {
        return Scaffold(
          body: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverAppBar(
                  title: Text('Tab 滚动 + AppBar 折叠'),
                  pinned: true,
                  floating: true,
                  forceElevated: innerBoxIsScrolled,
                  bottom: TabBar(
                    controller: value == 0 ? _tabController : _tabController2,
                    tabs: (value == 0 ? tabs : tabs2)
                        .map((e) => Tab(text: e))
                        .toList(),
                  ),
                ),
                // SliverPersistentHeader(
                //   pinned: true,
                //   delegate: _SliverAppBarDelegate(
                //     SizedBox(
                //       width: double.infinity,
                //       height: 50,
                //       child: ValueListenableBuilder(
                //         valueListenable: currentIndex,
                //         builder:
                //             (BuildContext context, int value, Widget? child) {
                //               return TabBar(
                //                 controller: value == 0
                //                     ? _tabController
                //                     : _tabController2,
                //                 tabs: (value == 0 ? tabs : tabs2)
                //                     .map((e) => Tab(text: e))
                //                     .toList(),
                //               );
                //             },
                //       ),
                //     ),
                //   ),
                // ),
              ];
            },
            body: TabBarView(
              physics: NeverScrollableScrollPhysics(),
              controller: value == 0 ? _tabController : _tabController2,
              children: (value == 0 ? tabs : tabs2).map((tabTitle) {
                return SafeArea(
                  top: false,
                  child: Builder(
                    builder: (context) {
                      return ListView.builder(
                        key: PageStorageKey(tabTitle),
                        primary: true,
                        physics: ClampingScrollPhysics(),
                        padding: EdgeInsets.zero,
                        itemCount: 30,
                        itemBuilder: (context, index) {
                          return ListTile(
                            title: Text('$tabTitle - 第 $index 项'),
                          );
                        },
                      );
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          bottomNavigationBar: PFBottomNavigationBar((int index) {
            currentIndex.value = index;
          }, currentIndex),
        );
      },
    );
  }
}

// ignore: must_be_immutable
class PFBottomNavigationBar extends StatelessWidget {
  void Function(int)? onTap;
  final ValueNotifier<int> currentIndex;

  PFBottomNavigationBar(this.onTap, this.currentIndex, {super.key});

  final List<Map<String, String>> bottomNavigationBarItems = [
    {'icon': 'assets/images/booking_selected.svg', 'text': 'Booking'},
    {'icon': 'assets/images/requests_unselected.svg', 'text': 'Requests'},
    {
      'icon': 'assets/images/notifications_unselected.svg',
      'text': 'Notification',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 360,
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Color(0x19000000),
            blurRadius: 10,
            offset: Offset(0, -4),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(child: buildItem(0)),
          Expanded(child: buildItem(1)),
          Expanded(child: buildItem(2)),
        ],
      ),
    );
  }

  Widget buildItem(int index) {
    Map<String, String> item = bottomNavigationBarItems[index];
    String icon = item["icon"]!;
    String text = item["text"]!;
    return GestureDetector(
      onTap: () {
        onTap?.call(index);
      },
      child: Container(
        height: 72,
        decoration: BoxDecoration(color: Colors.white),
        child: ValueListenableBuilder(
          valueListenable: currentIndex,
          builder: (BuildContext context, int value, Widget? child) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              spacing: 6,
              children: [
                SvgPicture.asset(
                  icon,
                  colorFilter: ColorFilter.mode(
                    value == index ? Color(0xFF92722A) : Color(0xFF5F646D),
                    BlendMode.srcIn,
                  ),
                ),
                SizedBox(
                  width: 90,
                  child: Text(
                    text,
                    textAlign: TextAlign.center,
                    style: value == index
                        ? TextStyle(
                            color: const Color(0xFF92722A),
                            fontSize: 12,
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w600,
                            height: 1.33,
                          )
                        : TextStyle(
                            color: const Color(0xFF5F646D),
                            fontSize: 12,
                            fontFamily: 'Roboto',
                            fontWeight: FontWeight.w600,
                            height: 1.33,
                          ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this.tabBar);

  final Widget tabBar;

  @override
  double get minExtent => 50;

  @override
  double get maxExtent => 50;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(color: Colors.white, child: tabBar);
  }

  @override
  bool shouldRebuild(covariant _SliverAppBarDelegate oldDelegate) {
    return false;
  }
}

// import 'dart:io';
//
// import 'package:flutter/material.dart';
//
// void main() => runApp(MyApp());
//
// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Demo',
//       theme: ThemeData(primaryColor: Colors.white),
//       home: NewsScreen(),
//       debugShowCheckedModeBanner: false,
//     );
//   }
// }
//
// class NewsScreen extends StatefulWidget {
//   @override
//   State<StatefulWidget> createState() => _NewsScreenState();
// }
//
// class _NewsScreenState extends State<NewsScreen> {
//   final List<String> _tabs = <String>["Featured", "Popular", "Latest"];
//
//   @override
//   Widget build(BuildContext context) {
//     return Material(
//       child: Scaffold(
//         body: DefaultTabController(
//           length: _tabs.length,
//           child: NestedScrollView(
//             headerSliverBuilder:
//                 (BuildContext context, bool innerBoxIsScrolled) {
//                   return <Widget>[
//                     SliverOverlapAbsorber(
//                       handle: NestedScrollView.sliverOverlapAbsorberHandleFor(
//                         context,
//                       ),
//                       sliver: SliverSafeArea(
//                         top: false,
//                         bottom: Platform.isIOS ? false : true,
//                         sliver: SliverAppBar(
//                           title: Text('Tab Demo'),
//                           floating: true,
//                           pinned: true,
//                           snap: true,
//                           forceElevated: innerBoxIsScrolled,
//                           bottom: TabBar(
//                             tabs: _tabs
//                                 .map((String name) => Tab(text: name))
//                                 .toList(),
//                           ),
//                         ),
//                       ),
//                     ),
//                   ];
//                 },
//             body: TabBarView(
//               children: _tabs.map((String name) {
//                 return SafeArea(
//                   top: false,
//                   bottom: false,
//                   child: Builder(
//                     builder: (BuildContext context) {
//                       return NotificationListener<ScrollNotification>(
//                         onNotification: (scrollNotification) {
//                           return true;
//                         },
//                         child: CustomScrollView(
//                           key: PageStorageKey<String>(name),
//                           slivers: <Widget>[
//                             SliverOverlapInjector(
//                               handle:
//                                   NestedScrollView.sliverOverlapAbsorberHandleFor(
//                                     context,
//                                   ),
//                             ),
//                             SliverPadding(
//                               padding: const EdgeInsets.all(8.0),
//                               sliver: SliverList(
//                                 delegate: SliverChildBuilderDelegate((
//                                   BuildContext context,
//                                   int index,
//                                 ) {
//                                   return Column(
//                                     children: <Widget>[
//                                       Container(
//                                         height: 150,
//                                         width: double.infinity,
//                                         color: Colors.blueGrey,
//                                         child: Column(
//                                           mainAxisAlignment:
//                                               MainAxisAlignment.center,
//                                           children: <Widget>[
//                                             Text('$name $index'),
//                                           ],
//                                         ),
//                                       ),
//                                       SizedBox(height: 8),
//                                     ],
//                                   );
//                                 }, childCount: 30),
//                               ),
//                             ),
//                           ],
//                         ),
//                       );
//                     },
//                   ),
//                 );
//               }).toList(),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
