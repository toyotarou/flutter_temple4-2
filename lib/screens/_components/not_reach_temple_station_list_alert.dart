import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../extensions/extensions.dart';
import '../../models/tokyo_station_model.dart';
import '../../state/temple_list/temple_list.dart';
import '../../state/tokyo_train/tokyo_train.dart';

class NotReachTempleStationListAlert extends ConsumerStatefulWidget {
  const NotReachTempleStationListAlert({super.key});

  @override
  ConsumerState<NotReachTempleStationListAlert> createState() =>
      _TempleNotReachStationListAlertState();
}

class _TempleNotReachStationListAlertState
    extends ConsumerState<NotReachTempleStationListAlert> {
  List<String> notReachTrainIds = [];
  List<String> notReachStationIds = [];

  ///
  @override
  void initState() {
    super.initState();

    ref.read(tokyoTrainProvider.notifier).getTokyoTrain();

    ref.read(templeNotReachListProvider.notifier).getAllNotReachTemple();
  }

  ///
  @override
  Widget build(BuildContext context) {
    makeNotReachTempleIds();

    return AlertDialog(
      titlePadding: EdgeInsets.zero,
      contentPadding: EdgeInsets.zero,
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.zero,
      content: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        width: double.infinity,
        height: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Container(width: context.screenSize.width),
            Expanded(child: displayNotReachTrain()),
          ],
        ),
      ),
    );
  }

  ///
  Widget displayNotReachTrain() {
    final tokyoTrainList =
        ref.watch(tokyoTrainProvider.select((value) => value.tokyoTrainList));

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: tokyoTrainList.map((e) {
          if (notReachTrainIds.contains(e.trainNumber.toString())) {
            return ExpansionTile(
              collapsedIconColor: Colors.white,
              title: Text(
                e.trainName,
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
              children: e.station.map((e2) {
                if (notReachStationIds.contains(e2.id)) {
                  return displayNotReachStation(data: e2);
                } else {
                  return Container();
                }
              }).toList(),
            );
          } else {
            return Container();
          }
        }).toList(),
      ),
    );
  }

  ///
  Widget displayNotReachStation({required TokyoStationModel data}) {
    final templeStationMap = ref.watch(
        templeNotReachListProvider.select((value) => value.templeStationMap));

    return Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.white.withOpacity(0.3)),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            data.stationName,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
          Text(
            (templeStationMap[data.id] != null)
                ? templeStationMap[data.id]!.length.toString()
                : '0',
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }

  ///
  void makeNotReachTempleIds() {
    ref
        .watch(templeNotReachListProvider
            .select((value) => value.templeStationMap))
        .forEach((key, value) {
      notReachTrainIds.add(key.split('-')[0]);

      notReachStationIds.add(key);
    });
  }
}
