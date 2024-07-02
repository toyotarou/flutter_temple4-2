import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/http/client.dart';
import '../../data/http/path.dart';
import '../../extensions/extensions.dart';
import '../../models/temple_model.dart';
import '../../utility/utility.dart';

part 'temple.freezed.dart';

part 'temple.g.dart';

@freezed
class TempleState with _$TempleState {
  const factory TempleState({
    @Default([]) List<TempleModel> templeList,
    @Default({}) Map<String, TempleModel> dateTempleMap,
    @Default({}) Map<String, TempleModel> latLngTempleMap,
    @Default({}) Map<String, TempleModel> nameTempleMap,

    ///
    @Default('') String searchWord,
    @Default(false) bool doSearch,

    ///
    @Default('') selectYear,

    //
    @Default('') selectTempleName,
    @Default('') selectTempleLat,
    @Default('') selectTempleLng,

    //
    @Default(-1) int selectVisitedTempleListKey,

    //
    @Default({}) Map<String, List<String>> templeVisitDateMap,

    //
    @Default({}) Map<String, List<String>> templeCountMap,
  }) = _TempleState;
}

@riverpod
class Temple extends _$Temple {
  final utility = Utility();

  ///
  @override
  TempleState build() => const TempleState();

  ///
  Future<void> getAllTemple() async {
    final client = ref.read(httpClientProvider);

    await client.post(path: APIPath.getAllTemple).then((value) {
      final list = <TempleModel>[];
      final map = <String, TempleModel>{};
      final map2 = <String, TempleModel>{};

      final map3 = <String, List<String>>{};
      final templeNameList = <String>[];

      final map4 = <String, List<String>>{};

      // ignore: avoid_dynamic_calls
      for (var i = 0; i < value['list'].length.toString().toInt(); i++) {
        final val = TempleModel.fromJson(
          // ignore: avoid_dynamic_calls
          value['list'][i] as Map<String, dynamic>,
        );

        list.add(val);
        map[val.date.yyyymmdd] = val;

        map2['${val.lat}|${val.lng}'] = val;

        map3[val.temple] = [];
        templeNameList.add(val.temple);

        map4[val.date.yyyy] = [];
      }

      // ignore: avoid_dynamic_calls
      for (var i = 0; i < value['list'].length.toString().toInt(); i++) {
        final val = TempleModel.fromJson(
          // ignore: avoid_dynamic_calls
          value['list'][i] as Map<String, dynamic>,
        );

        val.memo.split('、').forEach((element) {
          map3[element] = [];
        });
      }

      // ignore: avoid_dynamic_calls
      for (var i = 0; i < value['list'].length.toString().toInt(); i++) {
        final val = TempleModel.fromJson(
          // ignore: avoid_dynamic_calls
          value['list'][i] as Map<String, dynamic>,
        );

        map3[val.temple]?.add(val.date.yyyymmdd);

        map4[val.date.yyyy]?.add(val.temple);

        val.memo.split('、').forEach((element) {
          if (element != '') {
            map3[element]?.add(val.date.yyyymmdd);

            map4[val.date.yyyy]?.add(element);
          }
        });
      }

      state = state.copyWith(
        templeList: list,
        dateTempleMap: map,
        latLngTempleMap: map2,
        templeVisitDateMap: map3,
        templeCountMap: map4,
      );
    }).catchError((error, _) {
      utility.showError('予期せぬエラーが発生しました');
    });
  }

  ///
  Future<void> doSearch({required String searchWord}) async =>
      state = state.copyWith(searchWord: searchWord, doSearch: true);

  ///
  Future<void> clearSearch() async =>
      state = state.copyWith(searchWord: '', doSearch: false);

  ///
  Future<void> setSelectYear({required String year}) async =>
      state = state.copyWith(selectYear: year);

  ///
  Future<void> setSelectTemple({
    required String name,
    required String lat,
    required String lng,
  }) async =>
      state = state.copyWith(
        selectTempleName: name,
        selectTempleLat: lat,
        selectTempleLng: lng,
      );

  ///
  Future<void> setSelectVisitedTempleListKey({required int key}) async =>
      state = state.copyWith(selectVisitedTempleListKey: key);
}
