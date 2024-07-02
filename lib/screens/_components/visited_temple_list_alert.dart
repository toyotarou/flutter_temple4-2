import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../extensions/extensions.dart';
import '../../models/temple_model.dart';
import '../../state/temple/temple.dart';
import '../../state/temple_lat_lng/temple_lat_lng.dart';
import '../_parts/_temple_dialog.dart';
import '../function.dart';
import 'visited_temple_map_alert.dart';

class VisitedTempleListAlert extends ConsumerStatefulWidget {
  const VisitedTempleListAlert({super.key});

  @override
  ConsumerState<VisitedTempleListAlert> createState() =>
      _VisitedTempleListAlertState();
}

class _VisitedTempleListAlertState
    extends ConsumerState<VisitedTempleListAlert> {
  List<int> yearList = [];

  List<GlobalKey> globalKeyList2 = [];

  ///
  @override
  void initState() {
    super.initState();

    ref.read(templeProvider.notifier).getAllTemple();

    ref.read(templeLatLngProvider.notifier).getAllTempleLatLng();

    globalKeyList2 = List.generate(100, (index) => GlobalKey());
  }

  ///
  @override
  Widget build(BuildContext context) {
    if (yearList.isEmpty) {
      yearList = makeTempleVisitYearList(ref: ref);
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final selectVisitedTempleListKey = ref.watch(
          templeProvider.select((value) => value.selectVisitedTempleListKey));

      if (selectVisitedTempleListKey != -1) {
        scrollToIndex(selectVisitedTempleListKey);
      }
    });

    return DefaultTabController(
      length: yearList.length,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.black.withOpacity(0.2),
        appBar: AppBar(
          title: Text(
            'Visited Temple',
            style: TextStyle(
              color: Colors.white.withOpacity(0.4),
              fontSize: 12,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          leading: const Icon(Icons.check_box_outline_blank,
              color: Colors.transparent),
          bottom: displayVisitedTempleListAppBar(),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Container(width: context.screenSize.width),
            Expanded(child: displayTempleList()),
          ],
        ),
      ),
    );
  }

  ///
  PreferredSize displayVisitedTempleListAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(20),
      child: Column(
        children: [
          displayVisitedTempleListTabBar(),
        ],
      ),
    );
  }

  ///
  Widget displayVisitedTempleListTabBar() {
    return TabBar(
      isScrollable: true,
      padding: EdgeInsets.zero,
      indicatorColor: Colors.transparent,
      indicatorWeight: 0.1,
      tabs: _getTabs(),
    );
  }

  ///
  List<Widget> _getTabs() {
    final list = <Widget>[];

    final selectVisitedTempleListKey = ref.watch(
        templeProvider.select((value) => value.selectVisitedTempleListKey));

    for (var i = 0; i < yearList.length; i++) {
      list.add(
        GestureDetector(
          onTap: () {
            ref
                .read(templeProvider.notifier)
                .setSelectVisitedTempleListKey(key: i);

            scrollToIndex(i);
          },
          child: Text(
            yearList[i].toString(),
            style: TextStyle(
                color: (selectVisitedTempleListKey == -1)
                    ? Colors.white
                    : (yearList[selectVisitedTempleListKey] == yearList[i])
                        ? Colors.yellowAccent
                        : Colors.white),
          ),
        ),
      );
    }

    return list;
  }

  ///
  Future<void> scrollToIndex(int index) async {
    final target = globalKeyList2[index].currentContext!;

    await Scrollable.ensureVisible(
      target,
      duration: const Duration(milliseconds: 1000),
    );
  }

  ///
  Widget displayTempleList() {
    final list = <Widget>[];

    final templeState = ref.watch(templeProvider);

    final roopList = List<TempleModel>.from(templeState.templeList);

    var keepY = '';
    var keepYm = '';
    roopList.forEach((element) {
      if (keepY != element.date.yyyy) {
        final pos =
            yearList.indexWhere((element2) => element2 == element.date.year);

        list.add(
          Container(
            padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 5),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.2)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(key: globalKeyList2[pos], element.date.yyyy),
                Container(),
              ],
            ),
          ),
        );
      }

      if (keepYm != element.date.yyyymm) {
        list.add(
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.white.withOpacity(0.1), Colors.transparent],
                stops: const [0.7, 1],
              ),
            ),
            margin: const EdgeInsets.only(bottom: 5),
            padding: const EdgeInsets.all(5),
            child: Text(element.date.yyyymm),
          ),
        );
      }

      list.add(displayVisitedMainTempleList(data: element));

      if (element.memo != '') {
        element.memo.split('、').forEach((element2) => list
            .add(displayVisitedSubTempleList(data: element, data2: element2)));
      }

      keepYm = element.date.yyyymm;
      keepY = element.date.yyyy;
    });

    return SingleChildScrollView(
      child: DefaultTextStyle(
        style: const TextStyle(fontSize: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: list,
        ),
      ),
    );
  }

  ///
  Widget displayVisitedMainTempleList({required TempleModel data}) {
    final templeLatLngMap = ref
        .watch(templeLatLngProvider.select((value) => value.templeLatLngMap));

    final templeState = ref.watch(templeProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.white.withOpacity(0.3)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.temple,
                  style: TextStyle(
                    color: (templeState.selectTempleName == data.temple)
                        ? Colors.yellowAccent
                        : Colors.white,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  data.date.yyyymmdd,
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              ref.read(templeProvider.notifier).setSelectTemple(
                    name: data.temple,
                    lat: (templeLatLngMap[data.temple] != null)
                        ? templeLatLngMap[data.temple]!.lat
                        : '',
                    lng: (templeLatLngMap[data.temple] != null)
                        ? templeLatLngMap[data.temple]!.lng
                        : '',
                  );

              Navigator.pop(context);
              Navigator.pop(context);

              TempleDialog(
                context: context,
                widget: const VisitedTempleMapAlert(),
                clearBarrierColor: true,
              );
            },
            child: Icon(
              Icons.location_on,
              color: (templeState.selectTempleName == data.temple)
                  ? Colors.yellowAccent.withOpacity(0.4)
                  : Colors.white.withOpacity(0.4),
            ),
          ),
        ],
      ),
    );
  }

  ///
  Widget displayVisitedSubTempleList(
      {required TempleModel data, required String data2}) {
    final templeLatLngMap = ref
        .watch(templeLatLngProvider.select((value) => value.templeLatLngMap));

    final templeState = ref.watch(templeProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.white.withOpacity(0.3)),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data2,
                  style: TextStyle(
                    color: (templeState.selectTempleName == data2)
                        ? Colors.yellowAccent
                        : Colors.white,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  data.date.yyyymmdd,
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              ref.read(templeProvider.notifier).setSelectTemple(
                    name: data2,
                    lat: (templeLatLngMap[data2] != null)
                        ? templeLatLngMap[data2]!.lat
                        : '',
                    lng: (templeLatLngMap[data2] != null)
                        ? templeLatLngMap[data2]!.lng
                        : '',
                  );

              Navigator.pop(context);
              Navigator.pop(context);

              TempleDialog(
                context: context,
                widget: const VisitedTempleMapAlert(),
                clearBarrierColor: true,
              );
            },
            child: Icon(
              Icons.location_on,
              color: (templeState.selectTempleName == data2)
                  ? Colors.yellowAccent.withOpacity(0.4)
                  : Colors.white.withOpacity(0.4),
            ),
          ),
        ],
      ),
    );
  }
}
