import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../extensions/extensions.dart';
import '../models/common/temple_data.dart';
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
