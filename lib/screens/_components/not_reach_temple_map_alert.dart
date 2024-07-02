import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_temple4/screens/_components/not_reach_temple_train_select_alert.dart';
import 'package:flutter_temple4/state/tokyo_train/tokyo_train.dart';
import 'package:flutter_temple4/utility/utility.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../extensions/extensions.dart';
import '../../models/common/temple_data.dart';
import '../../state/temple_lat_lng/temple_lat_lng.dart';
import '../../state/temple_list/temple_list.dart';
import '../_parts/_temple_dialog.dart';
import '../function.dart';
import 'temple_info_display_alert.dart';

class NotReachTempleMapAlert extends ConsumerStatefulWidget {
  const NotReachTempleMapAlert({super.key});

  @override
  ConsumerState<NotReachTempleMapAlert> createState() =>
      _NotReachTempleMapAlertState();
}

class _NotReachTempleMapAlertState
    extends ConsumerState<NotReachTempleMapAlert> {
  List<TempleData> templeDataList = [];

  Map<String, double> boundsLatLngMap = {};

  double boundsInner = 0;

  List<Marker> markerList = [];

  MapController mapController = MapController();
  late LatLng currentCenter;

  List<Polyline> polylineList = [];

  Utility utility = Utility();

  ///
  @override
  void initState() {
    super.initState();

    ref.read(templeListProvider.notifier).getAllTempleListTemple();

    ref.read(templeLatLngProvider.notifier).getAllTempleLatLng();

    ref.read(tokyoTrainProvider.notifier).getTokyoTrain();

    currentCenter = LatLng('35.7185071'.toDouble(), '139.5869534'.toDouble());
  }

  ///
  @override
  Widget build(BuildContext context) {
    getNotReachTemple();

    makePolylineList();

    if (templeDataList.isNotEmpty) {
      final boundsData = makeBounds(data: templeDataList);

      if (boundsData.isNotEmpty) {
        boundsLatLngMap = boundsData['boundsLatLngMap'];
        boundsInner = boundsData['boundsInner'];
      }
    }

    makeMarker();

    return (boundsLatLngMap.isNotEmpty)
        ? Column(
            children: [
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      templeDataList.length.toString(),
                      style: const TextStyle(color: Colors.white),
                    ),
                    IconButton(
                      onPressed: () {
                        mapController.move(currentCenter, 10);

                        TempleDialog(
                          context: context,
                          widget: const NotReachTempleTrainSelectAlert(),
                          paddingRight: context.screenSize.width * 0.2,
                          clearBarrierColor: true,
                        );
                      },
                      icon: const Icon(Icons.train, color: Colors.white),
                    ),
                  ],
                ),
              ),
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
                    //minZoom: 10,
                    maxZoom: 14,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    ),
                    PolylineLayer(polylines: polylineList),
                    MarkerLayer(markers: markerList),
                  ],
                ),
              ),
            ],
          )
        : Container();
  }

  ///
  void getNotReachTemple() {
    templeDataList = [];

    final jogaiTempleNameList = <String>[];
    final jogaiTempleAddressList = <String>[];
    final jogaiTempleAddressList2 = <String>[];

    ref
        .watch(templeLatLngProvider.select((value) => value.templeLatLngList))
        .forEach((element) {
      jogaiTempleNameList.add(element.temple);
      jogaiTempleAddressList.add(element.address);
      jogaiTempleAddressList2.add('東京都${element.address}');
    });

    final templeListList =
        ref.watch(templeListProvider.select((value) => value.templeListList));

    for (var i = 0; i < templeListList.length; i++) {
      if (jogaiTempleNameList.contains(templeListList[i].name)) {
        continue;
      }

      if (jogaiTempleAddressList.contains(templeListList[i].address)) {
        continue;
      }

      if (jogaiTempleAddressList2.contains(templeListList[i].address)) {
        continue;
      }

      if (jogaiTempleAddressList.contains('東京都${templeListList[i].address}')) {
        continue;
      }

      if (jogaiTempleAddressList2.contains('東京都${templeListList[i].address}')) {
        continue;
      }

      templeDataList.add(
        TempleData(
          name: templeListList[i].name,
          address: templeListList[i].address,
          latitude: templeListList[i].lat,
          longitude: templeListList[i].lng,
          mark: templeListList[i].id.toString(),
        ),
      );
    }
  }

  ///
  void makeMarker() {
    markerList = [];

    for (var i = 0; i < templeDataList.length; i++) {
      markerList.add(
        Marker(
          point: LatLng(
            templeDataList[i].latitude.toDouble(),
            templeDataList[i].longitude.toDouble(),
          ),
          builder: (context) {
            return GestureDetector(
              onTap: () {
                TempleDialog(
                  context: context,
                  widget: TempleInfoDisplayAlert(
                    temple: templeDataList[i],
                    from: 'NotReachTempleMapAlert',
                  ),
                  paddingTop: context.screenSize.height * 0.7,
                  clearBarrierColor: true,
                );
              },
              child: CircleAvatar(
                backgroundColor: getCircleAvatarBgColor(
                  element: templeDataList[i],
                  ref: ref,
                ),
                child: Text(
                  (templeDataList[i].mark == '0')
                      ? 'STA'
                      : templeDataList[i].mark.padLeft(3, '0'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            );
          },
        ),
      );
    }
  }

  ///
  void makePolylineList() {
    polylineList = [];

    final tokyoTrainState = ref.watch(tokyoTrainProvider);

    final twelveColor = utility.getTwelveColor();

    for (var i = 0; i < tokyoTrainState.selectTrainList.length; i++) {
      final map =
          tokyoTrainState.tokyoTrainIdMap[tokyoTrainState.selectTrainList[i]];

      final points = <LatLng>[];
      map?.station.forEach((element2) =>
          points.add(LatLng(element2.lat.toDouble(), element2.lng.toDouble())));

      polylineList.add(
        Polyline(points: points, color: twelveColor[i], strokeWidth: 5),
      );
    }
  }
}
