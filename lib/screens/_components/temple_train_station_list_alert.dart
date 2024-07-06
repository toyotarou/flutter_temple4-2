import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../extensions/extensions.dart';
import '../../models/station_model.dart';
import '../../models/temple_list_model.dart';
import '../../models/temple_model.dart';
import '../../models/tokyo_station_model.dart';
import '../../models/tokyo_train_model.dart';
import '../../state/lat_lng_temple/lat_lng_temple.dart';
import '../../state/routing/routing.dart';
import '../../state/temple_list/temple_list.dart';
import '../_parts/_caution_dialog.dart';
import '../_parts/_temple_dialog.dart';
import 'lat_lng_temple_map_alert.dart';
import 'not_reach_temple_station_list_alert.dart';

class TempleTrainStationListAlert extends ConsumerStatefulWidget {
  const TempleTrainStationListAlert({
    super.key,
    required this.templeVisitDateMap,
    required this.dateTempleMap,
    required this.tokyoTrainList,
    required this.tokyoStationMap,
    required this.tokyoTrainIdMap,
    required this.templeListMap,
    required this.stationMap,
  });

  final Map<String, List<String>> templeVisitDateMap;
  final Map<String, TempleModel> dateTempleMap;
  final List<TokyoTrainModel> tokyoTrainList;
  final Map<String, TokyoStationModel> tokyoStationMap;
  final Map<int, TokyoTrainModel> tokyoTrainIdMap;
  final Map<String, TempleListModel> templeListMap;
  final Map<String, StationModel> stationMap;

  @override
  ConsumerState<TempleTrainStationListAlert> createState() =>
      _TempleTrainListAlertState();
}

class _TempleTrainListAlertState
    extends ConsumerState<TempleTrainStationListAlert> {
  int reachTempleNum = 0;

  ///
  @override
  void initState() {
    super.initState();

//    ref.read(tokyoTrainProvider.notifier).getTokyoTrain();
  }

  ///
  @override
  Widget build(BuildContext context) {
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
            DefaultTextStyle(
              style: const TextStyle(fontSize: 12),
              child: Column(
                children: [
                  displaySelectedStation(),
                  displayTempleTrainStationListButton(),
                ],
              ),
            ),
            const SizedBox(height: 20),
            displayTokyoTrainList(),
          ],
        ),
      ),
    );
  }

  ///
  Widget displayTempleTrainStationListButton() {
//    final tokyoTrainState = ref.watch(tokyoTrainProvider);

    final startStationId =
        ref.watch(routingProvider.select((value) => value.startStationId));

    final latLngTempleList = ref
        .watch(latLngTempleProvider.select((value) => value.latLngTempleList));

    final templeStationMap =
        ref.watch(templeListProvider.select((value) => value.templeStationMap));

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(),
        Row(
          children: [
            IconButton(
              onPressed: () {
                TempleDialog(
                  context: context,
                  widget: NotReachTempleStationListAlert(
                    tokyoTrainList: widget.tokyoTrainList,
                    templeStationMap: templeStationMap,
                  ),
                  paddingLeft: context.screenSize.width * 0.2,
                );
              },
              icon: Icon(
                Icons.train,
                color: Colors.white.withOpacity(0.4),
              ),
            ),
            IconButton(
              onPressed: (startStationId == '')
                  ? null
                  : () {
                      if (latLngTempleList.isEmpty) {
                        caution_dialog(context: context, content: 'no hit');

                        return;
                      }

                      ref
                          .read(routingProvider.notifier)
                          .clearRoutingTempleDataList();

                      ref
                          .read(routingProvider.notifier)
                          .setGoalStationId(id: '');

                      TempleDialog(
                        context: context,
                        widget: LatLngTempleMapAlert(
                          templeList: latLngTempleList,
                          station: widget.tokyoStationMap[startStationId],
                          tokyoTrainList: widget.tokyoTrainList,
                          tokyoStationMap: widget.tokyoStationMap,
                          tokyoTrainIdMap: widget.tokyoTrainIdMap,
                          templeVisitDateMap: widget.templeVisitDateMap,
                          dateTempleMap: widget.dateTempleMap,
                          templeListMap: widget.templeListMap,
                          stationMap: widget.stationMap,
                        ),
                      );
                    },
              icon: Icon(
                Icons.map,
                color: (startStationId != '' && latLngTempleList.isNotEmpty)
                    ? Colors.yellowAccent.withOpacity(0.4)
                    : Colors.white.withOpacity(0.4),
              ),
            ),
          ],
        ),
      ],
    );
  }

  ///
  Widget displaySelectedStation() {
//    final tokyoTrainState = ref.watch(tokyoTrainProvider);

    final startStationId =
        ref.watch(routingProvider.select((value) => value.startStationId));

    final latLngTempleList = ref
        .watch(latLngTempleProvider.select((value) => value.latLngTempleList));

    getReachTempleNum();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          (widget.tokyoStationMap[startStationId] != null)
              ? widget.tokyoStationMap[startStationId]!.stationName
              : '-----',
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(latLngTempleList.length.toString()),
            Text(reachTempleNum.toString()),
            Text(
              (latLngTempleList.length - reachTempleNum).toString(),
              style: const TextStyle(color: Colors.orangeAccent),
            ),
          ],
        ),
      ],
    );
  }

  ///
  Widget displayTokyoTrainList() {
//    final tokyoTrainState = ref.watch(tokyoTrainProvider);

    final startStationId =
        ref.watch(routingProvider.select((value) => value.startStationId));

    return Expanded(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: widget.tokyoTrainList.map((e) {
            return ExpansionTile(
              collapsedIconColor: Colors.white,
              title: Text(
                e.trainName,
                style: const TextStyle(fontSize: 12, color: Colors.white),
              ),
              children: e.station.map((e2) {
                return Container(
                  padding: const EdgeInsets.all(10),
                  margin: const EdgeInsets.only(bottom: 10),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color: Colors.white.withOpacity(0.3),
                      ),
                    ),
                  ),
                  child: DefaultTextStyle(
                    style: TextStyle(
                      color: (e2.id == startStationId)
                          ? Colors.yellowAccent
                          : Colors.white,
                      fontSize: 12,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(e2.stationName),
                        GestureDetector(
                          onTap: () {
                            ref
                                .read(latLngTempleProvider.notifier)
                                .getLatLngTemple(param: {
                              'latitude': e2.lat,
                              'longitude': e2.lng,
                            });

                            ref
                                .read(routingProvider.notifier)
                                .setStartStationId(id: e2.id);
                          },
                          child: Icon(
                            Icons.location_on,
                            color: (e2.id == startStationId)
                                ? Colors.yellowAccent.withOpacity(0.4)
                                : Colors.white.withOpacity(0.4),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            );
          }).toList(),
        ),
      ),
    );
  }

  ///
  void getReachTempleNum() {
    reachTempleNum = 0;

    ref
        .watch(latLngTempleProvider.select((value) => value.latLngTempleList))
        .forEach((element) {
      if (element.cnt > 0) {
        reachTempleNum++;
      }
    });
  }
}
