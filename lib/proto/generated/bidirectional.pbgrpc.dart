//
//  Generated code. Do not modify.
//  source: bidirectional.proto
//
// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:async' as $async;
import 'dart:core' as $core;

import 'package:grpc/service_api.dart' as $grpc;
import 'package:protobuf/protobuf.dart' as $pb;

import 'bidirectional.pb.dart' as $0;

export 'bidirectional.pb.dart';

@$pb.GrpcServiceName('bidirectional.Bidirectional')
class BidirectionalClient extends $grpc.Client {
  /// The hostname for this service.
  static const $core.String defaultHost = '';

  /// OAuth scopes needed for the client.
  static const $core.List<$core.String> oauthScopes = [
    '',
  ];

  static final _$chatty = $grpc.ClientMethod<$0.Request, $0.Response>(
      '/bidirectional.Bidirectional/Chatty',
      ($0.Request value) => value.writeToBuffer(),
      ($core.List<$core.int> value) => $0.Response.fromBuffer(value));

  BidirectionalClient(super.channel, {super.options, super.interceptors});

  $grpc.ResponseStream<$0.Response> chatty($async.Stream<$0.Request> request, {$grpc.CallOptions? options}) {
    return $createStreamingCall(_$chatty, request, options: options);
  }
}

@$pb.GrpcServiceName('bidirectional.Bidirectional')
abstract class BidirectionalServiceBase extends $grpc.Service {
  $core.String get $name => 'bidirectional.Bidirectional';

  BidirectionalServiceBase() {
    $addMethod($grpc.ServiceMethod<$0.Request, $0.Response>(
        'Chatty',
        chatty,
        true,
        true,
        ($core.List<$core.int> value) => $0.Request.fromBuffer(value),
        ($0.Response value) => value.writeToBuffer()));
  }

  $async.Stream<$0.Response> chatty($grpc.ServiceCall call, $async.Stream<$0.Request> request);
}
