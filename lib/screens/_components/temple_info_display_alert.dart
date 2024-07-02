import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_temple4/screens/_components/visited_temple_photo_alert.dart';
import 'package:flutter_temple4/screens/_parts/_temple_dialog.dart';

import '../../extensions/extensions.dart';
import '../../models/common/temple_data.dart';
import '../../models/tokyo_station_model.dart';
import '../../state/routing/routing.dart';
import '../../state/temple/temple.dart';
import '../function.dart';

class TempleInfoDisplayAlert extends ConsumerStatefulWidget {
  const TempleInfoDisplayAlert(
      {super.key, required this.temple, required this.from, this.station});

  final TempleData temple;
  final String from;
  final TokyoStationModel? station;

  @override
  ConsumerState<TempleInfoDisplayAlert> createState() =>
      _TempleInfoDisplayAlertState();
}

class _TempleInfoDisplayAlertState
    extends ConsumerState<TempleInfoDisplayAlert> {
  ///
  @override
  void initState() {
    super.initState();

    ref.read(templeProvider.notifier).getAllTemple();
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
        child: DefaultTextStyle(
          style: const TextStyle(fontSize: 12),
          child: Column(
            children: [
              const SizedBox(height: 20),
              displayTempleInfo(),
              displayAddRemoveRoutingButton(),
            ],
          ),
        ),
      ),
    );
  }

  ///
  Widget displayAddRemoveRoutingButton() {
    if (widget.from != 'LatLngTempleMapAlert') {
      return Container();
    }

    final routingTempleDataList = ref
        .watch(routingProvider.select((value) => value.routingTempleDataList));

    final pos = routingTempleDataList
        .indexWhere((element) => element.mark == widget.temple.mark);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Container(),
        ElevatedButton(
          onPressed: () {
            ref
                .read(routingProvider.notifier)
                .setRouting(templeData: widget.temple, station: widget.station);
          },
          style: ElevatedButton.styleFrom(
              backgroundColor: (pos != -1)
                  ? Colors.white.withOpacity(0.2)
                  : Colors.indigo.withOpacity(0.2)),
          child: Text((pos != -1) ? 'remove routing' : 'add routing'),
        ),
      ],
    );
  }

  ///
  Widget displayTempleInfo() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        displayTempleInfoCircleAvatar(),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(width: context.screenSize.width),
              Text(widget.temple.name),
              Text(widget.temple.address),
              Text(widget.temple.latitude),
              Text(widget.temple.longitude),
              const SizedBox(height: 10),
              displayTempleVisitDate(),
            ],
          ),
        ),
        displayVisitedTemplePhoto(),
      ],
    );
  }

  ///
  Widget displayVisitedTemplePhoto() {
    if (widget.from != 'VisitedTempleMapAlert') {
      return Row(
        children: [Container(), const SizedBox(width: 20)],
      );
    }

    final templeVisitDateMap =
        ref.watch(templeProvider.select((value) => value.templeVisitDateMap));

    return GestureDetector(
      onTap: () {
        TempleDialog(
          context: context,
          widget: VisitedTemplePhotoAlert(
            templeVisitDateMap: templeVisitDateMap,
            temple: widget.temple,
          ),
          paddingTop: context.screenSize.height * 0.1,
          paddingLeft: context.screenSize.width * 0.2,
        );
      },
      child: const Icon(Icons.photo, color: Colors.white),
    );
  }

  ///
  Widget displayTempleInfoCircleAvatar() {
    if (widget.from == 'VisitedTempleMapAlert') {
      return Row(
        children: [Container(), const SizedBox(width: 20)],
      );
    }

    return Row(
      children: [
        CircleAvatar(
          backgroundColor:
              getCircleAvatarBgColor(element: widget.temple, ref: ref),
          child: Text(
            widget.temple.mark.padLeft(2, '0'),
            style: const TextStyle(color: Colors.white),
          ),
        ),
        const SizedBox(width: 20),
      ],
    );
  }

  ///
  Widget displayTempleVisitDate() {
    final templeVisitDateMap =
        ref.watch(templeProvider.select((value) => value.templeVisitDateMap));

    if (widget.from != 'VisitedTempleMapAlert') {
      return Container();
    }

    return SizedBox(
      height: 80,
      width: double.infinity,
      child: Scrollbar(
        thumbVisibility: true,
        child: SingleChildScrollView(
          child: Wrap(
            children: templeVisitDateMap[widget.temple.name]!.map((e) {
              return Container(
                width: context.screenSize.width / 5,
                padding: const EdgeInsets.symmetric(vertical: 3, horizontal: 5),
                margin: const EdgeInsets.all(1),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white.withOpacity(0.2)),
                ),
                child: Text(e, style: const TextStyle(fontSize: 12)),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
