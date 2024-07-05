import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../extensions/extensions.dart';
import '../models/common/temple_data.dart';
import '../models/tokyo_station_model.dart';
import '../state/routing/routing.dart';
import '../state/temple/temple.dart';

///
Color? getCircleAvatarBgColor(
    {required TempleData element, required WidgetRef ref}) {
  Color? color;

  switch (element.mark) {
    case 'S':
    case 'E':
    case 'S/E':
    case '0':
    case 'STA':
      color = Colors.green[900]?.withOpacity(0.5);
      break;
    case '01':
      color = Colors.redAccent.withOpacity(0.5);
      break;
    default:
      if (element.cnt > 0) {
        color = Colors.pinkAccent.withOpacity(0.5);
      } else {
        color = Colors.orangeAccent.withOpacity(0.5);
      }

      break;
  }

  if (element.mark.split('-').length == 2) {
    color = Colors.purpleAccent.withOpacity(0.5);
  } else {
    final routingTempleDataList = ref
        .watch(routingProvider.select((value) => value.routingTempleDataList));

    final pos = routingTempleDataList
        .indexWhere((element2) => element2.mark == element.mark);

    if (pos != -1) {
      color = Colors.indigo.withOpacity(0.5);
    }
  }

  return color;
}

///
Map<String, dynamic> makeBounds({required List<TempleData> data}) {
  final latList = <double>[];
  final lngList = <double>[];

  data.forEach((element) {
    latList.add(element.latitude.toDouble());
    lngList.add(element.longitude.toDouble());
  });

  if (latList.isNotEmpty && lngList.isNotEmpty) {
    final minLat = latList.reduce(min);
    final maxLat = latList.reduce(max);
    final minLng = lngList.reduce(min);
    final maxLng = lngList.reduce(max);

    final latDiff = maxLat - minLat;
    final lngDiff = maxLng - minLng;
    final small = (latDiff < lngDiff) ? latDiff : lngDiff;

    final boundsLatLngMap = {
      'minLat': minLat,
      'maxLat': maxLat,
      'minLng': minLng,
      'maxLng': maxLng,
    };

    return {'boundsLatLngMap': boundsLatLngMap, 'boundsInner': small};
  }

  return {};
}

///
String calcDistance({
  required double originLat,
  required double originLng,
  required double destLat,
  required double destLng,
}) {
  final distanceKm = 6371 *
      acos(
        cos(originLat / 180 * pi) *
                cos((destLng - originLng) / 180 * pi) *
                cos(destLat / 180 * pi) +
            sin(originLat / 180 * pi) * sin(destLat / 180 * pi),
      );

  final exDistance = distanceKm.toString().split('.');

  final seisuu = exDistance[0];
  final shousuu = exDistance[1].substring(0, 2);

  return '$seisuu.$shousuu';
}

///
List<int> makeTempleVisitYearList({required WidgetRef ref}) {
  final list = <int>[];

  ref
      .watch(templeProvider.select((value) => value.templeList))
      .forEach((element) {
    if (!list.contains(element.date.year)) {
      list.add(element.date.year);
    }
  });

  return list;
}

///
List<TokyoStationModel> getNearTokyoStation({
  required TempleData temple,
  required Map<String, TokyoStationModel> tokyoStationMap,
}) {
  final list = <TokyoStationModel>[];

  final map = <double, List<TokyoStationModel>>{};

  final distanceList = <double>[];

  var distance = '';
  tokyoStationMap
    ..forEach((key, value) {
      distance = calcDistance(
        originLat: temple.latitude.toDouble(),
        originLng: temple.longitude.toDouble(),
        destLat: value.lat.toDouble(),
        destLng: value.lng.toDouble(),
      );

      if (distance.toDouble() < 3.0) {
        map[distance.toDouble()] = [];

        distanceList.add(distance.toDouble());
      }
    })
    ..forEach((key, value) {
      distance = calcDistance(
        originLat: temple.latitude.toDouble(),
        originLng: temple.longitude.toDouble(),
        destLat: value.lat.toDouble(),
        destLng: value.lng.toDouble(),
      );

      if (distance.toDouble() < 3.0) {
        map[distance.toDouble()]?.add(value);
      }
    });

  final stationNames = <String>[];

  distanceList
    ..sort()
    ..forEach((element) {
      map[element]?.forEach((element2) {
        if (!stationNames.contains(element2.stationName)) {
          list.add(element2);
        }

        stationNames.add(element2.stationName);
      });
    });

  return list;
}
