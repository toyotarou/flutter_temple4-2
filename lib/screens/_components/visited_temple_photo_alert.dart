import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../extensions/extensions.dart';
import '../../models/common/temple_data.dart';
import '../../state/temple/temple.dart';

class VisitedTemplePhotoAlert extends ConsumerStatefulWidget {
  const VisitedTemplePhotoAlert(
      {super.key, required this.templeVisitDateMap, required this.temple});

  final Map<String, List<String>> templeVisitDateMap;
  final TempleData temple;

  @override
  ConsumerState<VisitedTemplePhotoAlert> createState() =>
      _VisitedTemplePhotoAlertState();
}

class _VisitedTemplePhotoAlertState
    extends ConsumerState<VisitedTemplePhotoAlert> {
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Container(width: context.screenSize.width),
              Text(widget.temple.name),
              Divider(color: Colors.white.withOpacity(0.4), thickness: 5),
              const SizedBox(height: 10),
              Expanded(child: displayVisitedTemplePhoto()),
            ],
          ),
        ),
      ),
    );
  }

  ///
  Widget displayVisitedTemplePhoto() {
    final list = <Widget>[];

    final dateTempleMap =
        ref.watch(templeProvider.select((value) => value.dateTempleMap));

    widget.templeVisitDateMap[widget.temple.name]?.forEach((element) {
      list.add(
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.white.withOpacity(0.1), Colors.transparent],
              stops: const [0.7, 1],
            ),
          ),
          padding: const EdgeInsets.all(5),
          child: Text(element),
        ),
      );

      final list2 = <Widget>[];

      dateTempleMap[element]?.photo.forEach((element2) {
        list2.add(
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            width: 50,
            child: CachedNetworkImage(
              imageUrl: element2,
              placeholder: (context, url) =>
                  Image.asset('assets/images/no_image.png'),
              errorWidget: (context, url, error) => const Icon(Icons.error),
            ),
          ),
        );
      });

      list.add(SizedBox(
        height: 100,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(children: list2),
        ),
      ));
    });

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: list,
      ),
    );
  }
}
