import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:sliver_tools/sliver_tools.dart';

// [SliverOverlapAbsorber] and [SliverOverlapInjector] 用于解决Appbar收缩时非当前显示的滑动组件出现的‘初始滑动偏移’
// [CustomScrollView] 增加 PageStorageKey 用于缓存当前滑动偏移位置
// CustomScrollView 的 primary: true 表示该滚动视图是“主要滚动视图”, 用于与NestedScrollView的滑动联动

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
  ValueNotifier<int> bottomNavigationIndex = ValueNotifier(0);

  final List<String> bookingTabs = ['Booking 1', 'Booking 2'];
  final List<String> requestTabs = ['Request 1', 'Request 2', 'Request 3'];
  final List<String> notificationTabs = ['Notification 1', 'Notification 2'];

  late TabController _bookingTabController;
  late TabController _requestTabController;
  late TabController _notificationTabController;

  @override
  void initState() {
    super.initState();
    _bookingTabController = TabController(
      length: bookingTabs.length,
      vsync: this,
    );
    _requestTabController = TabController(
      length: requestTabs.length,
      vsync: this,
    );
    _notificationTabController = TabController(
      length: notificationTabs.length,
      vsync: this,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: bottomNavigationIndex,
      builder: (BuildContext context, int value, Widget? child) {
        return Scaffold(
          body: NestedScrollView(
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverOverlapAbsorber(
                  handle: NestedScrollView.sliverOverlapAbsorberHandleFor(
                    context,
                  ),
                  sliver: MultiSliver(
                    children: [
                      SliverAppBar(
                        expandedHeight: 135,
                        flexibleSpace: FlexibleSpaceBar(
                          title: Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Manage for',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  'Rashid Al Mazrouei',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          background: Container(
                            alignment: Alignment.center,
                            padding: EdgeInsets.symmetric(horizontal: 20),
                            child: Row(
                              children: [
                                Text(
                                  'Good morning\nAhmed',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        backgroundColor: Color(0xFFCBA344),
                        pinned: true,
                        floating: true,
                        forceElevated: innerBoxIsScrolled,
                        // bottom: PreferredSize(
                        //   preferredSize: Size.fromHeight(60),
                        //   child: Container(
                        //     color: Color(0xFFCBA344),
                        //     padding: EdgeInsets.symmetric(
                        //       horizontal: 20,
                        //       vertical: 10,
                        //     ),
                        //     child: Row(
                        //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        //       children: [
                        //         Text('Manage for'),
                        //         Text('Rashid Al Mazrouei'),
                        //       ],
                        //     ),
                        //   ),
                        // ),
                      ),
                      SliverToBoxAdapter(
                        child: Container(
                          height: 100,
                          width: double.infinity,
                          color: Colors.green,
                        ),
                      ),
                      SliverPersistentHeader(
                        pinned: true,
                        delegate: _SliverAppBarDelegate(
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ValueListenableBuilder(
                              valueListenable: bottomNavigationIndex,
                              builder:
                                  (
                                    BuildContext context,
                                    int value,
                                    Widget? child,
                                  ) {
                                    return TabBar(
                                      controller: _currentTabController(value),
                                      tabs: _currentTabs(
                                        value,
                                      ).map((e) => Tab(text: e)).toList(),
                                    );
                                  },
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ];
            },
            body: TabBarView(
              physics: NeverScrollableScrollPhysics(),
              controller: _currentTabController(value),
              children: _currentTabs(value).map((tabTitle) {
                return SafeArea(
                  top: false,
                  child: Builder(
                    builder: (context) {
                      return CustomScrollView(
                        key: PageStorageKey(tabTitle),
                        primary: true,
                        physics: ClampingScrollPhysics(),
                        slivers: [
                          SliverOverlapInjector(
                            handle:
                                NestedScrollView.sliverOverlapAbsorberHandleFor(
                                  context,
                                ),
                          ),
                          SliverList.builder(
                            itemCount: 30,
                            itemBuilder: (BuildContext context, int index) {
                              return ListTile(
                                title: Text('$tabTitle - 第 $index 项'),
                              );
                            },
                          ),
                        ],
                      );
                    },
                  ),
                );
              }).toList(),
            ),
          ),
          bottomNavigationBar: PFBottomNavigationBar((int index) {
            bottomNavigationIndex.value = index;
          }, bottomNavigationIndex),
        );
      },
    );
  }

  TabController _currentTabController(int index) {
    if (index == 0) {
      return _bookingTabController;
    } else if (index == 1) {
      return _requestTabController;
    } else {
      return _notificationTabController;
    }
  }

  List<String> _currentTabs(int index) {
    if (index == 0) {
      return bookingTabs;
    } else if (index == 1) {
      return requestTabs;
    } else {
      return notificationTabs;
    }
  }
}

// ignore: must_be_immutable
class PFBottomNavigationBar extends StatelessWidget {
  void Function(int)? onTap;
  final ValueNotifier<int> bottomNavigationIndexIndex;

  PFBottomNavigationBar(
    this.onTap,
    this.bottomNavigationIndexIndex, {
    super.key,
  });

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
          valueListenable: bottomNavigationIndexIndex,
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
