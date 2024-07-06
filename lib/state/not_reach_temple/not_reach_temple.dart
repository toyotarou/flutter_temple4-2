import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../models/station_model.dart';

part 'not_reach_temple.freezed.dart';
part 'not_reach_temple.g.dart';

@freezed
class NotReachTempleState with _$NotReachTempleState {
  const factory NotReachTempleState({
    @Default('') String selectedNotReachTempleId,
    @Default([]) List<StationModel> selectedNotReachTempleStationList,
  }) = _NotReachTempleState;
}

@riverpod
class NotReachTemple extends _$NotReachTemple {
  ///
  @override
  NotReachTempleState build() => const NotReachTempleState();

  ///
  Future<void> setSelectedNotReachTempleId({required String id}) async {
    state = state.copyWith(selectedNotReachTempleId: id);
  }

  ///
  Future<void> setSelectedNotReachTempleStationList(
      {required StationModel stationModel}) async {
    final list = [...state.selectedNotReachTempleStationList];

    final stationNameList = <String>[];
    list.forEach((element) => stationNameList.add(element.stationName));

    final pos = stationNameList
        .indexWhere((element) => element == stationModel.stationName);

    if (pos != -1) {
      list.removeAt(pos);
    } else {
      list.add(stationModel);
    }

    state = state.copyWith(selectedNotReachTempleStationList: list);
  }

  ///
  Future<void> clearSelectedNotReachTemple() async {
    state = state.copyWith(
      selectedNotReachTempleId: '',
      selectedNotReachTempleStationList: [],
    );
  }
}
