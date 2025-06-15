@echo off
mkdir -p lib/proto/generated
protoc --dart_out=grpc:lib/proto/generated -Ilib/proto lib/proto/bidirectional.proto