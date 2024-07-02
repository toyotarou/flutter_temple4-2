import 'package:flutter_temple4/extensions/extensions.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/http/client.dart';
import '../../data/http/path.dart';
import '../../models/common/temple_data.dart';
import '../../models/tokyo_station_model.dart';
import '../../utility/utility.dart';

part 'routing.freezed.dart';

part 'routing.g.dart';

@freezed
class RoutingState with _$RoutingState {
  const factory RoutingState({
    @Default([]) List<TempleData> routingTempleDataList,
    @Default({}) Map<String, TempleData> routingTempleDataMap,

    ///
    @Default('') String startStationId,
    @Default('') String goalStationId,

    //
    @Default(true) bool startNow,
    @Default('') String startTime,

    //
    @Default(5) int walkSpeed,

    //
    @Default(20) int spotStayTime,

    //
    @Default(20) int adjustPercent,
  }) = _RoutingState;
}

@riverpod
class Routing extends _$Routing {
  final utility = Utility();

  ///
  @override
  RoutingState build() => const RoutingState();

  ///
  Future<void> setRouting(
      {required TempleData templeData, TokyoStationModel? station}) async {
    final list = [...state.routingTempleDataList];

    if (list.isEmpty) {
      if (station != null) {
        final stationTempleData = TempleData(
          name: station.stationName,
          address: station.address,
          latitude: station.lat,
          longitude: station.lng,
          mark: station.id,
        );

        list.add(stationTempleData);
      }
    }

    if (station?.stationName == templeData.name) {
      if (list.last.mark.split('-').length == 2) {
        list.removeAt(list.length - 1);
      }
    } else {
      final markList = <String>[];
      list.forEach((element) => markList.add(element.mark));

      final pos = markList.indexWhere((element) => element == templeData.mark);

      if (pos != -1) {
        list.removeAt(pos);
      } else {
        list.add(templeData);
      }
    }

    if (station?.stationName != templeData.name) {
      if (templeData.mark.split('-').length == 2) {
        list[list.length - 1] = templeData;
      }
    }

    state = state.copyWith(routingTempleDataList: list);
  }

  ///
  Future<void> removeGoalStation() async {
    final list = [...state.routingTempleDataList];

    var pos = 0;
    for (var i = 1; i < list.length; i++) {
      final exMarkLength = list[i].mark.split('-').length;

      if (exMarkLength == 2) {
        pos = i;
      }
    }

    list.removeAt(pos);

    state = state.copyWith(routingTempleDataList: list, goalStationId: '');
  }

  ///
  Future<void> clearRoutingTempleDataList() async {
    state = state.copyWith(routingTempleDataList: []);
  }

  ///
  Future<void> setStartStationId({required String id}) async =>
      state = state.copyWith(startStationId: id);

  ///
  Future<void> setGoalStationId({required String id}) async =>
      state = state.copyWith(goalStationId: id);

  ///
  Future<void> setSelectTime({required String time}) async =>
      state = state.copyWith(startNow: false, startTime: time);

  ///
  Future<void> setWalkSpeed({required int speed}) async =>
      state = state.copyWith(walkSpeed: speed);

  ///
  Future<void> setSpotStayTime({required int time}) async =>
      state = state.copyWith(spotStayTime: time);

  ///
  Future<void> setAdjustPercent({required int adjust}) async =>
      state = state.copyWith(adjustPercent: adjust);

  ///
  Future<void> insertRoute() async {
    final list = [...state.routingTempleDataList];
    final first = list.first;
    final last = list.last;

    final firstMark = first.mark.split('-')[1];
    final lastMark = last.mark.split('-')[1];

    final data = <String>['start-$firstMark'];
    for (var i = 1; i < list.length - 1; i++) {
      data.add(list[i].mark);
    }
    data.add('goal-$lastMark');

    final client = ref.read(httpClientProvider);

    await client
        .post(
          path: APIPath.insertTempleRoute,
          body: {'date': DateTime.now().yyyymmdd, 'data': data},
        )
        .then((value) {})
        .catchError((error, _) {
          utility.showError('予期せぬエラーが発生しました');
        });
  }
}
