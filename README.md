#  qt wasm build

docker pull colorlength/qt-webassembly-build-env:latest
docker run -v $BUILD_PWD/build_wasm:/project/build -v $SOURCE_PWD:/project/source colorlength/qt-webassembly-build-env:latest
