//
//  Generated code. Do not modify.
//  source: bidirectional.proto
//
// @dart = 3.3

// ignore_for_file: annotate_overrides, camel_case_types, comment_references
// ignore_for_file: constant_identifier_names, library_prefixes
// ignore_for_file: non_constant_identifier_names, prefer_final_fields
// ignore_for_file: unnecessary_import, unnecessary_this, unused_import

import 'dart:convert' as $convert;
import 'dart:core' as $core;
import 'dart:typed_data' as $typed_data;

@$core.Deprecated('Use requestDescriptor instead')
const Request$json = {
  '1': 'Request',
  '2': [
    {'1': 'UserName', '3': 1, '4': 1, '5': 9, '10': 'UserName'},
    {'1': 'ClientMessage', '3': 2, '4': 1, '5': 9, '10': 'ClientMessage'},
  ],
};

/// Descriptor for `Request`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List requestDescriptor = $convert.base64Decode(
    'CgdSZXF1ZXN0EhoKCFVzZXJOYW1lGAEgASgJUghVc2VyTmFtZRIkCg1DbGllbnRNZXNzYWdlGA'
    'IgASgJUg1DbGllbnRNZXNzYWdl');

@$core.Deprecated('Use responseDescriptor instead')
const Response$json = {
  '1': 'Response',
  '2': [
    {'1': 'UserName', '3': 1, '4': 1, '5': 9, '10': 'UserName'},
    {'1': 'ResponseMessage', '3': 2, '4': 1, '5': 9, '10': 'ResponseMessage'},
  ],
};

/// Descriptor for `Response`. Decode as a `google.protobuf.DescriptorProto`.
final $typed_data.Uint8List responseDescriptor = $convert.base64Decode(
    'CghSZXNwb25zZRIaCghVc2VyTmFtZRgBIAEoCVIIVXNlck5hbWUSKAoPUmVzcG9uc2VNZXNzYW'
    'dlGAIgASgJUg9SZXNwb25zZU1lc3NhZ2U=');

