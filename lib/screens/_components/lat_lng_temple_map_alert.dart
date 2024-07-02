import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../extensions/extensions.dart';
import '../../models/common/temple_data.dart';
import '../../models/lat_lng_temple_model.dart';
import '../../models/tokyo_station_model.dart';
import '../../state/lat_lng_temple/lat_lng_temple.dart';
import '../../state/routing/routing.dart';
import '../../state/tokyo_train/tokyo_train.dart';
import '../_parts/_caution_dialog.dart';
import '../_parts/_temple_dialog.dart';
import '../function.dart';
import 'goal_station_setting_alert.dart';
import 'route_display_setting_alert.dart';
import 'temple_info_display_alert.dart';

class LatLngTempleMapAlert extends ConsumerStatefulWidget {
  const LatLngTempleMapAlert(
      {super.key, required this.templeList, this.station});

  final List<LatLngTempleModel> templeList;
  final TokyoStationModel? station;

  @override
  ConsumerState<LatLngTempleMapAlert> createState() =>
      _LatLngTempleDisplayAlertState();
}

class _LatLngTempleDisplayAlertState
    extends ConsumerState<LatLngTempleMapAlert> {
  List<TempleData> templeDataList = [];

  Map<String, double> boundsLatLngMap = {};

  double boundsInner = 0;

  List<Marker> markerList = [];

  List<int> reachedTempleIds = [];

  MapController mapController = MapController();
  late LatLng currentCenter;

  ///
  @override
  void initState() {
    super.initState();

    ref.read(tokyoTrainProvider.notifier).getTokyoTrain();

    currentCenter =
        LatLng(widget.station!.lat.toDouble(), widget.station!.lng.toDouble());
  }

  ///
  @override
  Widget build(BuildContext context) {
    final routingTempleDataList = ref
        .watch(routingProvider.select((value) => value.routingTempleDataList));

    //------------------// goal
    final tokyoTrainState = ref.watch(tokyoTrainProvider);

    final goalStationId =
        ref.watch(routingProvider.select((value) => value.goalStationId));
    //------------------// goal

    templeDataList = [];

    widget.templeList.forEach((element) {
      templeDataList.add(
        TempleData(
          name: element.name,
          address: element.address,
          latitude: element.latitude,
          longitude: element.longitude,
          mark: element.id.toString(),
          cnt: element.cnt,
        ),
      );
    });

    if (widget.station != null) {
      templeDataList.add(TempleData(
        name: widget.station!.stationName,
        address: widget.station!.address,
        latitude: widget.station!.lat,
        longitude: widget.station!.lng,
        mark: 'STA',
      ));
    }

    if (tokyoTrainState.tokyoStationMap[goalStationId] != null) {
      final goal = tokyoTrainState.tokyoStationMap[goalStationId];

      templeDataList.add(
        TempleData(
          name: goal!.stationName,
          address: goal.address,
          latitude: goal.lat,
          longitude: goal.lng,
          mark: goal.id,
        ),
      );
    }

    final boundsData = makeBounds(data: templeDataList);

    if (boundsData.isNotEmpty) {
      boundsLatLngMap = boundsData['boundsLatLngMap'];
      boundsInner = boundsData['boundsInner'];
    }

    makeMarker();

    return (boundsLatLngMap.isNotEmpty)
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (widget.station != null) ...[
                Column(
                  children: [
                    const SizedBox(height: 10),
                    displayLatLngTempleMapButtonWidget(),
                    Container(
                      width: context.screenSize.width,
                      margin: const EdgeInsets.all(5),
                      padding: const EdgeInsets.all(5),
                      decoration:
                          BoxDecoration(color: Colors.white.withOpacity(0.2)),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: context.screenSize.height / 15,
                        ),
                        child: displaySelectedRoutingTemple(),
                      ),
                    ),
                  ],
                ),
              ],
              Expanded(
                child: FlutterMap(
                  mapController: mapController,
                  options: MapOptions(
                    bounds: LatLngBounds(
                      LatLng(
                        boundsLatLngMap['minLat']! - boundsInner,
                        boundsLatLngMap['minLng']! - boundsInner,
                      ),
                      LatLng(
                        boundsLatLngMap['maxLat']! + boundsInner,
                        boundsLatLngMap['maxLng']! + boundsInner,
                      ),
                    ),
                    minZoom: 10,
                    maxZoom: 14,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    ),
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: routingTempleDataList.map((e) {
                            return LatLng(
                              e.latitude.toDouble(),
                              e.longitude.toDouble(),
                            );
                          }).toList(),
                          color: Colors.redAccent,
                          strokeWidth: 5,
                        ),
                      ],
                    ),
                    MarkerLayer(markers: markerList),
                  ],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(),
                  IconButton(
                    onPressed: () {
                      mapController.move(currentCenter, 13);
                    },
                    icon: const Icon(
                      Icons.center_focus_strong,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          )
        : Container();
  }

  ///
  Widget displayLatLngTempleMapButtonWidget() {
    final routingTempleDataList = ref
        .watch(routingProvider.select((value) => value.routingTempleDataList));

    //------------------// goal
    final tokyoTrainState = ref.watch(tokyoTrainProvider);

    final goalStationId =
        ref.watch(routingProvider.select((value) => value.goalStationId));
    //------------------// goal

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 60,
                      padding: const EdgeInsets.symmetric(vertical: 3),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.green[900]!.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Text(
                        'Start',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                        child: Text(
                      widget.station!.stationName,
                      style: const TextStyle(color: Colors.white),
                    )),
                  ],
                ),
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (routingTempleDataList.length < 2) {
                          caution_dialog(
                            context: context,
                            content: 'cant setting goal',
                          );

                          return;
                        }

                        TempleDialog(
                          context: context,
                          widget: const GoalStationSettingAlert(),
                          paddingLeft: context.screenSize.width * 0.2,
                          clearBarrierColor: true,
                        );
                      },
                      child: Container(
                        width: 60,
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.purpleAccent.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'Goal',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Text(
                        (tokyoTrainState.tokyoStationMap[goalStationId] != null)
                            ? tokyoTrainState
                                .tokyoStationMap[goalStationId]!.stationName
                            : '-----',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        ref.read(routingProvider.notifier).removeGoalStation();
                      },
                      child:
                          const Icon(Icons.close, color: Colors.purpleAccent),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          GestureDetector(
            onTap: () {
              TempleDialog(
                context: context,
                widget: RouteDisplaySettingAlert(),
                paddingLeft: context.screenSize.width * 0.1,
              );
            },
            child: const Icon(Icons.settings, color: Colors.white),
          ),
          const SizedBox(width: 20),
          GestureDetector(
            onTap: () {
              ref.read(latLngTempleProvider.notifier).setOrangeDisplay();
            },
            child: CircleAvatar(
              backgroundColor: Colors.orangeAccent.withOpacity(0.6),
              radius: 10,
            ),
          ),
        ],
      ),
    );
  }

  ///
  void makeMarker() {
    markerList = [];

    final orangeDisplay =
        ref.watch(latLngTempleProvider.select((value) => value.orangeDisplay));

    for (var i = 0; i < templeDataList.length; i++) {
      if (orangeDisplay) {
        if (templeDataList[i].cnt > 0) {
          continue;
        }
      }

      markerList.add(
        Marker(
          point: LatLng(
            templeDataList[i].latitude.toDouble(),
            templeDataList[i].longitude.toDouble(),
          ),
          builder: (context) {
            return GestureDetector(
              onTap: (templeDataList[i].mark == '0')
                  ? null
                  : () {
                      final exMarkLength =
                          templeDataList[i].mark.split('-').length;

                      if (exMarkLength == 2) {
                        return;
                      } else {
                        TempleDialog(
                          context: context,
                          widget: TempleInfoDisplayAlert(
                            temple: templeDataList[i],
                            from: 'LatLngTempleMapAlert',
                            station: widget.station,
                          ),
                          paddingTop: context.screenSize.height * 0.7,
                          clearBarrierColor: true,
                        );
                      }
                    },
              child: CircleAvatar(
                backgroundColor: getCircleAvatarBgColor(
                  element: templeDataList[i],
                  ref: ref,
                ),
                child: getCircleAvatarText(element: templeDataList[i]),
              ),
            );
          },
        ),
      );
    }
  }

  ///
  Widget getCircleAvatarText({required TempleData element}) {
    final routingTempleDataList = ref
        .watch(routingProvider.select((value) => value.routingTempleDataList));

    var str = '';
    if (element.mark == '0') {
      str = 'S';
    } else if (element.mark.split('-').length == 2) {
      if (routingTempleDataList.isNotEmpty &&
          routingTempleDataList[0].name == element.name) {
        str = 'S';
      } else {
        str = 'G';
      }
    } else {
      str = element.mark.padLeft(3, '0');
    }

    return Text(
      str,
      style: const TextStyle(
          color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
    );
  }

  ///
  Widget displaySelectedRoutingTemple() {
    final list = <Widget>[];

    final routingTempleDataList = ref
        .watch(routingProvider.select((value) => value.routingTempleDataList));

    for (var i = 1; i < routingTempleDataList.length; i++) {
      final distance = calcDistance(
        originLat: routingTempleDataList[i - 1].latitude.toDouble(),
        originLng: routingTempleDataList[i - 1].longitude.toDouble(),
        destLat: routingTempleDataList[i].latitude.toDouble(),
        destLng: routingTempleDataList[i].longitude.toDouble(),
      );

      list.add(
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.only(top: 5),
              width: 40,
              decoration: const BoxDecoration(
                border: Border(top: BorderSide(color: Colors.white)),
              ),
              alignment: Alignment.topRight,
              child: Text(distance,
                  style: const TextStyle(fontSize: 10, color: Colors.white)),
            ),
            Container(
              margin: const EdgeInsets.all(3),
              padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 15),
              decoration: (routingTempleDataList[i].mark.split('-').length != 2)
                  ? BoxDecoration(
                      color: (routingTempleDataList[i].cnt > 0)
                          ? Colors.pinkAccent.withOpacity(0.5)
                          : Colors.orangeAccent.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(10),
                    )
                  : null,
              child: (routingTempleDataList[i].mark.split('-').length != 2)
                  ? Text(routingTempleDataList[i].mark,
                      style: const TextStyle(fontSize: 10, color: Colors.white))
                  : const Text(''),
            ),
          ],
        ),
      );
    }

    return (list.isNotEmpty)
        ? Wrap(children: list)
        : Text(
            'No Routing',
            style: TextStyle(color: Colors.white.withOpacity(0.6)),
          );
  }
}
