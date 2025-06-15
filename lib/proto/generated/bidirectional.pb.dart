//
//  Generated code. Do not modify.
//  source: bidirectional.proto
//
// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:core' as $core;

import 'package:protobuf/protobuf.dart' as $pb;

import 'google/protobuf/timestamp.pb.dart' as $1;

export 'package:protobuf/protobuf.dart' show GeneratedMessageGenericExtensions;

class Request extends $pb.GeneratedMessage {
  factory Request({
    $core.String? userName,
    $core.String? clientMessage,
  }) {
    final $result = create();
    if (userName != null) {
      $result.userName = userName;
    }
    if (clientMessage != null) {
      $result.clientMessage = clientMessage;
    }
    return $result;
  }
  Request._() : super();
  factory Request.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Request.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Request', package: const $pb.PackageName(_omitMessageNames ? '' : 'bidirectional'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'UserName', protoName: 'UserName')
    ..aOS(2, _omitFieldNames ? '' : 'ClientMessage', protoName: 'ClientMessage')
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Request clone() => Request()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Request copyWith(void Function(Request) updates) => super.copyWith((message) => updates(message as Request)) as Request;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Request create() => Request._();
  Request createEmptyInstance() => create();
  static $pb.PbList<Request> createRepeated() => $pb.PbList<Request>();
  @$core.pragma('dart2js:noInline')
  static Request getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Request>(create);
  static Request? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get userName => $_getSZ(0);
  @$pb.TagNumber(1)
  set userName($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasUserName() => $_has(0);
  @$pb.TagNumber(1)
  void clearUserName() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get clientMessage => $_getSZ(1);
  @$pb.TagNumber(2)
  set clientMessage($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasClientMessage() => $_has(1);
  @$pb.TagNumber(2)
  void clearClientMessage() => $_clearField(2);
}

class Response extends $pb.GeneratedMessage {
  factory Response({
    $core.String? userName,
    $core.String? responseMessage,
    $1.Timestamp? createdAt,
  }) {
    final $result = create();
    if (userName != null) {
      $result.userName = userName;
    }
    if (responseMessage != null) {
      $result.responseMessage = responseMessage;
    }
    if (createdAt != null) {
      $result.createdAt = createdAt;
    }
    return $result;
  }
  Response._() : super();
  factory Response.fromBuffer($core.List<$core.int> i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromBuffer(i, r);
  factory Response.fromJson($core.String i, [$pb.ExtensionRegistry r = $pb.ExtensionRegistry.EMPTY]) => create()..mergeFromJson(i, r);

  static final $pb.BuilderInfo _i = $pb.BuilderInfo(_omitMessageNames ? '' : 'Response', package: const $pb.PackageName(_omitMessageNames ? '' : 'bidirectional'), createEmptyInstance: create)
    ..aOS(1, _omitFieldNames ? '' : 'UserName', protoName: 'UserName')
    ..aOS(2, _omitFieldNames ? '' : 'ResponseMessage', protoName: 'ResponseMessage')
    ..aOM<$1.Timestamp>(3, _omitFieldNames ? '' : 'CreatedAt', protoName: 'CreatedAt', subBuilder: $1.Timestamp.create)
    ..hasRequiredFields = false
  ;

  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Response clone() => Response()..mergeFromMessage(this);
  @$core.Deprecated('See https://github.com/google/protobuf.dart/issues/998.')
  Response copyWith(void Function(Response) updates) => super.copyWith((message) => updates(message as Response)) as Response;

  $pb.BuilderInfo get info_ => _i;

  @$core.pragma('dart2js:noInline')
  static Response create() => Response._();
  Response createEmptyInstance() => create();
  static $pb.PbList<Response> createRepeated() => $pb.PbList<Response>();
  @$core.pragma('dart2js:noInline')
  static Response getDefault() => _defaultInstance ??= $pb.GeneratedMessage.$_defaultFor<Response>(create);
  static Response? _defaultInstance;

  @$pb.TagNumber(1)
  $core.String get userName => $_getSZ(0);
  @$pb.TagNumber(1)
  set userName($core.String v) { $_setString(0, v); }
  @$pb.TagNumber(1)
  $core.bool hasUserName() => $_has(0);
  @$pb.TagNumber(1)
  void clearUserName() => $_clearField(1);

  @$pb.TagNumber(2)
  $core.String get responseMessage => $_getSZ(1);
  @$pb.TagNumber(2)
  set responseMessage($core.String v) { $_setString(1, v); }
  @$pb.TagNumber(2)
  $core.bool hasResponseMessage() => $_has(1);
  @$pb.TagNumber(2)
  void clearResponseMessage() => $_clearField(2);

  @$pb.TagNumber(3)
  $1.Timestamp get createdAt => $_getN(2);
  @$pb.TagNumber(3)
  set createdAt($1.Timestamp v) { $_setField(3, v); }
  @$pb.TagNumber(3)
  $core.bool hasCreatedAt() => $_has(2);
  @$pb.TagNumber(3)
  void clearCreatedAt() => $_clearField(3);
  @$pb.TagNumber(3)
  $1.Timestamp ensureCreatedAt() => $_ensure(2);
}


const _omitFieldNames = $core.bool.fromEnvironment('protobuf.omit_field_names');
const _omitMessageNames = $core.bool.fromEnvironment('protobuf.omit_message_names');
