// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dashboard_schema.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$WidgetSize {

/// Breite in Raster-Spalten (1–4).
 int get cols;/// Höhe in Raster-Reihen (1–3).
 int get rows;
/// Create a copy of WidgetSize
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WidgetSizeCopyWith<WidgetSize> get copyWith => _$WidgetSizeCopyWithImpl<WidgetSize>(this as WidgetSize, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as WidgetSize;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WidgetSize&&(identical(other.cols, _this.cols) || other.cols == _this.cols)&&(identical(other.rows, _this.rows) || other.rows == _this.rows));
}


@override
int get hashCode {
  final _this = this as WidgetSize;
  return Object.hash(runtimeType,_this.cols,_this.rows);
}

@override
String toString() {
  final _this = this as WidgetSize;
  return 'WidgetSize(cols: ${_this.cols}, rows: ${_this.rows})';
}


}

/// @nodoc
abstract mixin class $WidgetSizeCopyWith<$Res>  {
  factory $WidgetSizeCopyWith(WidgetSize value, $Res Function(WidgetSize) _then) = _$WidgetSizeCopyWithImpl;
@useResult
$Res call({
 int cols, int rows
});




}
/// @nodoc
class _$WidgetSizeCopyWithImpl<$Res>
    implements $WidgetSizeCopyWith<$Res> {
  _$WidgetSizeCopyWithImpl(this._self, this._then);

  final WidgetSize _self;
  final $Res Function(WidgetSize) _then;

/// Create a copy of WidgetSize
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? cols = null,Object? rows = null,}) {
  return _then(WidgetSize(
cols: null == cols ? _self.cols : cols // ignore: cast_nullable_to_non_nullable
as int,rows: null == rows ? _self.rows : rows // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [WidgetSize].
extension WidgetSizePatterns on WidgetSize {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WidgetSize value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WidgetSize() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WidgetSize value)  $default,){
final _that = this;
switch (_that) {
case _WidgetSize():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WidgetSize value)?  $default,){
final _that = this;
switch (_that) {
case _WidgetSize() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int cols,  int rows)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WidgetSize() when $default != null:
return $default(_that.cols,_that.rows);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int cols,  int rows)  $default,) {final _that = this;
switch (_that) {
case _WidgetSize():
return $default(_that.cols,_that.rows);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int cols,  int rows)?  $default,) {final _that = this;
switch (_that) {
case _WidgetSize() when $default != null:
return $default(_that.cols,_that.rows);case _:
  return null;

}
}

}

/// @nodoc


class _WidgetSize implements WidgetSize {
  const _WidgetSize({this.cols = 2, this.rows = 2});
  

/// Breite in Raster-Spalten (1–4).
@override@JsonKey() final  int cols;
/// Höhe in Raster-Reihen (1–3).
@override@JsonKey() final  int rows;

/// Create a copy of WidgetSize
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WidgetSizeCopyWith<_WidgetSize> get copyWith => __$WidgetSizeCopyWithImpl<_WidgetSize>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _WidgetSize&&(identical(other.cols, cols) || other.cols == cols)&&(identical(other.rows, rows) || other.rows == rows));
}


@override
int get hashCode {
    return Object.hash(runtimeType,cols,rows);
}

@override
String toString() {
    return 'WidgetSize(cols: $cols, rows: $rows)';
}


}

/// @nodoc
abstract mixin class _$WidgetSizeCopyWith<$Res> implements $WidgetSizeCopyWith<$Res> {
  factory _$WidgetSizeCopyWith(_WidgetSize value, $Res Function(_WidgetSize) _then) = __$WidgetSizeCopyWithImpl;
@override @useResult
$Res call({
 int cols, int rows
});




}
/// @nodoc
class __$WidgetSizeCopyWithImpl<$Res>
    implements _$WidgetSizeCopyWith<$Res> {
  __$WidgetSizeCopyWithImpl(this._self, this._then);

  final _WidgetSize _self;
  final $Res Function(_WidgetSize) _then;

/// Create a copy of WidgetSize
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? cols = null,Object? rows = null,}) {
  return _then(_WidgetSize(
cols: null == cols ? _self.cols : cols // ignore: cast_nullable_to_non_nullable
as int,rows: null == rows ? _self.rows : rows // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
mixin _$WidgetConfig {

/// Stabile ID (Client generiert; UUID-artig).
 String get id;/// Baustein-Typ.
 WidgetType get type;/// Position innerhalb des Layouts (0-basiert, eindeutig).
 int get index;/// Raster-Größe.
 WidgetSize get size;/// Typspezifische, validierte Eigenschaften.
 Map<String, Object?> get props;
/// Create a copy of WidgetConfig
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WidgetConfigCopyWith<WidgetConfig> get copyWith => _$WidgetConfigCopyWithImpl<WidgetConfig>(this as WidgetConfig, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as WidgetConfig;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WidgetConfig&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.type, _this.type) || other.type == _this.type)&&(identical(other.index, _this.index) || other.index == _this.index)&&(identical(other.size, _this.size) || other.size == _this.size)&&const DeepCollectionEquality().equals(other.props, _this.props));
}


@override
int get hashCode {
  final _this = this as WidgetConfig;
  return Object.hash(runtimeType,_this.id,_this.type,_this.index,_this.size,const DeepCollectionEquality().hash(_this.props));
}

@override
String toString() {
  final _this = this as WidgetConfig;
  return 'WidgetConfig(id: ${_this.id}, type: ${_this.type}, index: ${_this.index}, size: ${_this.size}, props: ${_this.props})';
}


}

/// @nodoc
abstract mixin class $WidgetConfigCopyWith<$Res>  {
  factory $WidgetConfigCopyWith(WidgetConfig value, $Res Function(WidgetConfig) _then) = _$WidgetConfigCopyWithImpl;
@useResult
$Res call({
 String id, WidgetType type, int index, WidgetSize size, Map<String, Object?> props
});


$WidgetSizeCopyWith<$Res> get size;

}
/// @nodoc
class _$WidgetConfigCopyWithImpl<$Res>
    implements $WidgetConfigCopyWith<$Res> {
  _$WidgetConfigCopyWithImpl(this._self, this._then);

  final WidgetConfig _self;
  final $Res Function(WidgetConfig) _then;

/// Create a copy of WidgetConfig
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? type = null,Object? index = null,Object? size = null,Object? props = null,}) {
  return _then(WidgetConfig(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as WidgetType,index: null == index ? _self.index : index // ignore: cast_nullable_to_non_nullable
as int,size: null == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as WidgetSize,props: null == props ? _self.props : props // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>,
  ));
}
/// Create a copy of WidgetConfig
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$WidgetSizeCopyWith<$Res> get size {
  
  return $WidgetSizeCopyWith<$Res>(_self.size, (value) {
    return _then(_self.copyWith(size: value));
  });
}
}


/// Adds pattern-matching-related methods to [WidgetConfig].
extension WidgetConfigPatterns on WidgetConfig {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WidgetConfig value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WidgetConfig() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WidgetConfig value)  $default,){
final _that = this;
switch (_that) {
case _WidgetConfig():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WidgetConfig value)?  $default,){
final _that = this;
switch (_that) {
case _WidgetConfig() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  WidgetType type,  int index,  WidgetSize size,  Map<String, Object?> props)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WidgetConfig() when $default != null:
return $default(_that.id,_that.type,_that.index,_that.size,_that.props);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  WidgetType type,  int index,  WidgetSize size,  Map<String, Object?> props)  $default,) {final _that = this;
switch (_that) {
case _WidgetConfig():
return $default(_that.id,_that.type,_that.index,_that.size,_that.props);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  WidgetType type,  int index,  WidgetSize size,  Map<String, Object?> props)?  $default,) {final _that = this;
switch (_that) {
case _WidgetConfig() when $default != null:
return $default(_that.id,_that.type,_that.index,_that.size,_that.props);case _:
  return null;

}
}

}

/// @nodoc


class _WidgetConfig extends WidgetConfig {
  const _WidgetConfig({required this.id, required this.type, required this.index, required this.size,  Map<String, Object?> props = const {}}): _props = props,super._();
  

/// Stabile ID (Client generiert; UUID-artig).
@override final  String id;
/// Baustein-Typ.
@override final  WidgetType type;
/// Position innerhalb des Layouts (0-basiert, eindeutig).
@override final  int index;
/// Raster-Größe.
@override final  WidgetSize size;
/// Typspezifische, validierte Eigenschaften.
 final  Map<String, Object?> _props;
/// Typspezifische, validierte Eigenschaften.
@override@JsonKey() Map<String, Object?> get props {
  if (_props is EqualUnmodifiableMapView) return _props;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_props);
}


/// Create a copy of WidgetConfig
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WidgetConfigCopyWith<_WidgetConfig> get copyWith => __$WidgetConfigCopyWithImpl<_WidgetConfig>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _WidgetConfig&&(identical(other.id, id) || other.id == id)&&(identical(other.type, type) || other.type == type)&&(identical(other.index, index) || other.index == index)&&(identical(other.size, size) || other.size == size)&&const DeepCollectionEquality().equals(other.props, _props));
}


@override
int get hashCode {
    return Object.hash(runtimeType,id,type,index,size,const DeepCollectionEquality().hash(_props));
}

@override
String toString() {
    return 'WidgetConfig(id: $id, type: $type, index: $index, size: $size, props: $props)';
}


}

/// @nodoc
abstract mixin class _$WidgetConfigCopyWith<$Res> implements $WidgetConfigCopyWith<$Res> {
  factory _$WidgetConfigCopyWith(_WidgetConfig value, $Res Function(_WidgetConfig) _then) = __$WidgetConfigCopyWithImpl;
@override @useResult
$Res call({
 String id, WidgetType type, int index, WidgetSize size, Map<String, Object?> props
});


@override $WidgetSizeCopyWith<$Res> get size;

}
/// @nodoc
class __$WidgetConfigCopyWithImpl<$Res>
    implements _$WidgetConfigCopyWith<$Res> {
  __$WidgetConfigCopyWithImpl(this._self, this._then);

  final _WidgetConfig _self;
  final $Res Function(_WidgetConfig) _then;

/// Create a copy of WidgetConfig
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? type = null,Object? index = null,Object? size = null,Object? props = null,}) {
  return _then(_WidgetConfig(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as WidgetType,index: null == index ? _self.index : index // ignore: cast_nullable_to_non_nullable
as int,size: null == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as WidgetSize,props: null == props ? _self._props : props // ignore: cast_nullable_to_non_nullable
as Map<String, Object?>,
  ));
}

/// Create a copy of WidgetConfig
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$WidgetSizeCopyWith<$Res> get size {
  
  return $WidgetSizeCopyWith<$Res>(_self.size, (value) {
    return _then(_self.copyWith(size: value));
  });
}
}

/// @nodoc
mixin _$DashboardLayout {

/// Schema-Version (aktuell 1).
 int get schemaVersion;/// Stabile ID des Layouts.
 String get id;/// Anzeigename.
 String get name;/// Hauptbereich, dem das Layout zugeordnet ist.
 HealthArea get area;/// Bausteine in Darstellungsreihenfolge (index aufsteigend).
 List<WidgetConfig> get widgets;
/// Create a copy of DashboardLayout
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DashboardLayoutCopyWith<DashboardLayout> get copyWith => _$DashboardLayoutCopyWithImpl<DashboardLayout>(this as DashboardLayout, _$identity);



@override
bool operator ==(Object other) {
  final _this = this as DashboardLayout;
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DashboardLayout&&(identical(other.schemaVersion, _this.schemaVersion) || other.schemaVersion == _this.schemaVersion)&&(identical(other.id, _this.id) || other.id == _this.id)&&(identical(other.name, _this.name) || other.name == _this.name)&&(identical(other.area, _this.area) || other.area == _this.area)&&const DeepCollectionEquality().equals(other.widgets, _this.widgets));
}


@override
int get hashCode {
  final _this = this as DashboardLayout;
  return Object.hash(runtimeType,_this.schemaVersion,_this.id,_this.name,_this.area,const DeepCollectionEquality().hash(_this.widgets));
}

@override
String toString() {
  final _this = this as DashboardLayout;
  return 'DashboardLayout(schemaVersion: ${_this.schemaVersion}, id: ${_this.id}, name: ${_this.name}, area: ${_this.area}, widgets: ${_this.widgets})';
}


}

/// @nodoc
abstract mixin class $DashboardLayoutCopyWith<$Res>  {
  factory $DashboardLayoutCopyWith(DashboardLayout value, $Res Function(DashboardLayout) _then) = _$DashboardLayoutCopyWithImpl;
@useResult
$Res call({
 int schemaVersion, String id, String name, HealthArea area, List<WidgetConfig> widgets
});




}
/// @nodoc
class _$DashboardLayoutCopyWithImpl<$Res>
    implements $DashboardLayoutCopyWith<$Res> {
  _$DashboardLayoutCopyWithImpl(this._self, this._then);

  final DashboardLayout _self;
  final $Res Function(DashboardLayout) _then;

/// Create a copy of DashboardLayout
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? schemaVersion = null,Object? id = null,Object? name = null,Object? area = null,Object? widgets = null,}) {
  return _then(DashboardLayout(
schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as int,id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,area: null == area ? _self.area : area // ignore: cast_nullable_to_non_nullable
as HealthArea,widgets: null == widgets ? _self.widgets : widgets // ignore: cast_nullable_to_non_nullable
as List<WidgetConfig>,
  ));
}

}


/// Adds pattern-matching-related methods to [DashboardLayout].
extension DashboardLayoutPatterns on DashboardLayout {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DashboardLayout value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DashboardLayout() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DashboardLayout value)  $default,){
final _that = this;
switch (_that) {
case _DashboardLayout():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DashboardLayout value)?  $default,){
final _that = this;
switch (_that) {
case _DashboardLayout() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int schemaVersion,  String id,  String name,  HealthArea area,  List<WidgetConfig> widgets)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DashboardLayout() when $default != null:
return $default(_that.schemaVersion,_that.id,_that.name,_that.area,_that.widgets);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int schemaVersion,  String id,  String name,  HealthArea area,  List<WidgetConfig> widgets)  $default,) {final _that = this;
switch (_that) {
case _DashboardLayout():
return $default(_that.schemaVersion,_that.id,_that.name,_that.area,_that.widgets);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int schemaVersion,  String id,  String name,  HealthArea area,  List<WidgetConfig> widgets)?  $default,) {final _that = this;
switch (_that) {
case _DashboardLayout() when $default != null:
return $default(_that.schemaVersion,_that.id,_that.name,_that.area,_that.widgets);case _:
  return null;

}
}

}

/// @nodoc


class _DashboardLayout implements DashboardLayout {
  const _DashboardLayout({this.schemaVersion = 1, required this.id, required this.name, required this.area,  List<WidgetConfig> widgets = const []}): _widgets = widgets;
  

/// Schema-Version (aktuell 1).
@override@JsonKey() final  int schemaVersion;
/// Stabile ID des Layouts.
@override final  String id;
/// Anzeigename.
@override final  String name;
/// Hauptbereich, dem das Layout zugeordnet ist.
@override final  HealthArea area;
/// Bausteine in Darstellungsreihenfolge (index aufsteigend).
 final  List<WidgetConfig> _widgets;
/// Bausteine in Darstellungsreihenfolge (index aufsteigend).
@override@JsonKey() List<WidgetConfig> get widgets {
  if (_widgets is EqualUnmodifiableListView) return _widgets;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_widgets);
}


/// Create a copy of DashboardLayout
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DashboardLayoutCopyWith<_DashboardLayout> get copyWith => __$DashboardLayoutCopyWithImpl<_DashboardLayout>(this, _$identity);



@override
bool operator ==(Object other) {
    return identical(this, other) || (other.runtimeType == runtimeType&&other is _DashboardLayout&&(identical(other.schemaVersion, schemaVersion) || other.schemaVersion == schemaVersion)&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.area, area) || other.area == area)&&const DeepCollectionEquality().equals(other.widgets, _widgets));
}


@override
int get hashCode {
    return Object.hash(runtimeType,schemaVersion,id,name,area,const DeepCollectionEquality().hash(_widgets));
}

@override
String toString() {
    return 'DashboardLayout(schemaVersion: $schemaVersion, id: $id, name: $name, area: $area, widgets: $widgets)';
}


}

/// @nodoc
abstract mixin class _$DashboardLayoutCopyWith<$Res> implements $DashboardLayoutCopyWith<$Res> {
  factory _$DashboardLayoutCopyWith(_DashboardLayout value, $Res Function(_DashboardLayout) _then) = __$DashboardLayoutCopyWithImpl;
@override @useResult
$Res call({
 int schemaVersion, String id, String name, HealthArea area, List<WidgetConfig> widgets
});




}
/// @nodoc
class __$DashboardLayoutCopyWithImpl<$Res>
    implements _$DashboardLayoutCopyWith<$Res> {
  __$DashboardLayoutCopyWithImpl(this._self, this._then);

  final _DashboardLayout _self;
  final $Res Function(_DashboardLayout) _then;

/// Create a copy of DashboardLayout
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? schemaVersion = null,Object? id = null,Object? name = null,Object? area = null,Object? widgets = null,}) {
  return _then(_DashboardLayout(
schemaVersion: null == schemaVersion ? _self.schemaVersion : schemaVersion // ignore: cast_nullable_to_non_nullable
as int,id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,area: null == area ? _self.area : area // ignore: cast_nullable_to_non_nullable
as HealthArea,widgets: null == widgets ? _self._widgets : widgets // ignore: cast_nullable_to_non_nullable
as List<WidgetConfig>,
  ));
}


}

// dart format on
