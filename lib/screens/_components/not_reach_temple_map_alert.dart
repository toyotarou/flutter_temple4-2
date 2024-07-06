import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../extensions/extensions.dart';
import '../../models/common/temple_data.dart';
import '../../models/station_model.dart';
import '../../models/temple_lat_lng_model.dart';
import '../../models/temple_list_model.dart';

import '../../models/temple_model.dart';
import '../../models/tokyo_station_model.dart';
import '../../models/tokyo_train_model.dart';

//selectTrainList
import '../../state/tokyo_train/tokyo_train.dart';
import '../../utility/utility.dart';
import '../_parts/_temple_dialog.dart';
import '../function.dart';
import 'not_reach_temple_train_select_alert.dart';
import 'temple_info_display_alert.dart';

class NotReachTempleMapAlert extends ConsumerStatefulWidget {
  const NotReachTempleMapAlert({
    super.key,
    required this.templeListList,
    required this.templeLatLngList,
    required this.tokyoTrainIdMap,
    required this.tokyoTrainList,
    required this.templeVisitDateMap,
    required this.dateTempleMap,
    required this.templeListMap,
    required this.stationMap,
  });

  final List<TempleListModel> templeListList;
  final List<TempleLatLngModel> templeLatLngList;
  final Map<int, TokyoTrainModel> tokyoTrainIdMap;
  final List<TokyoTrainModel> tokyoTrainList;
  final Map<String, List<String>> templeVisitDateMap;
  final Map<String, TempleModel> dateTempleMap;
  final Map<String, TempleListModel> templeListMap;
  final Map<String, StationModel> stationMap;

  @override
  ConsumerState<NotReachTempleMapAlert> createState() =>
      _NotReachTempleMapAlertState();
}

class _NotReachTempleMapAlertState extends ConsumerState<NotReachTempleMapAlert>
    with TickerProviderStateMixin {
  List<TempleData> templeDataList = [];

  Map<String, double> boundsLatLngMap = {};

  double boundsInner = 0;

  List<Marker> markerList = [];

  late final _animatedMapController = AnimatedMapController(vsync: this);
  late LatLng currentCenter;

  List<Polyline> polylineList = [];

  Utility utility = Utility();

  ///
  @override
  void initState() {
    super.initState();

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
                    Container(),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed: () {
                        _animatedMapController.move(currentCenter, 10);

                        TempleDialog(
                          context: context,
                          widget: NotReachTempleTrainSelectAlert(
                            tokyoTrainList: widget.tokyoTrainList,
                          ),
                          paddingRight: context.screenSize.width * 0.2,
                          clearBarrierColor: true,
                        );
                      },
                      icon: const Icon(Icons.train, color: Colors.white),
                    ),
                    Row(
                      children: [
                        IconButton(
                          onPressed: () {
                            _animatedMapController.animatedZoomIn();
                          },
                          icon: const Icon(
                            FontAwesomeIcons.plus,
                            color: Colors.white,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            _animatedMapController.animatedZoomOut();
                          },
                          icon: const Icon(
                            FontAwesomeIcons.minus,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: FlutterMap(
                  mapController: _animatedMapController,
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

    widget.templeLatLngList.forEach((element) {
      jogaiTempleNameList.add(element.temple);
      jogaiTempleAddressList.add(element.address);
      jogaiTempleAddressList2.add('東京都${element.address}');
    });

    for (var i = 0; i < widget.templeListList.length; i++) {
      if (jogaiTempleNameList.contains(widget.templeListList[i].name)) {
        continue;
      }

      if (jogaiTempleAddressList.contains(widget.templeListList[i].address)) {
        continue;
      }

      if (jogaiTempleAddressList2.contains(widget.templeListList[i].address)) {
        continue;
      }

      if (jogaiTempleAddressList
          .contains('東京都${widget.templeListList[i].address}')) {
        continue;
      }

      if (jogaiTempleAddressList2
          .contains('東京都${widget.templeListList[i].address}')) {
        continue;
      }

      templeDataList.add(
        TempleData(
          name: widget.templeListList[i].name,
          address: widget.templeListList[i].address,
          latitude: widget.templeListList[i].lat,
          longitude: widget.templeListList[i].lng,
          mark: widget.templeListList[i].id.toString(),
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
                    templeVisitDateMap: widget.templeVisitDateMap,
                    dateTempleMap: widget.dateTempleMap,
                    templeListMap: widget.templeListMap,
                    stationMap: widget.stationMap,
                  ),
                  paddingTop: context.screenSize.height * 0.6,
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
      final map = widget.tokyoTrainIdMap[tokyoTrainState.selectTrainList[i]];

      final points = <LatLng>[];
      map?.station.forEach((element2) =>
          points.add(LatLng(element2.lat.toDouble(), element2.lng.toDouble())));

      polylineList.add(
        Polyline(points: points, color: twelveColor[i], strokeWidth: 5),
      );
    }
  }
}
