#!/bin/bash

SERVICE_NAME=$1
RELEASE_VERSION=$2
USER_NAME=$3
EMAIL=$4

git config user.name "$USER_NAME"
git config user.email "$EMAIL"
git fetch --all && git checkout main

sudo apt-get install -y protobuf-compiler golang-goprotobuf-dev
go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest
mkdir -p go
protoc --go_out=./go --go_opt=paths=source_relative \
  --go-grpc_out=./go --go-grpc_opt=paths=source_relative \
 ./${SERVICE_NAME}/*.proto
cd go/${SERVICE_NAME}
go mod init \
  github.com/lamtrinh/ecom-proto/go/${SERVICE_NAME} || true
go mod tidy
cd ../../
git add . && git commit -am "build: :rocket: update proto" || true
git push origin HEAD:main
git tag -fa go/${SERVICE_NAME}/${RELEASE_VERSION} \
  -m "go/${SERVICE_NAME}/${RELEASE_VERSION}" 
git push origin refs/tags/go/${SERVICE_NAME}/${RELEASE_VERSION}