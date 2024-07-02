import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/http/client.dart';
import '../../data/http/path.dart';
import '../../extensions/extensions.dart';
import '../../models/temple_lat_lng_model.dart';
import '../../utility/utility.dart';

part 'temple_lat_lng.freezed.dart';

part 'temple_lat_lng.g.dart';

@freezed
class TempleLatLngState with _$TempleLatLngState {
  const factory TempleLatLngState({
    @Default([]) List<TempleLatLngModel> templeLatLngList,
    @Default({}) Map<String, TempleLatLngModel> templeLatLngMap,
  }) = _TempleLatLngState;
}

@riverpod
class TempleLatLng extends _$TempleLatLng {
  final utility = Utility();

  ///
  @override
  TempleLatLngState build() => const TempleLatLngState();

  ///
  Future<void> getAllTempleLatLng() async {
    final client = ref.read(httpClientProvider);

    await client.post(path: APIPath.getTempleLatLng).then((value) {
      final list = <TempleLatLngModel>[];
      final map = <String, TempleLatLngModel>{};

      // ignore: avoid_dynamic_calls
      for (var i = 0; i < value['list'].length.toString().toInt(); i++) {
        final val = TempleLatLngModel.fromJson(
          // ignore: avoid_dynamic_calls
          value['list'][i] as Map<String, dynamic>,
        );

        list.add(val);
        map[val.temple] = val;
      }

      state = state.copyWith(templeLatLngList: list, templeLatLngMap: map);
    }).catchError((error, _) {
      utility.showError('予期せぬエラーが発生しました');
    });
  }
}
