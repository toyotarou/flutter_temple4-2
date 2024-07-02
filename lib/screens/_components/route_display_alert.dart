import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../extensions/extensions.dart';
import '../../state/routing/routing.dart';
import '../function.dart';

class RouteDisplayAlert extends ConsumerStatefulWidget {
  const RouteDisplayAlert({super.key});

  @override
  ConsumerState<RouteDisplayAlert> createState() => _RouteDisplayAlertState();
}

class _RouteDisplayAlertState extends ConsumerState<RouteDisplayAlert> {
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
        child: DefaultTextStyle(
          style: const TextStyle(fontSize: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Container(width: context.screenSize.width),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () {
                      ref.read(routingProvider.notifier).insertRoute();
                    },
                    icon: const Icon(
                      Icons.input,
                      color: Colors.white,
                    ),
                  ),
                  Container(),
                ],
              ),
              Divider(
                color: Colors.white.withOpacity(0.5),
                thickness: 5,
              ),
              Expanded(child: displayRoute()),
            ],
          ),
        ),
      ),
    );
  }

  ///
  Widget displayRoute() {
    final list = <Widget>[];

    final routingState = ref.watch(routingProvider);

    final timeFormat = DateFormat('HH:mm');
    final startTime = timeFormat.format(DateTime.parse(routingState.startTime));

    var keepEndTime = '';

    final record = routingState.routingTempleDataList;

    for (var i = 0; i < record.length; i++) {
      final ll = [record[i].latitude, record[i].longitude];

      var distance = '';
      var walkMinutes = 0;
      if (i < record.length - 1) {
        if ((record[i].latitude == record[i + 1].latitude) &&
            (record[i].longitude == record[i + 1].longitude)) {
          //TODO 緯度経度が同じ場合
          distance = '0';
        } else {
          distance = calcDistance(
            originLat: record[i].latitude.toDouble(),
            originLng: record[i].longitude.toDouble(),
            destLat: record[i + 1].latitude.toDouble(),
            destLng: record[i + 1].longitude.toDouble(),
          );
        }

        final dist1000 = int.parse(
          (double.parse(distance) * 1000).toString().split('.')[0],
        );
        final ws = routingState.walkSpeed * 1000;
        final percent = (100 + routingState.adjustPercent) / 100;
        walkMinutes = ((dist1000 / ws * 60) * percent).round();
      }

      final exMark = record[i].mark.split('-');

      //------------------------//
      var st = (i == 0) ? startTime : keepEndTime;
      final spotStayTime = (exMark.length == 1) ? routingState.spotStayTime : 0;
      st = getTimeStr(time: st, minutes: spotStayTime);
      final endTime = getTimeStr(time: st, minutes: walkMinutes);
      //------------------------//

      list.add(
        Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: getCircleAvatarBgColor(
                    element: record[i],
                    ref: ref,
                  ),
                  child: Text(
                    i.toString(),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(record[i].name),
                      Container(
                        padding: const EdgeInsets.only(left: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(record[i].address),
                            Text(
                              ll.join(' / '),
                              style: const TextStyle(fontSize: 8),
                            ),
                            if (exMark.length == 1) ...[
                              Text('滞在時間：$spotStayTime 分'),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (i < record.length - 1)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.arrow_downward_outlined,
                    size: 40,
                    color: Colors.white.withOpacity(0.4),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(st),
                        Row(
                          children: [
                            Text('$distance Km'),
                            const Text(' / '),
                            Text('$walkMinutes 分'),
                          ],
                        ),
                        Text(endTime),
                      ],
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 30),
          ],
        ),
      );

      keepEndTime = endTime;
    }

    return SingleChildScrollView(child: Column(children: list));
  }

  ///
  String getTimeStr({required String time, required int minutes}) {
    final dt = DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
      time.split(':')[0].toInt(),
      time.split(':')[1].toInt(),
    ).add(Duration(minutes: minutes));

    final timeFormat = DateFormat('HH:mm');

    return timeFormat.format(dt);
  }
}
