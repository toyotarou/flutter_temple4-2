import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/http/client.dart';
import '../../data/http/path.dart';
import '../../extensions/extensions.dart';
import '../../models/station_model.dart';
import '../../utility/utility.dart';

part 'station.freezed.dart';

part 'station.g.dart';

@freezed
class StationState with _$StationState {
  const factory StationState({
    @Default([]) List<StationModel> stationList,
    @Default({}) Map<String, StationModel> stationMap,
  }) = _StationState;
}

@riverpod
class Station extends _$Station {
  final utility = Utility();

  ///
  @override
  StationState build() => const StationState();

  ///
  Future<void> getAllStation() async {
    final client = ref.read(httpClientProvider);

    await client.post(path: APIPath.getAllStation).then((value) {
      final list = <StationModel>[];
      final map = <String, StationModel>{};

      // ignore: avoid_dynamic_calls
      for (var i = 0; i < value['data'].length.toString().toInt(); i++) {
        final val = StationModel.fromJson(
          // ignore: avoid_dynamic_calls
          value['data'][i] as Map<String, dynamic>,
        );

        list.add(val);
        map[val.id.toString()] = val;
      }

      state = state.copyWith(stationList: list, stationMap: map);
    }).catchError((error, _) {
      utility.showError('予期せぬエラーが発生しました');
    });
  }
}
