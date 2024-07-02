import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../extensions/extensions.dart';
import '../models/temple_model.dart';
import '../state/temple/temple.dart';
import '../utility/utility.dart';
import '_components/not_reach_temple_map_alert.dart';
import '_components/temple_detail_map_alert.dart';
import '_components/temple_train_station_list_alert.dart';
import '_components/visited_temple_map_alert.dart';
import '_parts/_temple_dialog.dart';
import 'function.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  List<int> yearList = [];

  List<GlobalKey> globalKeyList = [];

  Utility utility = Utility();

  TextEditingController searchWordEditingController = TextEditingController();

  ///
  @override
  void initState() {
    super.initState();

    ref.read(templeProvider.notifier).getAllTemple();

    globalKeyList = List.generate(100, (index) => GlobalKey());
  }

  ///
  @override
  Widget build(BuildContext context) {
    if (yearList.isEmpty) {
      yearList = makeTempleVisitYearList(ref: ref);
    }

    return DefaultTabController(
      length: yearList.length,
      child: Container(
        width: context.screenSize.width,
        height: context.screenSize.height,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/bg.png'),
            fit: BoxFit.fitHeight,
          ),
        ),
        child: Scaffold(
          resizeToAvoidBottomInset: false,
          backgroundColor: Colors.black.withOpacity(0.7),
          appBar: AppBar(
            title: Text(
              'Temple List',
              style: TextStyle(color: Colors.white.withOpacity(0.4)),
            ),
            centerTitle: true,
            backgroundColor: Colors.transparent,
            bottom: displayHomeAppBar(),
          ),
          body: Column(
            children: [
              const SizedBox(height: 10),
              Expanded(child: displayTempleList()),
            ],
          ),
        ),
      ),
    );
  }

  ///
  PreferredSize displayHomeAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(120),
      child: Column(
        children: [
          displayHomeButton(),
          displaySearchForm(),
          const SizedBox(height: 10),
          displayHomeTabBar(),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  ///
  Widget displayHomeTabBar() {
    final templeState = ref.watch(templeProvider);

    if (templeState.doSearch == true) {
      return Container(
        height: 40,
        margin: const EdgeInsets.symmetric(vertical: 3, horizontal: 10),
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.1)),
      );
    }

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

    final selectYear =
        ref.watch(templeProvider.select((value) => value.selectYear));

    for (var i = 0; i < yearList.length; i++) {
      list.add(
        GestureDetector(
          onTap: () {
            ref
                .read(templeProvider.notifier)
                .setSelectYear(year: yearList[i].toString());

            scrollToIndex(i);
          },
          child: Text(
            yearList[i].toString(),
            style: TextStyle(
                color: (selectYear == yearList[i].toString())
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
    final target = globalKeyList[index].currentContext!;

    await Scrollable.ensureVisible(
      target,
      duration: const Duration(milliseconds: 1000),
    );
  }

  ///
  Widget displayHomeButton() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            IconButton(
              onPressed: () {
                ref
                    .read(templeProvider.notifier)
                    .setSelectTemple(name: '', lat: '', lng: '');

                ref
                    .read(templeProvider.notifier)
                    .setSelectVisitedTempleListKey(key: -1);

                TempleDialog(
                  context: context,
                  widget: const VisitedTempleMapAlert(),
                  clearBarrierColor: true,
                );
              },
              icon: const Icon(Icons.map, color: Colors.white),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          decoration: BoxDecoration(
            color: Colors.orangeAccent.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              IconButton(
                onPressed: () => TempleDialog(
                  context: context,
                  widget: const TempleTrainStationListAlert(),
                ),
                icon: const Icon(Icons.train, color: Colors.white),
              ),
              IconButton(
                onPressed: () => TempleDialog(
                  context: context,
                  widget: const NotReachTempleMapAlert(),
                ),
                icon:
                    const Icon(FontAwesomeIcons.toriiGate, color: Colors.white),
              ),
              const SizedBox(width: 20),
            ],
          ),
        ),
      ],
    );
  }

  ///
  Widget displaySearchForm() {
    return Row(
      children: [
        IconButton(
          onPressed: () {
            searchWordEditingController.text = '';

            ref.read(templeProvider.notifier).clearSearch();
          },
          icon: const Icon(Icons.close, color: Colors.white),
        ),
        Expanded(
          child: TextFormField(
            autovalidateMode: AutovalidateMode.onUserInteraction,
            controller: searchWordEditingController,
            decoration: InputDecoration(
              isDense: true,
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              filled: true,
              fillColor: Colors.white.withOpacity(0.2),
              border: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey),
              ),
              focusedBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey),
              ),
              enabledBorder: const OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey),
              ),
            ),
            onTapOutside: (event) =>
                FocusManager.instance.primaryFocus?.unfocus(),
            onChanged: (value) {},
          ),
        ),
        IconButton(
          onPressed: () => ref
              .read(templeProvider.notifier)
              .doSearch(searchWord: searchWordEditingController.text),
          icon: const Icon(Icons.search, color: Colors.white),
        ),
      ],
    );
  }

  ///
  Widget displayTempleList() {
    final list = <Widget>[];

    final templeState = ref.watch(templeProvider);

    var keepYear = 0;
    var i = 0;
    templeState.templeList.forEach((element) {
      if (keepYear != element.date.year) {
        if (templeState.doSearch == false) {
          list.add(Container(
            key: globalKeyList[i],
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
            ),
            padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            child: DefaultTextStyle(
              style: const TextStyle(color: Colors.white),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(element.date.year.toString()),
                  Text((templeState.templeCountMap[element.date.yyyy] != null)
                      ? templeState.templeCountMap[element.date.yyyy]!.length
                          .toString()
                      : 0.toString()),
                ],
              ),
            ),
          ));
        }

        i++;
      }

      var dispFlag = true;

      if (templeState.doSearch) {
        final reg = RegExp(templeState.searchWord);

        if (reg.firstMatch(element.temple) != null ||
            reg.firstMatch(element.memo) != null) {
          dispFlag = true;
        } else {
          dispFlag = false;
        }
      }

      if (dispFlag) {
        list.add(
          displayHomeCard(data: element, selectYear: templeState.selectYear),
        );
      }

      keepYear = element.date.year;
    });

    return SingleChildScrollView(child: Column(children: list));
  }

  ///
  Widget displayHomeCard(
      {required TempleModel data, required String selectYear}) {
    final templeState = ref.watch(templeProvider);

    return Card(
      color: Colors.black.withOpacity(0.3),
      child: ListTile(
        leading: SizedBox(
          width: 40,
          child: (data.date.year.toString() == selectYear ||
                  templeState.searchWord != '')
              ? CachedNetworkImage(
                  imageUrl: data.thumbnail,
                  placeholder: (context, url) =>
                      Image.asset('assets/images/no_image.png'),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                )
              : Container(
                  decoration:
                      BoxDecoration(color: Colors.grey.withOpacity(0.3)),
                ),
        ),
        title: DefaultTextStyle(
          style: const TextStyle(fontSize: 12),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: context.screenSize.height / 8,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [Container(), Text(data.date.yyyymmdd)],
                ),
                Text(data.temple),
                const SizedBox(height: 5),
                Text(data.address),
                const SizedBox(height: 5),
                Text(
                  data.memo,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
        trailing: Column(
          children: [
            GestureDetector(
              onTap: () => TempleDialog(
                context: context,
                widget: TempleDetailMapAlert(date: data.date),
              ),
              child: const Icon(
                Icons.call_made,
                color: Colors.white,
              ),
            ),
            CircleAvatar(
              radius: 15,
              backgroundColor: utility.getLeadingBgColor(
                month: data.date.yyyymmdd.split('-')[1],
              ),
              child: Text(
                data.date.yyyymmdd.split('-')[1],
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
