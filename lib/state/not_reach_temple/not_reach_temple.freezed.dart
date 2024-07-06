// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'not_reach_temple.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$NotReachTempleState {
  String get selectedNotReachTempleId => throw _privateConstructorUsedError;
  List<StationModel> get selectedNotReachTempleStationList =>
      throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $NotReachTempleStateCopyWith<NotReachTempleState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $NotReachTempleStateCopyWith<$Res> {
  factory $NotReachTempleStateCopyWith(
          NotReachTempleState value, $Res Function(NotReachTempleState) then) =
      _$NotReachTempleStateCopyWithImpl<$Res, NotReachTempleState>;
  @useResult
  $Res call(
      {String selectedNotReachTempleId,
      List<StationModel> selectedNotReachTempleStationList});
}

/// @nodoc
class _$NotReachTempleStateCopyWithImpl<$Res, $Val extends NotReachTempleState>
    implements $NotReachTempleStateCopyWith<$Res> {
  _$NotReachTempleStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? selectedNotReachTempleId = null,
    Object? selectedNotReachTempleStationList = null,
  }) {
    return _then(_value.copyWith(
      selectedNotReachTempleId: null == selectedNotReachTempleId
          ? _value.selectedNotReachTempleId
          : selectedNotReachTempleId // ignore: cast_nullable_to_non_nullable
              as String,
      selectedNotReachTempleStationList: null ==
              selectedNotReachTempleStationList
          ? _value.selectedNotReachTempleStationList
          : selectedNotReachTempleStationList // ignore: cast_nullable_to_non_nullable
              as List<StationModel>,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$NotReachTempleStateImplCopyWith<$Res>
    implements $NotReachTempleStateCopyWith<$Res> {
  factory _$$NotReachTempleStateImplCopyWith(_$NotReachTempleStateImpl value,
          $Res Function(_$NotReachTempleStateImpl) then) =
      __$$NotReachTempleStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String selectedNotReachTempleId,
      List<StationModel> selectedNotReachTempleStationList});
}

/// @nodoc
class __$$NotReachTempleStateImplCopyWithImpl<$Res>
    extends _$NotReachTempleStateCopyWithImpl<$Res, _$NotReachTempleStateImpl>
    implements _$$NotReachTempleStateImplCopyWith<$Res> {
  __$$NotReachTempleStateImplCopyWithImpl(_$NotReachTempleStateImpl _value,
      $Res Function(_$NotReachTempleStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? selectedNotReachTempleId = null,
    Object? selectedNotReachTempleStationList = null,
  }) {
    return _then(_$NotReachTempleStateImpl(
      selectedNotReachTempleId: null == selectedNotReachTempleId
          ? _value.selectedNotReachTempleId
          : selectedNotReachTempleId // ignore: cast_nullable_to_non_nullable
              as String,
      selectedNotReachTempleStationList: null ==
              selectedNotReachTempleStationList
          ? _value._selectedNotReachTempleStationList
          : selectedNotReachTempleStationList // ignore: cast_nullable_to_non_nullable
              as List<StationModel>,
    ));
  }
}

/// @nodoc

class _$NotReachTempleStateImpl implements _NotReachTempleState {
  const _$NotReachTempleStateImpl(
      {this.selectedNotReachTempleId = '',
      final List<StationModel> selectedNotReachTempleStationList = const []})
      : _selectedNotReachTempleStationList = selectedNotReachTempleStationList;

  @override
  @JsonKey()
  final String selectedNotReachTempleId;
  final List<StationModel> _selectedNotReachTempleStationList;
  @override
  @JsonKey()
  List<StationModel> get selectedNotReachTempleStationList {
    if (_selectedNotReachTempleStationList is EqualUnmodifiableListView)
      return _selectedNotReachTempleStationList;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_selectedNotReachTempleStationList);
  }

  @override
  String toString() {
    return 'NotReachTempleState(selectedNotReachTempleId: $selectedNotReachTempleId, selectedNotReachTempleStationList: $selectedNotReachTempleStationList)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$NotReachTempleStateImpl &&
            (identical(
                    other.selectedNotReachTempleId, selectedNotReachTempleId) ||
                other.selectedNotReachTempleId == selectedNotReachTempleId) &&
            const DeepCollectionEquality().equals(
                other._selectedNotReachTempleStationList,
                _selectedNotReachTempleStationList));
  }

  @override
  int get hashCode => Object.hash(runtimeType, selectedNotReachTempleId,
      const DeepCollectionEquality().hash(_selectedNotReachTempleStationList));

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$NotReachTempleStateImplCopyWith<_$NotReachTempleStateImpl> get copyWith =>
      __$$NotReachTempleStateImplCopyWithImpl<_$NotReachTempleStateImpl>(
          this, _$identity);
}

abstract class _NotReachTempleState implements NotReachTempleState {
  const factory _NotReachTempleState(
          {final String selectedNotReachTempleId,
          final List<StationModel> selectedNotReachTempleStationList}) =
      _$NotReachTempleStateImpl;

  @override
  String get selectedNotReachTempleId;
  @override
  List<StationModel> get selectedNotReachTempleStationList;
  @override
  @JsonKey(ignore: true)
  _$$NotReachTempleStateImplCopyWith<_$NotReachTempleStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
