import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../extensions/extensions.dart';
import '../../models/tokyo_train_model.dart';
import '../../state/tokyo_train/tokyo_train.dart';
import '../_parts/_caution_dialog.dart';

class NotReachTempleTrainSelectAlert extends ConsumerStatefulWidget {
  const NotReachTempleTrainSelectAlert(
      {super.key, required this.tokyoTrainList});

  final List<TokyoTrainModel> tokyoTrainList;

  @override
  ConsumerState<NotReachTempleTrainSelectAlert> createState() =>
      _NotReachTempleTrainSelectAlertState();
}

class _NotReachTempleTrainSelectAlertState
    extends ConsumerState<NotReachTempleTrainSelectAlert> {
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
              Expanded(child: displayTrainCheckPanel()),
            ],
          ),
        ),
      ),
    );
  }

  ///
  Widget displayTrainCheckPanel() {
    final list = <Widget>[];

    final tokyoTrainState = ref.watch(tokyoTrainProvider);

    widget.tokyoTrainList.forEach((element) {
      list.add(
        CheckboxListTile(
          contentPadding: EdgeInsets.zero,
          activeColor: Colors.greenAccent,
          controlAffinity: ListTileControlAffinity.leading,
          value: tokyoTrainState.selectTrainList.contains(element.trainNumber),
          onChanged: (value) {
            if (!tokyoTrainState.selectTrainList
                .contains(element.trainNumber)) {
              if (tokyoTrainState.selectTrainList.length > 2) {
                caution_dialog(context: context, content: 'cant add train');

                return;
              }
            }

            ref
                .read(tokyoTrainProvider.notifier)
                .setTrainList(trainNumber: element.trainNumber);
          },
          title: Text(
            element.trainName,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ),
      );
    });

    return SingleChildScrollView(child: Column(children: list));
  }
}
