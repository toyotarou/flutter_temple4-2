import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/http/client.dart';
import '../../data/http/path.dart';
import '../../extensions/extensions.dart';
import '../../models/temple_list_model.dart';
import '../../utility/utility.dart';

part 'temple_list.freezed.dart';

part 'temple_list.g.dart';

@freezed
class TempleListState with _$TempleListState {
  const factory TempleListState({
    @Default([]) List<TempleListModel> templeListList,
    @Default({}) Map<String, TempleListModel> templeListMap,
    @Default({}) Map<String, List<TempleListModel>> templeStationMap,
  }) = _TempleListState;
}

@riverpod
class TempleList extends _$TempleList {
  final utility = Utility();

  ///
  @override
  TempleListState build() => const TempleListState();

  ///
  Future<void> getAllTempleListTemple() async {
    final client = ref.read(httpClientProvider);

    await client.post(path: APIPath.getTempleListTemple).then((value) {
      final list = <TempleListModel>[];
      final map = <String, TempleListModel>{};
      final templeStationMap = <String, List<TempleListModel>>{};

      // ignore: avoid_dynamic_calls
      for (var i = 0; i < value['data'].length.toString().toInt(); i++) {
        final val = TempleListModel.fromJson(
          // ignore: avoid_dynamic_calls
          value['data'][i] as Map<String, dynamic>,
        );

        list.add(val);
        map[val.name] = val;

        val.nearStation.split(',').forEach((element) {
          templeStationMap[element.trim()] = [];
        });
      }

      // ignore: avoid_dynamic_calls
      for (var i = 0; i < value['data'].length.toString().toInt(); i++) {
        final val = TempleListModel.fromJson(
          // ignore: avoid_dynamic_calls
          value['data'][i] as Map<String, dynamic>,
        );

        val.nearStation.split(',').forEach((element) {
          templeStationMap[element.trim()]?.add(val);
        });
      }

      state = state.copyWith(
        templeListList: list,
        templeListMap: map,
        templeStationMap: templeStationMap,
      );
    }).catchError((error, _) {
      utility.showError('予期せぬエラーが発生しました');
    });
  }
}

@riverpod
class TempleNotReachList extends _$TempleNotReachList {
  final utility = Utility();

  ///
  @override
  TempleListState build() => const TempleListState();

  ///
  Future<void> getAllNotReachTemple() async {
    final client = ref.read(httpClientProvider);

    await client.post(path: APIPath.templeNotReached).then((value) {
      final list = <TempleListModel>[];
      final map = <String, TempleListModel>{};
      final templeStationMap = <String, List<TempleListModel>>{};

      // ignore: avoid_dynamic_calls
      for (var i = 0; i < value['data'].length.toString().toInt(); i++) {
        final val = TempleListModel.fromJson(
          // ignore: avoid_dynamic_calls
          value['data'][i] as Map<String, dynamic>,
        );

        list.add(val);
        map[val.name] = val;

        val.nearStation.split(',').forEach((element) {
          templeStationMap[element.trim()] = [];
        });
      }

      // ignore: avoid_dynamic_calls
      for (var i = 0; i < value['data'].length.toString().toInt(); i++) {
        final val = TempleListModel.fromJson(
          // ignore: avoid_dynamic_calls
          value['data'][i] as Map<String, dynamic>,
        );

        val.nearStation.split(',').forEach((element) {
          templeStationMap[element.trim()]?.add(val);
        });
      }

      state = state.copyWith(
        templeListList: list,
        templeListMap: map,
        templeStationMap: templeStationMap,
      );
    }).catchError((error, _) {
      utility.showError('予期せぬエラーが発生しました');
    });
  }
}
