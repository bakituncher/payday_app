// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'pay_period.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

/// @nodoc
mixin _$PayPeriod {
  DateTime get start => throw _privateConstructorUsedError;
  DateTime get end => throw _privateConstructorUsedError;

  /// Create a copy of PayPeriod
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PayPeriodCopyWith<PayPeriod> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PayPeriodCopyWith<$Res> {
  factory $PayPeriodCopyWith(PayPeriod value, $Res Function(PayPeriod) then) =
      _$PayPeriodCopyWithImpl<$Res, PayPeriod>;
  @useResult
  $Res call({DateTime start, DateTime end});
}

/// @nodoc
class _$PayPeriodCopyWithImpl<$Res, $Val extends PayPeriod>
    implements $PayPeriodCopyWith<$Res> {
  _$PayPeriodCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PayPeriod
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? start = null, Object? end = null}) {
    return _then(
      _value.copyWith(
            start: null == start
                ? _value.start
                : start // ignore: cast_nullable_to_non_nullable
                      as DateTime,
            end: null == end
                ? _value.end
                : end // ignore: cast_nullable_to_non_nullable
                      as DateTime,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$PayPeriodImplCopyWith<$Res>
    implements $PayPeriodCopyWith<$Res> {
  factory _$$PayPeriodImplCopyWith(
    _$PayPeriodImpl value,
    $Res Function(_$PayPeriodImpl) then,
  ) = __$$PayPeriodImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({DateTime start, DateTime end});
}

/// @nodoc
class __$$PayPeriodImplCopyWithImpl<$Res>
    extends _$PayPeriodCopyWithImpl<$Res, _$PayPeriodImpl>
    implements _$$PayPeriodImplCopyWith<$Res> {
  __$$PayPeriodImplCopyWithImpl(
    _$PayPeriodImpl _value,
    $Res Function(_$PayPeriodImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of PayPeriod
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({Object? start = null, Object? end = null}) {
    return _then(
      _$PayPeriodImpl(
        start: null == start
            ? _value.start
            : start // ignore: cast_nullable_to_non_nullable
                  as DateTime,
        end: null == end
            ? _value.end
            : end // ignore: cast_nullable_to_non_nullable
                  as DateTime,
      ),
    );
  }
}

/// @nodoc

class _$PayPeriodImpl extends _PayPeriod {
  const _$PayPeriodImpl({required this.start, required this.end}) : super._();

  @override
  final DateTime start;
  @override
  final DateTime end;

  @override
  String toString() {
    return 'PayPeriod(start: $start, end: $end)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PayPeriodImpl &&
            (identical(other.start, start) || other.start == start) &&
            (identical(other.end, end) || other.end == end));
  }

  @override
  int get hashCode => Object.hash(runtimeType, start, end);

  /// Create a copy of PayPeriod
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PayPeriodImplCopyWith<_$PayPeriodImpl> get copyWith =>
      __$$PayPeriodImplCopyWithImpl<_$PayPeriodImpl>(this, _$identity);
}

abstract class _PayPeriod extends PayPeriod {
  const factory _PayPeriod({
    required final DateTime start,
    required final DateTime end,
  }) = _$PayPeriodImpl;
  const _PayPeriod._() : super._();

  @override
  DateTime get start;
  @override
  DateTime get end;

  /// Create a copy of PayPeriod
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PayPeriodImplCopyWith<_$PayPeriodImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
