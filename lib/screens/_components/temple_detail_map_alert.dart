import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:latlong2/latlong.dart';

import '../../extensions/extensions.dart';
import '../../models/common/temple_data.dart';
import '../../models/temple_model.dart';
import '../../state/station/station.dart';
import '../../state/temple/temple.dart';
import '../../state/temple_lat_lng/temple_lat_lng.dart';
import '../../utility/utility.dart';
import '../_parts/_temple_dialog.dart';
import '../function.dart';
import 'temple_course_display_alert.dart';
import 'temple_photo_gallery_alert.dart';

class TempleDetailMapAlert extends ConsumerStatefulWidget {
  const TempleDetailMapAlert({super.key, required this.date});

  final DateTime date;

  @override
  ConsumerState<TempleDetailMapAlert> createState() =>
      _TempleDetailDialogState();
}

class _TempleDetailDialogState extends ConsumerState<TempleDetailMapAlert> {
  List<TempleData> templeDataList = [];

  Map<String, double> boundsLatLngMap = {};

  double boundsInner = 0;

  List<Marker> markerList = [];

  List<Polyline> polylineList = [];

  Utility utility = Utility();

  String start = '';
  String end = '';

  ///
  @override
  void initState() {
    super.initState();

    ref.read(templeLatLngProvider.notifier).getAllTempleLatLng();

    ref.read(stationProvider.notifier).getAllStation();
  }

  ///
  @override
  Widget build(BuildContext context) {
    makeTempleDataList();

    final boundsData = makeBounds(data: templeDataList);

    if (boundsData.isNotEmpty) {
      boundsLatLngMap = boundsData['boundsLatLngMap'];
      boundsInner = boundsData['boundsInner'];
    }

    makeMarker();

    makeStartEnd();

    return Stack(
      children: [
        (boundsLatLngMap.isNotEmpty)
            ? FlutterMap(
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
                        points: templeDataList.map((e) {
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
              )
            : Container(),
        displayInfoPlate(),
      ],
    );
  }

  ///
  Widget displayInfoPlate() {
    final dateTempleMap =
        ref.watch(templeProvider.select((value) => value.dateTempleMap));

    final temple = dateTempleMap[widget.date.yyyymmdd];

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconButton(
            onPressed: () {
              TempleDialog(
                context: context,
                widget: TempleCourseDisplayAlert(data: templeDataList),
                paddingLeft: context.screenSize.width * 0.2,
                clearBarrierColor: true,
              );
            },
            icon: const Icon(
              Icons.info_outline,
              size: 30,
              color: Colors.white,
            ),
          ),
          (temple == null)
              ? Container()
              : DefaultTextStyle(
                  style: const TextStyle(color: Colors.white),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(widget.date.yyyymmdd),
                      Text(temple.temple),
                      const SizedBox(height: 10),
                      Text(start),
                      Text(end),
                      if (temple.memo != '') ...[
                        const SizedBox(height: 10),
                        Flexible(
                          child: SizedBox(
                            width: context.screenSize.width * 0.6,
                            child: Text(temple.memo),
                          ),
                        ),
                      ],
                      const SizedBox(height: 10),
                      displayThumbNailPhoto(),
                    ],
                  ),
                ),
        ],
      ),
    );
  }

  ///
  Widget displayThumbNailPhoto() {
    final dateTempleMap =
        ref.watch(templeProvider.select((value) => value.dateTempleMap));

    final temple = dateTempleMap[widget.date.yyyymmdd];

    final list = <Widget>[];

    if (temple != null) {
      if (temple.photo.isNotEmpty) {
        for (var i = 0; i < temple.photo.length; i++) {
          list.add(
            GestureDetector(
              onTap: () {
                TempleDialog(
                  context: context,
                  widget: TemplePhotoGalleryAlert(
                    photoList: temple.photo,
                    number: i,
                  ),
                );
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 5),
                width: 50,
                child: CachedNetworkImage(
                  imageUrl: temple.photo[i],
                  placeholder: (context, url) =>
                      Image.asset('assets/images/no_image.png'),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
              ),
            ),
          );
        }
      }
    }

    return SizedBox(
      width: context.screenSize.width * 0.6,
      child: SingleChildScrollView(
          scrollDirection: Axis.horizontal, child: Row(children: list)),
    );
  }

  ///
  void makeTempleDataList() {
    templeDataList = [];

    final dateTempleMap =
        ref.watch(templeProvider.select((value) => value.dateTempleMap));

    final templeLatLngMap = ref
        .watch(templeLatLngProvider.select((value) => value.templeLatLngMap));

    final temple = dateTempleMap[widget.date.yyyymmdd];

    if (temple != null) {
      getStartEndPointInfo(temple: temple, flag: 'start');

      if (templeLatLngMap[temple.temple] != null) {
        templeDataList.add(
          TempleData(
            name: temple.temple,
            address: templeLatLngMap[temple.temple]!.address,
            latitude: templeLatLngMap[temple.temple]!.lat,
            longitude: templeLatLngMap[temple.temple]!.lng,
            mark: '01',
          ),
        );
      }

      if (temple.memo != '') {
        var i = 2;
        temple.memo.split('、').forEach((element) {
          final latlng = templeLatLngMap[element];

          if (latlng != null) {
            templeDataList.add(
              TempleData(
                name: element,
                address: latlng.address,
                latitude: latlng.lat,
                longitude: latlng.lng,
                mark: i.toString().padLeft(2, '0'),
              ),
            );
          }

          i++;
        });
      }

      getStartEndPointInfo(temple: temple, flag: 'end');
    }
  }

  ///
  Future<void> getStartEndPointInfo(
      {required TempleModel temple, required String flag}) async {
    final stationMap =
        ref.watch(stationProvider.select((value) => value.stationMap));

    var point = '';
    switch (flag) {
      case 'start':
        point = temple.startPoint;
        break;
      case 'end':
        point = temple.endPoint;
        break;
    }

    if (stationMap[point] != null) {
      templeDataList.add(
        TempleData(
          name: stationMap[point]!.stationName,
          address: stationMap[point]!.address,
          latitude: stationMap[point]!.lat,
          longitude: stationMap[point]!.lng,
          mark: (flag == 'end')
              ? (temple.startPoint == temple.endPoint)
                  ? 'S/E'
                  : 'E'
              : (temple.startPoint == temple.endPoint)
                  ? 'S/E'
                  : 'S',
        ),
      );
    } else {
      switch (point) {
        case '自宅':
          templeDataList.add(
            TempleData(
              name: point,
              address: '千葉県船橋市二子町492-25-101',
              latitude: '35.7102009',
              longitude: '139.9490672',
              mark: (flag == 'end')
                  ? (temple.startPoint == temple.endPoint)
                      ? 'S/E'
                      : 'E'
                  : (temple.startPoint == temple.endPoint)
                      ? 'S/E'
                      : 'S',
            ),
          );

        case '実家':
          templeDataList.add(
            TempleData(
              name: point,
              address: '東京都杉並区善福寺4-22-11',
              latitude: '35.7185071',
              longitude: '139.5869534',
              mark: (flag == 'end')
                  ? (temple.startPoint == temple.endPoint)
                      ? 'S/E'
                      : 'E'
                  : (temple.startPoint == temple.endPoint)
                      ? 'S/E'
                      : 'S',
            ),
          );
      }
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
            return CircleAvatar(
              backgroundColor: getCircleAvatarBgColor(
                element: templeDataList[i],
                ref: ref,
              ),
              child: Text(
                templeDataList[i].mark,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          },
        ),
      );
    }
  }

  ///
  void makeStartEnd() {
    if (templeDataList.isNotEmpty) {
      final sWhere = templeDataList
          .where((element) => element.mark == 'S' || element.mark == 'S/E');
      if (sWhere.isNotEmpty) {
        start = sWhere.first.name;
      }

      final eWhere = templeDataList
          .where((element) => element.mark == 'E' || element.mark == 'S/E');

      if (eWhere.isNotEmpty) {
        end = eWhere.first.name;
      }
    }

    setState(() {});
  }
}
